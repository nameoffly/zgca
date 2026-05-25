import '../models/experiment.dart';

class LabWorkflowService {
  List<LabProject> createDemoProjects() {
    final eegV1 = _historyExperiment(
      id: 'exp-eeg-v1',
      title: 'EEG fatigue pilot v1',
      goal: '建立脑电疲劳评估的基础刺激流程',
      domain: '神经调控 / 脑电',
      resultLabel: '基线',
      transcriptTexts: const [
        '完成 6 Hz 基线刺激流程，记录疲劳评分和正确率。',
        '被试反馈任务负荷可接受，设备信号稳定。',
      ],
      evidencePrefix: 'eeg-v1',
    );
    final eegV2 = _historyExperiment(
      id: 'exp-eeg-v2',
      title: 'EEG fatigue pilot v2',
      goal: '验证延长刺激时长是否增强疲劳评分变化',
      domain: '神经调控 / 脑电',
      resultLabel: '部分',
      transcriptTexts: const ['保持 6 Hz，延长刺激时长并记录主观疲劳评分。', '疲劳评分略有下降，正确率变化不明显。'],
      evidencePrefix: 'eeg-v2',
    );
    final eegV3 = createPreviousDemoExperiment().copyWith(
      id: 'exp-eeg-v3',
      title: 'EEG fatigue pilot v3',
      goal: '验证刺激时长是否影响疲劳评分',
      domain: '神经调控 / 脑电',
      resultLabel: '部分',
    );
    final eegV4 = createCurrentDemoExperiment(
      title: 'EEG fatigue pilot v4',
      goal: '验证刺激频率变化是否影响疲劳评分',
      domain: '神经调控 / 脑电',
    ).copyWith(id: 'exp-eeg-v4');
    final eegControl = _historyExperiment(
      id: 'exp-eeg-control',
      title: 'EEG fatigue control repeat',
      goal: '重复 10 Hz 条件并加入 theta 功率记录',
      domain: '神经调控 / 脑电',
      resultLabel: '待验证',
      transcriptTexts: const [
        '保留 10 Hz 条件，增加 theta 功率和阻抗基线截图。',
        '作为 v4 的重复验证分支，等待更多被试数据。',
      ],
      evidencePrefix: 'eeg-control',
    );

    final materialV1 = _historyExperiment(
      id: 'exp-material-v1',
      title: 'polymer coating v1',
      goal: '筛选涂层固化温度的初始窗口',
      domain: '材料合成',
      resultLabel: '可行',
      transcriptTexts: const ['完成 60 到 90 摄氏度固化窗口筛选。', '80 摄氏度样品表面连续性最好。'],
      evidencePrefix: 'material-v1',
    );
    final materialV2 = _historyExperiment(
      id: 'exp-material-v2',
      title: 'polymer coating v2',
      goal: '在 80 摄氏度条件下比较溶剂比例',
      domain: '材料合成',
      resultLabel: '优化',
      transcriptTexts: const ['固定固化温度，调整溶剂比例。', '高挥发比例样品出现边缘收缩，需要降低旋涂速度。'],
      evidencePrefix: 'material-v2',
    );

    return [
      LabProject(
        id: 'proj-eeg',
        title: '脑电疲劳调控项目',
        domain: '神经调控 / 脑电',
        goal: '通过连续实验优化疲劳干预刺激条件',
        updatedAt: '今天 11:20',
        defaultNodeId: 'eeg-v4',
        historyNodes: [
          ExperimentHistoryNode(
            id: 'eeg-v1',
            parentId: null,
            experiment: eegV1,
            title: 'v1 基线流程',
            summary: '建立基础刺激和记录流程',
            timestamp: '5/20 09:30',
            resultLabel: '基线',
          ),
          ExperimentHistoryNode(
            id: 'eeg-v2',
            parentId: 'eeg-v1',
            experiment: eegV2,
            title: 'v2 延长时长',
            summary: '延长刺激时长，疲劳变化有限',
            timestamp: '5/21 15:40',
            resultLabel: '部分',
          ),
          ExperimentHistoryNode(
            id: 'eeg-v3',
            parentId: 'eeg-v2',
            experiment: eegV3,
            title: 'v3 时长验证',
            summary: '重复 6 Hz 条件并确认行为指标稳定',
            timestamp: '昨天 16:10',
            resultLabel: '部分',
          ),
          ExperimentHistoryNode(
            id: 'eeg-v4',
            parentId: 'eeg-v3',
            experiment: eegV4,
            title: 'v4 频率调整',
            summary: '切换到 10 Hz，疲劳评分下降更明显',
            timestamp: '今天 10:24',
            resultLabel: '部分',
          ),
          ExperimentHistoryNode(
            id: 'eeg-control',
            parentId: 'eeg-v4',
            experiment: eegControl,
            title: '重复验证分支',
            summary: '加入 theta 功率记录，准备重复验证',
            timestamp: '计划中',
            resultLabel: '待验证',
          ),
          ExperimentHistoryNode(
            id: 'eeg-alt',
            parentId: 'eeg-v2',
            experiment: _historyExperiment(
              id: 'exp-eeg-alt',
              title: 'EEG alpha band exploration',
              goal: '探索 alpha 频段刺激对注意力的影响',
              domain: '神经调控 / 脑电',
              resultLabel: '探索',
              transcriptTexts: const [
                '从 v2 分支出来，尝试 alpha 频段刺激。',
                '初步结果显示注意力指标有变化，需要更多数据。',
              ],
              evidencePrefix: 'eeg-alt',
            ),
            title: 'alpha 频段探索',
            summary: '从 v2 分支，探索 alpha 刺激对注意力的影响',
            timestamp: '5/22 14:00',
            resultLabel: '探索',
          ),
        ],
      ),
      LabProject(
        id: 'proj-material',
        title: '聚合物涂层优化项目',
        domain: '材料合成',
        goal: '通过条件迭代提升涂层连续性和稳定性',
        updatedAt: '昨天 18:35',
        defaultNodeId: 'material-v2',
        historyNodes: [
          ExperimentHistoryNode(
            id: 'material-v1',
            parentId: null,
            experiment: materialV1,
            title: 'v1 温度窗口',
            summary: '筛选固化温度并确定候选窗口',
            timestamp: '5/22 09:32',
            resultLabel: '可行',
          ),
          ExperimentHistoryNode(
            id: 'material-v2',
            parentId: 'material-v1',
            experiment: materialV2,
            title: 'v2 溶剂比例',
            summary: '固定温度后比较溶剂比例',
            timestamp: '昨天 18:35',
            resultLabel: '优化',
          ),
        ],
      ),
    ];
  }

  Experiment createCurrentDemoExperiment({
    String title = '脑电疲劳预实验 v4',
    String goal = '验证刺激频率变化是否影响疲劳评分',
    String domain = '神经调控 / 脑电',
  }) {
    return Experiment(
      id: 'exp-current',
      title: title,
      goal: goal,
      domain: domain,
      experimentType: '预实验',
      status: ExperimentStatus.draft,
      resultLabel: '部分',
      transcript: [
        TranscriptEntry(
          '00:00:04',
          '本轮刺激频率调整为 10 Hz，持续时间保持不变。',
          id: 'tr-1',
          evidenceIds: const ['ev-voice-1'],
        ),
        TranscriptEntry(
          '00:00:16',
          '这一组被试反馈疲劳感下降，但正确率变化不明显。',
          id: 'tr-2',
          flagged: true,
          evidenceIds: const ['ev-voice-1', 'ev-instrument-1'],
        ),
        TranscriptEntry(
          '00:00:31',
          '设备出现短暂信号波动，重新校准后继续测量。',
          id: 'tr-3',
          evidenceIds: const ['ev-voice-1', 'ev-image-1'],
        ),
      ],
      evidence: const [
        Evidence(
          id: 'ev-voice-1',
          type: EvidenceType.voice,
          title: '现场语音片段',
          detail: '包含刺激频率调整、疲劳反馈和设备波动描述。',
          timestamp: '00:00-00:38',
          source: '录音',
        ),
        Evidence(
          id: 'ev-image-1',
          type: EvidenceType.image,
          title: '电极阻抗截图',
          detail: '重新校准后阻抗恢复到可接受范围。',
          timestamp: '00:00:34',
          source: '拍照',
        ),
        Evidence(
          id: 'ev-instrument-1',
          type: EvidenceType.instrumentFile,
          title: 'EEG 指标文件',
          detail: '疲劳评分下降，准确率变化不明显，右侧额顶网络连接增强。',
          timestamp: '实验结束',
          source: '仪器导入',
        ),
        Evidence(
          id: 'ev-safety-1',
          type: EvidenceType.safetySource,
          title: '实验室 SOP',
          detail: '出现设备信号波动时需暂停、校准并记录异常时间点。',
          timestamp: '规则库',
          source: 'SOP-EEG-07',
        ),
      ],
    );
  }

  Experiment createPreviousDemoExperiment() {
    return Experiment(
      id: 'exp-previous',
      title: '脑电疲劳预实验 v3',
      goal: '验证刺激时长是否影响疲劳评分',
      domain: '神经调控 / 脑电',
      experimentType: '预实验',
      status: ExperimentStatus.completed,
      resultLabel: '部分',
      transcript: [
        TranscriptEntry('00:00:05', '刺激频率保持 6 Hz，延长刺激时长。'),
        TranscriptEntry('00:00:18', '疲劳感略有下降，正确率无明显变化。', flagged: true),
      ],
      evidence: const [
        Evidence(
          id: 'prev-ev-1',
          type: EvidenceType.instrumentFile,
          title: 'v3 指标文件',
          detail: '疲劳下降幅度低于 v4，行为正确率无明显变化。',
          timestamp: '上一轮',
          source: '仪器导入',
        ),
      ],
    );
  }

  Experiment _historyExperiment({
    required String id,
    required String title,
    required String goal,
    required String domain,
    required String resultLabel,
    required List<String> transcriptTexts,
    required String evidencePrefix,
  }) {
    return Experiment(
      id: id,
      title: title,
      goal: goal,
      domain: domain,
      experimentType: '迭代实验',
      status: ExperimentStatus.completed,
      resultLabel: resultLabel,
      transcript: [
        for (var i = 0; i < transcriptTexts.length; i++)
          TranscriptEntry(
            '00:00:${(i + 1) * 12}',
            transcriptTexts[i],
            id: '$evidencePrefix-tr-${i + 1}',
            flagged: i == transcriptTexts.length - 1,
            evidenceIds: ['$evidencePrefix-ev-${i + 1}'],
          ),
      ],
      evidence: [
        Evidence(
          id: '$evidencePrefix-ev-1',
          type: EvidenceType.transcript,
          title: '$title 过程记录',
          detail: transcriptTexts.join(' '),
          timestamp: '实验过程',
          source: '转写',
        ),
        Evidence(
          id: '$evidencePrefix-ev-2',
          type: EvidenceType.instrumentFile,
          title: '$title 指标文件',
          detail: '包含关键指标、异常标记和下一轮条件建议。',
          timestamp: '实验结束',
          source: '仪器导入',
        ),
      ],
    );
  }

  StructuredReport structureReport(Experiment experiment) {
    return StructuredReport(
      purpose: experiment.goal,
      experimentType: experiment.experimentType,
      plannedConditions: const ['保持刺激时长与任务设置不变', '仅调整刺激频率并记录疲劳评分、正确率和脑网络指标'],
      actualOperations: experiment.transcript
          .map((entry) => entry.text)
          .toList(),
      conditionChanges: const ['刺激频率 / 反应温度', '本轮将关键变量从上一版的 6 Hz 调整为 10 Hz'],
      processObservations: const ['疲劳感下降但主要行为指标变化不明显', '设备短暂信号波动已完成校准并保留证据'],
      resultMetrics: const ['疲劳评分下降', '正确率无明显变化', '右侧额顶网络连接增强'],
      rawEvidence: experiment.evidence,
      nextSuggestions: const [
        '下一轮同步记录 theta 功率与额顶网络连接',
        '增加一组 10 Hz 对照重复验证稳定性',
      ],
    );
  }

  ExperimentDiff compareVersions({
    required Experiment previous,
    required Experiment current,
  }) {
    return const ExperimentDiff(
      changedVariables: ['刺激频率 / 反应温度', 'v3: 6 Hz；v4: 10 Hz；其他任务条件保持不变'],
      resultDifferences: ['v4 疲劳评分下降更明显', '两轮实验的正确率均无显著变化'],
      repeatedSignals: ['疲劳下降在 v3 与 v4 中重复出现', '右侧额顶网络连接变化在 v4 中更清晰'],
      anomalyHints: ['v4 存在短暂设备信号波动，需在后续报告对比中标记'],
    );
  }

  List<ResearchInsight> generateInsights({
    required Experiment experiment,
    required StructuredReport report,
    required ExperimentDiff diff,
  }) {
    return const [
      ResearchInsight(
        id: 'insight-theta',
        title: '同步监测 theta 与额顶网络',
        summary: '疲劳下降与右侧额顶网络连接变化同时出现，适合作为下一轮待验证线索。',
        evidenceIds: ['ev-voice-1', 'ev-instrument-1'],
        uncertainty: '当前只有两轮预实验，缺少跨被试重复证据。',
        nextExperimentAction: '下一轮增加 theta 功率记录，并保持任务设置不变。',
        riskLabel: '中风险',
      ),
      ResearchInsight(
        id: 'insight-signal',
        title: '将设备波动纳入质量解释',
        summary: '设备短暂波动可能解释局部指标噪声，应作为报告对比维度保留。',
        evidenceIds: ['ev-image-1', 'ev-safety-1'],
        uncertainty: '尚不确定波动是否影响主要指标，需要重复测量确认。',
        nextExperimentAction: '开始前增加阻抗基线截图，并自动标记校准时间。',
        riskLabel: '低风险',
      ),
      ResearchInsight(
        id: 'insight-frequency',
        title: '保留 10 Hz 作为候选条件',
        summary: '与上一版相比，10 Hz 条件下疲劳下降更明显，但行为收益尚未出现。',
        evidenceIds: ['ev-voice-1', 'ev-instrument-1'],
        uncertainty: '行为指标不变，不能直接判断认知能力改善。',
        nextExperimentAction: '设计一组 10 Hz 重复验证，并加入更敏感的注意控制指标。',
        riskLabel: '低风险',
      ),
    ];
  }
}
