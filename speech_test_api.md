# speech_test.py API 文档

## 1. 概述

实验室语音助手：**麦克风 → 讯飞 ASR → DeepSeek 意图分类 → 状态机调度 → record.json → RAG 创意生成**

---

## 2. 系统架构

```
麦克风 ──▶ listen_and_recognize() ──▶ classify() ──▶ ExperimentRecorder.dispatch()
                │                           │                    │
                ▼                           ▼                    ▼
         _iflytek_recognize()         SYSTEM_PROMPT      generate_experiment_json()
          (讯飞 WebSocket)          (意图分类提示词)        (结构化 JSON 生成)
                                                               │
                                                               ▼
                                                         record.json
                                                               │
                                                               ▼
                                                    generate_idea_from_record()
                                                               │
                                                          rag_main()
                                                    (Chroma 向量检索 + DeepSeek)
                                                               │
                                                               ▼
                                                         idea_data.json
```

---

## 3. 数据流（一次完整实验）

```
"实验开始，合成阿司匹林，水杨酸十克..."
  → classify() → intent=start_experiment
  → state: idle → collecting_info

"加入五毫升浓硫酸"
  → classify() → intent=add_step
  → state: collecting_info → in_progress, steps+=1

"观察到溶液变蓝有沉淀"
  → classify() → intent=experiment_result
  → exp.observation 写入

"实验结束"
  → classify() → intent=experiment_end
  → 终端打印汇总
  → generate_experiment_json() → DeepSeek 结构化
  → 写入 record.json（自增 id）
  → generate_idea_from_record() → RAG 检索 + 创意生成 → 写入 idea_data.json
  → state: idle
```

---

## 4. 函数 API

### 4.1 语音识别

#### `_iflytek_recognize(raw_data: bytes) -> str`

讯飞语音听写（WebSocket，内部函数）。

- **原理**：HMAC-SHA256 签名 → WebSocket 连接 `iat-api.xfyun.cn/v2/iat` → PCM 16kHz 分帧发送（1280B/帧，Base64）→ 轮询等待结果（最长 8s）
- **参数**：`raw_data` — PCM 16kHz 16bit 单声道原始音频
- **返回**：识别文本
- **异常**：`sr.RequestError`（握手超时/讯飞错误码），`sr.UnknownValueError`（无结果）

#### `listen_and_recognize(recognizer, source) -> str`

麦克风采集 + 讯飞识别。

- **参数**：`recognizer`（`sr.Recognizer`），`source`（`sr.Microphone`）
- **返回**：识别文本
- **时长**：最长录音 30s，无输入 1s 超时

---

### 4.2 NLP 层

#### `classify(text: str) -> dict`

DeepSeek 意图分类。

- **原理**：`SYSTEM_PROMPT` + 用户文本 → DeepSeek Chat API → 解析 JSON
- **返回**：`{"intent": str, "data": {...}}`（intent 取值见下表）
- **超时**：10s，temperature=0，max_tokens=80

| intent | 含义 | data 字段 |
|--------|------|-----------|
| `start_experiment` | 开始实验 | `purpose`, `materials`?, `conditions`? |
| `add_step` | 操作步骤 | `step` |
| `experiment_result` | 实验现象 | `observation` |
| `experiment_failed` | 实验失败 | `{}` |
| `experiment_end` | 实验结束 | `{}` |
| `none` | 无关内容 | `{}` |

#### `generate_experiment_json(exp: Experiment) -> dict`

实验结束时，将累积的原始语音文本发送 DeepSeek 生成结构化 JSON。

- **返回字段**：`参数`(dict)、`耗材`(list)、`实验报告`(str)、`现象结论`(str)、`dt`(ISO 8601)、`实验名称`(str)
- **超时**：30s，temperature=0.1，max_tokens=2048
- **异常时 fallback**：用 Experiment 已有字段构造记录

---

### 4.3 RAG 创意生成

#### `generate_idea_from_record(record: dict) -> dict | None`

实验结束后自动调用，基于「现象结论」生成科研创意。

- **流程**：
  1. 提取 `record["现象结论"]`，为空则跳过
  2. 调用 `rag_main(new_phen)` — 写入 Chroma 向量库 → 检索 top-5 相似历史现象 → DeepSeek 对比生成创意
  3. 将 `{id, new_idea_title, new_idea}` 追加写入 `idea_data.json`
- **返回**：`rag_main()` 完整结果（含 `generated`/`new_idea_title`/`new_idea`），现象为空时返回 `None`

---

## 5. 状态机 — `ExperimentRecorder`

### 5.1 状态转换

```
            start_experiment
  ┌────┐ ────────────────────▶ ┌────────────────┐
  │idle│                        │collecting_info │
  └────┘ ◀──────────────────── └───────┬────────┘
    ▲      experiment_failed          │ add_step
    │                                  ▼
    │                          ┌────────────────┐
    │       experiment_end     │  in_progress   │
    └──────────────────────────└────────────────┘
```

| 状态 | 含义 |
|------|------|
| `idle` | 无进行中的实验 |
| `collecting_info` | 已创建实验，可多次补充基本信息 |
| `in_progress` | 实验中，记录操作步骤 |

### 5.2 方法速查

| 方法 | 触发 intent | 行为 |
|------|------------|------|
| `dispatch(intent, data)` | — | 统一入口，按 intent 分发 |
| `handle_start_experiment(data)` | `start_experiment` | idle→新建；collecting_info→追加；in_progress→覆盖 |
| `handle_add_step(data)` | `add_step` | idle→忽略；collecting_info→切 in_progress 后追加；in_progress→直接追加 |
| `handle_experiment_result(data)` | `experiment_result` | 写入 `exp.observation` |
| `handle_experiment_failed(data)` | `experiment_failed` | 丢弃实验 → idle |
| `handle_experiment_end(data)` | `experiment_end` | **见下方** |

### 5.3 `handle_experiment_end` 完整流程

1. 前置检查：无实验/未记录现象 → 提示并拒绝
2. 终端打印 `exp.summary()`
3. 调用 `generate_experiment_json(exp)` 生成结构化记录（失败则 fallback）
4. 追加写入 `record.json`，自动分配自增 `id`
5. 调用 `generate_idea_from_record(record)` → RAG 创意生成 → 写入 `idea_data.json`
6. 重置：`exp=None`，`state=idle`

---

## 6. Experiment 数据结构

```python
@dataclass
class Experiment:
    name: str = ""          # 实验名称
    purpose: str = ""       # 实验目的
    materials: str = ""     # 耗材用量
    conditions: str = ""    # 环境条件
    steps: list = []        # 步骤列表
    observation: str = ""   # 实验现象
    start_time: float       # 开始时间戳（自动）
    raw_texts: list = []    # ASR 原始文本（用于结构化生成）
```

**属性**：`step_count`(int)、`has_basic_info`(bool)
**方法**：`summary()`(终端格式化汇总)、`print_basic_info()`(打印基本信息)

---

## 7. main() 主循环

```
校准麦克风(2s) → 无限循环:
  等待语音 → 讯飞 ASR → classify() → dispatch()
```

**异常处理**：`WaitTimeoutError`/`UnknownValueError`/`RequestError`/DeepSeek 异常均静默跳过继续；`KeyboardInterrupt` 正常退出。

---

## 8. 文件依赖

| 文件 | 读写 | 说明 |
|------|------|------|
| `record.json` | 读写 | 实验记录（JSON 数组，自增 id） |
| `idea_data.json` | 读写 | RAG 创意记录（JSON 数组） |
| `rag_idea_generator/` | 导入 | Chroma 向量库 + DeepSeek 创意生成 |
| `speech_recognition` | 库 | 麦克风采集 |
| `websocket-client` | 库 | 讯飞 WebSocket |
| `requests` | 库 | DeepSeek HTTP |
