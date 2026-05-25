import '../models/experiment.dart';

class LabWorkflowService {
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
