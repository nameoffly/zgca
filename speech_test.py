"""
实验室语音助手
场景: 防护服科研人员通过语音记录实验流程
流程: 语音 → 讯飞 ASR → DeepSeek 意图分类+结构化提取 → 状态机调度
"""

import base64
import hashlib
import hmac
import json
import os
import ssl
import sys
import threading
import time
import urllib.parse
from dataclasses import dataclass, field
from datetime import datetime, timezone

from pathlib import Path

import requests
import speech_recognition as sr
import websocket

from rag_idea_generator import main as rag_main

# ── API 配置 ──
IFLYTEK = {
    "appid": "c2c9b4a6",
    "apikey": "b1f19d0ef468bd34debc2d13e0eedf25",
    "apisecret": "ZjZmYTk0Yjk0NjA1YTI2ODc5YTQxNmU1",
}
DEEPSEEK = {
    "api_key": "sk-e0e11e33d6104560bba5dcdebf568fe9",
    "base_url": "https://api.deepseek.com/v1/chat/completions",
    "model": "deepseek-chat",
}

sys.stdout.reconfigure(line_buffering=True, encoding="utf-8")

# ── DeepSeek 系统提示词 ──
SYSTEM_PROMPT = """你是实验室语音助手。判断用户意图并从语音中提取结构化信息，只输出一行 JSON。

输出格式: {"intent":"标签","data":{...}}

意图标签及对应的 data 字段:
- start_experiment: 实验基本信息
  data: {"purpose":"实验目的","materials":"材料及用量(没有则省略)","conditions":"温湿度等条件(没有则省略)"}
- add_step: 实验操作步骤
  data: {"step":"规范化的步骤描述"}
- experiment_result: 实验现象
  data: {"observation":"现象描述"}
- experiment_failed: 实验失败/中止
  data: {}
- experiment_end: 实验结束
  data: {}
- none: 无法归类
  data: {}

示例:
输入: "实验开始，本次实验目的是合成阿司匹林，使用水杨酸十克醋酐十五毫升，温度八十度湿度六十"
输出: {"intent":"start_experiment","data":{"purpose":"合成阿司匹林","materials":"水杨酸10克、醋酐15毫升","conditions":"温度80度、湿度60%"}}

输入: "加入五毫升浓硫酸"
输出: {"intent":"add_step","data":{"step":"加入5毫升浓硫酸"}}

输入: "观察到溶液变成了蓝色还有沉淀"
输出: {"intent":"experiment_result","data":{"observation":"溶液变为蓝色，出现沉淀"}}

输入: "实验失败"
输出: {"intent":"experiment_failed","data":{}}

输入: "实验结束"
输出: {"intent":"experiment_end","data":{}}

输入: "今天天气不错"
输出: {"intent":"none","data":{}}

规则（严格遵守）:
1. 只输出 JSON，不要任何其他文字、解释、标点、换行
2. 口语数字转阿拉伯数字（五→5、十→10、二十→20）
3. 规范化口语表达（"变成了蓝色"→"变为蓝色"，"还有"→"，"等）
4. 材料用量是可选的——用户没说就不要编造 data.materials 或 data.conditions
5. 对于 add_step 不要改动实验参数数值，只规范格式"""


# ── 实验数据结构 ──
@dataclass
class Experiment:
    name: str = ""                             # 实验名称，前端指定
    purpose: str = ""
    materials: str = ""
    conditions: str = ""
    steps: list = field(default_factory=list)
    observation: str = ""
    start_time: float = field(default_factory=time.time)
    raw_texts: list = field(default_factory=list)  # 累积所有ASR原始输入

    @property
    def step_count(self) -> int:
        return len(self.steps)

    @property
    def has_basic_info(self) -> bool:
        return bool(self.purpose or self.materials or self.conditions)

    def summary(self) -> str:
        t = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(self.start_time))
        lines = [
            "",
            "=" * 45,
            "         实验记录汇总",
            "=" * 45,
            f"开始时间: {t}",
        ]
        if self.purpose:
            lines.append(f"实验目的: {self.purpose}")
        if self.materials:
            lines.append(f"耗材用量: {self.materials}")
        if self.conditions:
            lines.append(f"环境条件: {self.conditions}")
        lines.append(f"实验步骤 ({self.step_count}步):")
        for i, s in enumerate(self.steps, 1):
            lines.append(f"  {i}. {s}")
        lines.append(f"实验现象: {self.observation or '(未记录)'}")
        lines.append("=" * 45)
        return "\n".join(lines)

    def print_basic_info(self):
        """打印基本信息（实验开始时调用）"""
        print(f"  实验目的: {self.purpose or '(未说明)'}")
        if self.materials:
            print(f"  耗材用量: {self.materials}")
        if self.conditions:
            print(f"  环境条件: {self.conditions}")


# ── 讯飞语音听写 ──
def _iflytek_recognize(raw_data: bytes) -> str:
    host, path = "iat-api.xfyun.cn", "/v2/iat"

    now = datetime.now(timezone.utc)
    date = now.strftime("%a, %d %b %Y %H:%M:%S") + " GMT"

    sign_str = f"host: {host}\ndate: {date}\nGET {path} HTTP/1.1"
    sig = base64.b64encode(
        hmac.new(IFLYTEK["apisecret"].encode(), sign_str.encode(), hashlib.sha256).digest()
    ).decode()

    auth_raw = (
        f'api_key="{IFLYTEK["apikey"]}",'
        f' algorithm="hmac-sha256",'
        f' headers="host date request-line",'
        f' signature="{sig}"'
    )
    auth = base64.b64encode(auth_raw.encode()).decode()
    ws_url = f"wss://{host}{path}?" + urllib.parse.urlencode(
        {"authorization": auth, "date": date, "host": host}
    )

    result_parts = []
    error = None
    ws_ready = threading.Event()
    ws_error = threading.Event()

    def on_open(ws):
        ws_ready.set()

    def on_message(ws, msg):
        nonlocal error
        m = json.loads(msg)
        if m.get("code", 0) != 0:
            error = m.get("message", f"code={m['code']}")
            return
        for item in m.get("data", {}).get("result", {}).get("ws", []):
            for cw in item.get("cw", []):
                result_parts.append(cw.get("w", ""))

    def on_error(ws, e):
        nonlocal error
        error = str(e) if not isinstance(e, str) else e
        ws_error.set()

    def on_close(ws, status, msg):
        if not ws_ready.is_set():
            ws_ready.set()

    ws = websocket.WebSocketApp(
        ws_url, on_open=on_open, on_message=on_message,
        on_error=on_error, on_close=on_close,
    )
    t = threading.Thread(
        target=lambda: ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE}), daemon=True,
    )
    t.start()

    if not ws_ready.wait(timeout=5):
        ws.close(); t.join(timeout=1)
        raise sr.RequestError("WebSocket 握手超时")
    if error:
        ws.close(); t.join(timeout=2)
        raise sr.RequestError(f"讯飞: {error}")

    chunk_size = 1280
    first = True
    for i in range(0, len(raw_data), chunk_size):
        chunk = raw_data[i:i + chunk_size]
        status = 0 if first else 1
        first = False
        frame = {
            "data": {
                "status": status, "format": "audio/L16;rate=16000",
                "encoding": "raw", "audio": base64.b64encode(chunk).decode(),
            },
        }
        if status == 0:
            frame["common"] = {"app_id": IFLYTEK["appid"]}
            frame["business"] = {"language": "zh_cn", "domain": "iat", "accent": "mandarin", "ptt": 0}
        try:
            ws.send(json.dumps(frame))
        except Exception as e:
            ws.close(); t.join(timeout=1)
            raise sr.RequestError(f"发送失败: {e}")
        time.sleep(0.04)

    try:
        ws.send(json.dumps({"data": {"status": 2}}))
    except Exception as e:
        ws.close(); t.join(timeout=1)
        raise sr.RequestError(f"发送结束帧失败: {e}")

    deadline = time.time() + 8
    while time.time() < deadline and not ws_error.is_set() and not result_parts and not error:
        time.sleep(0.1)

    ws.close(); t.join(timeout=2)
    if error:
        raise sr.RequestError(f"讯飞: {error}")
    if not result_parts:
        raise sr.UnknownValueError("未识别到内容")
    return "".join(result_parts)


def listen_and_recognize(recognizer: sr.Recognizer, source) -> str:
    audio = recognizer.listen(source, timeout=1, phrase_time_limit=30)
    raw = audio.get_raw_data(convert_rate=16000, convert_width=2)
    return _iflytek_recognize(raw)


# ── DeepSeek 意图分类 + 结构化提取 ──
def classify(text: str) -> dict:
    """返回 {"intent": "...", "data": {...}}"""
    resp = requests.post(
        DEEPSEEK["base_url"],
        headers={
            "Authorization": f"Bearer {DEEPSEEK['api_key']}",
            "Content-Type": "application/json",
        },
        json={
            "model": DEEPSEEK["model"],
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": text},
            ],
            "temperature": 0,
            "max_tokens": 80,
        },
        timeout=10,
    )
    resp.raise_for_status()
    raw = resp.json()["choices"][0]["message"]["content"].strip()
    # DeepSeek 偶尔会在 JSON 前后加 markdown 代码块标记，去除之
    raw = raw.removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    return json.loads(raw)


# ── DeepSeek 结构化JSON生成 ──
# prompt 由后端提供，定义了实验记录结构化抽取的格式要求
STRUCTURE_PROMPT = """请从用户的实验记录文本中提取相关字段信息，并输出结构化表格的 JSON 文本。

要求：

1. 必须只输出合法 JSON，不要输出 Markdown，不要添加解释性文字。
2. JSON 字段名必须严格使用结构化表格字段定义中的字段名。
3. 如果某个字段在实验记录文本中没有明确出现，请使用合理的空值：
   - `参数`：使用空对象 `{}`。
   - `耗材`：使用空数组 `[]`。
   - `实验报告`：使用空字符串 `""`。
   - `dt`：如果文本中没有明确时间，使用空字符串 `""`。
4. `参数` 字段必须是 JSON object，可以存储多个实验参数，包括实验编号、实验类型、研究主题、温度、湿度、pH、压力、转速、任务类型、刺激方式、刺激频率、刺激时长、主要指标、伴随指标等。该字段可拓展，不同实验记录中的参数 key 和字典大小可以不一样。
5. `耗材` 字段必须是数组，每个元素为三元数组：`[耗材名称, 耗材用量, 用量单位]`。
6. `实验报告` 应整理为对原始实验记录的忠实复述，保留实验过程、实验条件、实验操作、观察结果、数据记录和异常情况等信息，不要编造不存在的信息。
7. `现象结论` 不要求原文直接给出。请你根据用户实验记录中的实验现象、观察结果、数据变化和报告内容，自主总结一段现象结论。结论应简洁、准确、可用于后续 RAG 检索和新 idea 生成。
8. 如果实验记录中没有足够信息支撑明确结论，`现象结论` 应写成谨慎的观察性总结，不要过度推断。
9. `dt` 字段建议输出 ISO 8601 格式，例如 `2026-05-25T14:30:00`；如果原文只有日期，则保留日期信息。

以下是结构化表格的字段定义：

| 字段名 | 类型 | 是否必填 | 说明 |
| --- | --- | --- | --- |
| 参数 | `dict` | 否 | 实验参数字典，可存储湿度、温度、压力、pH、转速、时间窗口等参数。该字段可拓展，不同实验记录中的字典 key 和字典大小可以不一样。 |
| 耗材 | `List[tuple(str, float, str)]` | 否 | 实验耗材列表。每个元素为三元组：`(耗材名称, 耗材用量, 用量单位)`。 |
| 实验报告 | `str` | 否 | 实验过程、实验设置、观察记录、数据记录、异常情况等长文本内容。 |
| 现象结论 | `str` | 否 | 对实验现象的总结、结论或关键发现。该字段为长文本，可用于后续 RAG 检索和新 idea 生成。 |
| dt | `datetime` | 是 | 实验记录时间。建议使用 ISO 8601 格式保存，例如 `2026-05-25T14:30:00`。 |

参考输出示例：

```json
{
  "参数": {
    "实验编号": "H002",
    "实验类型": "预实验",
    "研究主题": "低频协同刺激参数探索",
    "任务类型": "持续注意任务",
    "刺激方式": "视听觉协同刺激",
    "刺激频率": "3 Hz",
    "刺激时长": "20 min",
    "主要指标": [
      "任务正确率",
      "反应时间"
    ],
    "伴随指标": [
      "主观疲劳评分"
    ]
  },
  "耗材": [
    ["脑电电极贴片", 1, "套"],
    ["酒精棉片", 2, "片"]
  ],
  "实验报告": "本次实验为刺激参数探索阶段的预实验，采用3 Hz视听觉协同刺激。实验过程中记录被试任务完成状态及实验后主观疲劳反馈。结果显示，任务正确率和反应时间没有出现稳定改善，但部分被试反馈实验结束后的疲劳感有所下降。由于主要行为指标未出现明显变化，本次结果最初未进入重点分析范围。",
  "现象结论": "在3 Hz协同刺激预实验中，主要行为指标未出现明显改善，但主观疲劳评分出现下降趋势，提示预实验中的伴随状态变化可能值得继续追踪。",
  "dt": "2026-05-12T14:30:00"
}
```

请根据用户实验记录文本输出一个 JSON object，字段必须为：

```json
{
  "参数": {},
  "耗材": [],
  "实验报告": "",
  "现象结论": "",
  "dt": ""
}
```"""


def generate_experiment_json(exp: Experiment) -> dict:
    """用 DeepSeek 将实验原始语音输入整理为目标JSON结构"""
    raw_text = "\n".join(f"{i}. {t}" for i, t in enumerate(exp.raw_texts, 1))
    dt_iso = time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(exp.start_time))

    user_input = f"""以下是用户的实验记录文本：

```text
实验时间: {dt_iso}
{raw_text if raw_text else '(无)'}
```"""

    resp = requests.post(
        DEEPSEEK["base_url"],
        headers={
            "Authorization": f"Bearer {DEEPSEEK['api_key']}",
            "Content-Type": "application/json",
        },
        json={
            "model": DEEPSEEK["model"],
            "messages": [
                {"role": "system", "content": STRUCTURE_PROMPT},
                {"role": "user", "content": user_input},
            ],
            "temperature": 0.1,
            "max_tokens": 2048,
        },
        timeout=30,
    )
    resp.raise_for_status()
    raw = resp.json()["choices"][0]["message"]["content"].strip()
    raw = raw.removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    result = json.loads(raw)
    # 注入实验名称（int id 由 handle_experiment_end 在保存时分配）
    result["实验名称"] = exp.name or exp.purpose
    return result


# ── RAG 创意生成 ──
def generate_idea_from_record(record: dict) -> dict | None:
    """根据单条实验记录的「现象结论」，通过 RAG 检索相关历史现象并生成新的科研创意。

    运行流程：
    1. 从 record 中提取 现象结论 字段
    2. 调用 rag_idea_generator.main() → 向量检索历史现象 + DeepSeek 生成创意
    3. 将 {id, new_idea} 追加写入 idea_data.json

    参数:
        record: 实验记录字典（与 record.json 中的单条记录格式一致）

    返回:
        成功时返回 rag_main() 的完整结果 dict，包含 new_idea_title / new_idea / generated 等字段
        现象结论为空时返回 None
    """
    new_phen = (record.get("现象结论") or "").strip()
    if not new_phen:
        print("  [RAG] 现象结论为空，跳过创意生成")
        return None

    result = rag_main(new_phen)

    if not result.get("generated"):
        print(f"  [RAG] 未生成创意（chroma_was_empty={result.get('chroma_was_empty')}）")
        return result

    idea_path = Path(__file__).parent / "idea_data.json"
    idea_data: list = []
    if idea_path.exists():
        try:
            with idea_path.open("r", encoding="utf-8") as f:
                idea_data = json.load(f)
            if not isinstance(idea_data, list):
                idea_data = [idea_data]
        except (json.JSONDecodeError, Exception):
            idea_data = []

    idea_data.append({
        "id": record.get("id"),
        "new_idea_title": result.get("new_idea_title", ""),
        "new_idea": result.get("new_idea", ""),
    })

    with idea_path.open("w", encoding="utf-8") as f:
        json.dump(idea_data, f, ensure_ascii=False, indent=2)

    print(f"  [RAG] 创意已追加至 idea_data.json (id={record.get('id')}, 共{len(idea_data)}条)")
    return result


# ── 状态机 ──
class ExperimentRecorder:
    def __init__(self):
        self.exp: Experiment | None = None
        self.state = "idle"  # idle | collecting_info | in_progress

    # ── 意图处理 ──

    def handle_start_experiment(self, data: dict):
        purpose = data.get("purpose", "")
        materials = data.get("materials", "")
        conditions = data.get("conditions", "")

        if self.state == "idle":
            self.exp = Experiment(
                purpose=purpose, materials=materials, conditions=conditions,
            )
            self.state = "collecting_info"
        elif self.state == "collecting_info":
            if purpose:
                self.exp.purpose += "；" + purpose
            if materials:
                self.exp.materials = (self.exp.materials + "、" + materials) if self.exp.materials else materials
            if conditions:
                self.exp.conditions = (self.exp.conditions + "、" + conditions) if self.exp.conditions else conditions
        elif self.state == "in_progress":
            self.exp = Experiment(
                purpose=purpose, materials=materials, conditions=conditions,
            )
            self.state = "collecting_info"

        parts = [self.exp.purpose]
        if self.exp.materials:
            parts.append(self.exp.materials)
        if self.exp.conditions:
            parts.append(self.exp.conditions)
        print(f"  [开始] {' | '.join(parts)}")

    def handle_add_step(self, data: dict):
        step = data.get("step", "")
        if not step:
            return
        if self.state == "idle":
            print(f"  尚未开始实验，忽略: {step}")
            return
        if self.state == "collecting_info":
            self.state = "in_progress"
        self.exp.steps.append(step)
        print(f"  [步骤{self.exp.step_count}] {step}")

    def handle_experiment_result(self, data: dict):
        obs = data.get("observation", "")
        if not self.exp:
            print(f"  尚未开始实验，忽略")
            return
        self.exp.observation = obs
        print(f"  [现象] {obs}")

    def handle_experiment_failed(self, _data: dict):
        if not self.exp:
            print(f"  没有进行中的实验")
            return
        print(f"  [失败] 实验已丢弃")
        self.exp = None
        self.state = "idle"

    def handle_experiment_end(self, _data: dict):
        if not self.exp:
            print(f"  没有进行中的实验")
            return
        if not self.exp.observation:
            print(f"  [提示] 请先汇报实验现象再结束")
            return

        # 1. 终端打印简要汇总
        print(self.exp.summary())
        print()

        # 2. 用大模型将原始语音输入整理为目标JSON结构
        print("  [整理] 正在用大模型整理实验数据...")
        try:
            record = generate_experiment_json(self.exp)
        except Exception as e:
            print(f"  [整理] 大模型调用失败: {e}")
            # fallback: 用已有结构化字段构造一条记录
            record = {
                "实验名称": self.exp.name or self.exp.purpose,
                "参数": {},
                "耗材": [],
                "实验报告": self.exp.summary(),
                "现象结论": self.exp.observation,
                "dt": time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(self.exp.start_time)),
            }

        # 3. 追加到本地实验词典文件（所有实验统一存储，自动分配 int id）
        filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "record.json")

        existing = []
        if os.path.exists(filepath):
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    existing = json.load(f)
                if not isinstance(existing, list):
                    existing = [existing]
            except (json.JSONDecodeError, Exception):
                existing = []

        # 自动分配 int id
        max_id = max((r.get("id", 0) for r in existing if isinstance(r.get("id"), int)), default=0)
        record["id"] = max_id + 1

        existing.append(record)
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(existing, f, ensure_ascii=False, indent=2)
        print(f"  [保存] 实验记录已追加至: {filepath} (id={record['id']}, 共{len(existing)}条)")

        # 4. 基于现象结论调用 RAG 生成科研创意
        generate_idea_from_record(record)

        self.exp = None
        self.state = "idle"

    # ── 统一入口 ──
    def dispatch(self, intent: str, data: dict):
        if intent == "start_experiment":
            self.handle_start_experiment(data)
        elif intent == "add_step":
            self.handle_add_step(data)
        elif intent == "experiment_result":
            self.handle_experiment_result(data)
        elif intent == "experiment_failed":
            self.handle_experiment_failed(data)
        elif intent == "experiment_end":
            self.handle_experiment_end(data)
        elif intent != "none":
            print(f"  [未知意图: {intent}]")


# ── 主循环 ──
def main():
    r = sr.Recognizer()
    r.dynamic_energy_threshold = True

    print("=" * 45)
    print("  实验室语音助手")
    print("  讯飞 ASR + DeepSeek 意图识别+结构化")
    print("=" * 45)

    with sr.Microphone() as source:
        r.adjust_for_ambient_noise(source, duration=2)
        print(f"麦克风校准完成, threshold={r.energy_threshold:.0f}")
        print("支持指令: 实验开始 | 加入/添加/改为... | 观察到/现象... | 实验失败 | 实验结束\n")

        recorder = ExperimentRecorder()

        while True:
            print("请说话... (Ctrl+C 退出)")
            try:
                text = listen_and_recognize(r, source)
            except sr.WaitTimeoutError:
                continue
            except sr.UnknownValueError:
                print("  ✗ 未听清\n")
                continue
            except sr.RequestError as e:
                print(f"  ✗ ASR错误: {e}\n")
                continue

            text = text.strip()
            if not text:
                continue
            print(f"  ASR: {text}")

            try:
                result = classify(text)
            except Exception as e:
                print(f"  ✗ DeepSeek错误: {e}\n")
                continue

            intent = result.get("intent", "none")
            data = result.get("data", {})
            print(f"  DeepSeek → {intent}")

            # 将原始语音输入累积到当前实验中（用于实验结束后生成结构化JSON）
            if recorder.exp is not None and intent != "none":
                recorder.exp.raw_texts.append(text)

            recorder.dispatch(intent, data)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n已退出。")
