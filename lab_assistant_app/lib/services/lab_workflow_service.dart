import '../models/experiment.dart';

class LabWorkflowService {
  List<LabProject> createDemoProjects() {
    final eegV1 = _historyExperiment(
      id: 'exp-eeg-v1',
      title: 'H001 高负荷认知任务协同刺激',
      goal: '高负荷认知任务下的协同刺激效果评估',
      domain: '神经调控 / 脑电',
      resultLabel: '基线',
      transcriptTexts: const [
        '实施 5 Hz 视听觉协同刺激 20 min。',
        '记录主观疲劳评分、任务表现和右侧额顶网络功能连接。',
      ],
      evidencePrefix: 'eeg-v1',
    ).copyWith(experimentType: '正式实验');
    final eegV2 = _historyExperiment(
      id: 'exp-eeg-v2',
      title: 'H002 低频协同刺激参数探索',
      goal: '低频协同刺激参数探索',
      domain: '神经调控 / 脑电',
      resultLabel: '部分',
      transcriptTexts: const [
        '采用 3 Hz 视听觉协同刺激 20 min。',
        '任务正确率和反应时间未稳定改善，主观疲劳评分有下降趋势。',
      ],
      evidencePrefix: 'eeg-v2',
    ).copyWith(experimentType: '预实验');
    final eegV3 = _historyExperiment(
      id: 'exp-eeg-v3',
      title: 'H003 脑电节律变化探索',
      goal: '协同刺激后的脑电节律变化探索',
      domain: '神经调控 / 脑电',
      resultLabel: '部分',
      transcriptTexts: const [
        '观察 5 Hz 视听觉协同刺激后额中线 theta 功率。',
        'theta 功率增强，任务正确率仅轻微变化。',
      ],
      evidencePrefix: 'eeg-v3',
    ).copyWith(experimentType: '预实验');
    final eegV4 = _historyExperiment(
      id: 'exp-eeg-v4',
      title: 'H004 额顶网络连接分析',
      goal: '额顶网络连接与疲劳状态变化分析',
      domain: '神经调控 / 脑电',
      resultLabel: '关联',
      transcriptTexts: const [
        '比较 5 Hz 协同刺激前后的右侧额顶网络连接和主观疲劳评分。',
        '网络连接增强与疲劳评分下降同时出现。',
      ],
      evidencePrefix: 'eeg-v4',
    ).copyWith(experimentType: '探索性分析实验');
    final eegV5 = _historyExperiment(
      id: 'exp-eeg-v5',
      title: 'H005 连续刺激顺序分析',
      goal: '连续刺激条件下行为与神经指标变化顺序分析',
      domain: '神经调控 / 脑电',
      resultLabel: '优化',
      transcriptTexts: const [
        '连续进行三次 5 Hz 视听觉协同刺激。',
        'theta 功率和右侧额顶网络连接先于任务正确率改善出现。',
      ],
      evidencePrefix: 'eeg-v5',
    ).copyWith(experimentType: '重复干预实验');
    final eegControl = _historyExperiment(
      id: 'exp-eeg-h006',
      title: 'H006 Sham 假刺激对照',
      goal: '假刺激条件下行为与神经指标变化',
      domain: '神经调控 / 脑电',
      resultLabel: '对照',
      transcriptTexts: const [
        '设置 Sham 假刺激条件，流程与有效刺激一致。',
        '任务正确率、疲劳评分、theta 功率和右侧额顶网络连接均未稳定变化。',
      ],
      evidencePrefix: 'eeg-h006',
    ).copyWith(experimentType: '对照实验');

    final eegReports = _createImportedEegReports();
    const eegV3Idea = GeneratedIdea(
      id: 'eeg-v3',
      title: 'theta前置线索',
      body:
          '当前报告中的 theta 功率增强，与历史现象中疲劳评分下降和右侧额顶网络连接增强形成相似信号。可探索假设是神经节律变化可能先于行为改善出现；下一步可同步记录 theta 功率、额顶网络连接和任务正确率，验证神经指标是否能作为刺激参数优化的早期判据。',
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
        updatedAt: '2026-05-19 16:00',
        defaultNodeId: 'eeg-v5',
        historyNodes: [
          ExperimentHistoryNode(
            id: 'eeg-v1',
            parentId: null,
            experiment: eegV1,
            title: 'H001 协同刺激效果评估',
            summary: '5 Hz 协同刺激后额顶网络连接增强，疲劳状态改善',
            timestamp: '5/10 10:00',
            resultLabel: '基线',
            versionNumber: 1,
            report: eegReports['H001'],
            transcript: eegV1.transcript,
            evidence: eegV1.evidence,
          ),
          ExperimentHistoryNode(
            id: 'eeg-v2',
            parentId: 'eeg-v1',
            experiment: eegV2,
            title: 'H002 低频参数探索',
            summary: '3 Hz 条件下行为指标不明显，主观疲劳评分下降',
            timestamp: '5/12 14:30',
            resultLabel: '部分',
            versionNumber: 2,
            report: eegReports['H002'],
            transcript: eegV2.transcript,
            evidence: eegV2.evidence,
          ),
          ExperimentHistoryNode(
            id: 'eeg-v3',
            parentId: 'eeg-v2',
            experiment: eegV3,
            title: 'H003 脑电节律探索',
            summary: '5 Hz 后 theta 功率增强，行为改善尚不明确',
            timestamp: '5/14 09:40',
            resultLabel: '部分',
            versionNumber: 3,
            report: eegReports['H003'],
            transcript: eegV3.transcript,
            evidence: eegV3.evidence,
            idea: eegV3Idea,
          ),
          ExperimentHistoryNode(
            id: 'eeg-v4',
            parentId: 'eeg-v3',
            experiment: eegV4,
            title: 'H004 网络连接分析',
            summary: '右侧额顶网络连接增强与疲劳评分下降同时出现',
            timestamp: '5/16 15:20',
            resultLabel: '关联',
            versionNumber: 4,
            report: eegReports['H004'],
            transcript: eegV4.transcript,
            evidence: eegV4.evidence,
          ),
          ExperimentHistoryNode(
            id: 'eeg-v5',
            parentId: 'eeg-v4',
            experiment: eegV5,
            title: 'H005 连续刺激分析',
            summary: '神经指标变化先于明显行为改善出现',
            timestamp: '5/18 11:10',
            resultLabel: '优化',
            versionNumber: 5,
            report: eegReports['H005'],
            transcript: eegV5.transcript,
            evidence: eegV5.evidence,
          ),
          ExperimentHistoryNode(
            id: 'eeg-h006',
            parentId: 'eeg-v1',
            experiment: eegControl,
            title: 'H006 Sham 对照分支',
            summary: '假刺激条件下未观察到稳定联合变化',
            timestamp: '5/19 16:00',
            resultLabel: '对照',
            versionNumber: 6,
            report: eegReports['H006'],
            transcript: eegControl.transcript,
            evidence: eegControl.evidence,
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
            versionNumber: 1,
            transcript: materialV1.transcript,
            evidence: materialV1.evidence,
          ),
          ExperimentHistoryNode(
            id: 'material-v2',
            parentId: 'material-v1',
            experiment: materialV2,
            title: 'v2 溶剂比例',
            summary: '固定温度后比较溶剂比例',
            timestamp: '昨天 18:35',
            resultLabel: '优化',
            versionNumber: 2,
            transcript: materialV2.transcript,
            evidence: materialV2.evidence,
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

  Map<String, StructuredReport> _createImportedEegReports() {
    Evidence materialEvidence(String id, String detail, String timestamp) {
      return Evidence(
        id: '$id-materials',
        type: EvidenceType.transcript,
        title: '实验耗材',
        detail: detail,
        timestamp: timestamp,
        source: 'data.txt',
      );
    }

    return {
      'H001': StructuredReport(
        title: 'H001 高负荷认知任务下的协同刺激效果评估',
        body:
            '一、实验概况\n本次正式实验在高负荷认知任务中实施 5 Hz 视听觉协同刺激，刺激时长 20 min，重点观察主观疲劳评分、任务行为表现和右侧额顶网络功能连接。\n\n二、主要结果\n刺激后右侧额顶网络功能连接出现增强趋势，被试在任务持续阶段表现出更好的疲劳耐受状态。\n\n三、结论\n5 Hz视听觉协同刺激后，右侧额顶网络功能连接增强，并伴随认知疲劳状态改善。该记录可作为后续预实验分析和关联匹配的基础。',
        purpose: '高负荷认知任务下的协同刺激效果评估',
        experimentType: '正式实验',
        plannedConditions: const [
          '任务类型：高负荷认知任务',
          '刺激方式：视听觉协同刺激',
          '刺激频率：5 Hz；刺激时长：20 min',
          '观测指标：主观疲劳评分、任务行为表现、右侧额顶网络功能连接',
        ],
        actualOperations: const [
          '实施 5 Hz 视听觉协同刺激 20 min',
          '记录刺激前后的疲劳状态、任务表现和脑网络连接变化',
        ],
        conditionChanges: const ['作为基础正式实验记录，用于后续预实验比较'],
        processObservations: const ['刺激后右侧额顶网络功能连接出现增强趋势', '被试任务持续阶段疲劳耐受状态改善'],
        resultMetrics: const ['右侧额顶网络功能连接增强', '主观疲劳状态改善'],
        rawEvidence: [
          materialEvidence(
            'h001',
            '脑电电极贴片 1 套；导电膏 2 mL；酒精棉片 2 片',
            '2026-05-10 10:00',
          ),
        ],
        nextSuggestions: const ['用后续预实验验证 5 Hz 条件下神经指标与行为表现的关系'],
      ),
      'H002': StructuredReport(
        title: 'H002 低频协同刺激参数探索',
        body:
            '一、实验概况\n本次预实验采用 3 Hz 视听觉协同刺激，刺激时长 20 min，用持续注意任务评估低频刺激参数的可行性。\n\n二、主要结果\n任务正确率和反应时间没有出现稳定改善，但部分被试反馈实验后疲劳感下降。\n\n三、结论\n3 Hz 协同刺激对主要行为指标影响不明显，但主观疲劳评分有下降趋势，提示该伴随状态变化仍值得继续追踪。',
        purpose: '低频协同刺激参数探索',
        experimentType: '预实验',
        plannedConditions: const [
          '任务类型：持续注意任务',
          '刺激方式：视听觉协同刺激',
          '刺激频率：3 Hz；刺激时长：20 min',
          '主要指标：任务正确率、反应时间；伴随指标：主观疲劳评分',
        ],
        actualOperations: const [
          '实施 3 Hz 视听觉协同刺激 20 min',
          '记录任务完成状态和实验后主观疲劳反馈',
        ],
        conditionChanges: const ['相对 H001 将刺激频率从 5 Hz 降至 3 Hz'],
        processObservations: const ['行为指标未出现稳定改善', '部分被试主观疲劳感下降'],
        resultMetrics: const ['任务正确率无明显改善', '反应时间无稳定改善', '主观疲劳评分下降趋势'],
        rawEvidence: [
          materialEvidence('h002', '脑电电极贴片 1 套；酒精棉片 2 片', '2026-05-12 14:30'),
        ],
        nextSuggestions: const ['保留疲劳评分作为后续低频参数探索的伴随观察指标'],
      ),
      'H003': StructuredReport(
        title: 'H003 协同刺激后的脑电节律变化探索',
        body:
            '一、实验概况\n本次预实验观察 5 Hz 视听觉协同刺激后的脑电节律变化，重点分析额中线 theta 功率，并同步记录任务正确率和反应时间。\n\n二、主要结果\n刺激后额中线 theta 功率较基线增强，任务正确率仅有轻微变化，尚未形成明确行为改善。\n\n三、结论\n5 Hz 协同刺激后神经信号变化比行为改善更早出现，额中线 theta 功率可作为后续实验的早期评价指标。',
        purpose: '协同刺激后的脑电节律变化探索',
        experimentType: '预实验',
        plannedConditions: const [
          '任务类型：工作记忆任务',
          '刺激方式：视听觉协同刺激',
          '刺激频率：5 Hz；刺激时长：20 min',
          '脑电分析指标：额中线 theta 功率；行为指标：任务正确率、反应时间',
        ],
        actualOperations: const [
          '实施 5 Hz 视听觉协同刺激 20 min',
          '比较刺激后额中线 theta 功率和行为指标变化',
        ],
        conditionChanges: const ['从低频 3 Hz 参数探索回到 5 Hz 条件，并增加脑电节律分析'],
        processObservations: const ['额中线 theta 功率较基线增强', '任务正确率仅轻微变化'],
        resultMetrics: const ['额中线 theta 功率增强', '行为改善尚不明确'],
        rawEvidence: [
          materialEvidence(
            'h003',
            '脑电电极帽 1 套；导电膏 3 mL；一次性电极贴片 2 片',
            '2026-05-14 09:40',
          ),
        ],
        nextSuggestions: const ['将 theta 功率与额顶网络连接共同纳入后续分析'],
      ),
      'H004': StructuredReport(
        title: 'H004 额顶网络连接与疲劳状态变化分析',
        body:
            '一、实验概况\n本次探索性分析比较 5 Hz 协同刺激前后的右侧额顶网络功能连接和主观疲劳评分。\n\n二、主要结果\n刺激后右侧额顶网络连接强度增加，同时被试报告疲劳程度下降，结果方向与前序抗疲劳观察一致。\n\n三、结论\n右侧额顶网络功能连接增强与主观疲劳评分下降在同一次实验中同时出现，提示二者可能与认知疲劳缓解过程相关，但仍需重复实验验证。',
        purpose: '额顶网络连接与疲劳状态变化分析',
        experimentType: '探索性分析实验',
        plannedConditions: const [
          '任务类型：持续认知负荷任务',
          '刺激方式：视听觉协同刺激',
          '刺激频率：5 Hz；刺激时长：20 min',
          '观测指标：右侧额顶网络功能连接、主观疲劳评分',
        ],
        actualOperations: const ['比较刺激前后脑网络连接变化', '同步记录主观疲劳状态'],
        conditionChanges: const ['在 5 Hz 条件下加强额顶网络连接分析'],
        processObservations: const ['右侧额顶网络连接强度增加', '主观疲劳程度下降'],
        resultMetrics: const ['右侧额顶网络功能连接增强', '主观疲劳评分下降'],
        rawEvidence: [
          materialEvidence(
            'h004',
            '脑电电极帽 1 套；导电膏 3 mL；酒精棉片 2 片',
            '2026-05-16 15:20',
          ),
        ],
        nextSuggestions: const ['增加重复实验验证额顶网络连接与疲劳下降的稳定关联'],
      ),
      'H005': StructuredReport(
        title: 'H005 连续刺激条件下行为与神经指标变化顺序分析',
        body:
            '一、实验概况\n本实验连续进行三次 5 Hz 视听觉协同刺激，比较第一次和第三次刺激后的行为表现与神经指标变化。\n\n二、主要结果\n第一次刺激后，任务正确率尚未明显提升，但额中线 theta 功率和右侧额顶网络连接已有增强。第三次刺激后，任务正确率提高，主观疲劳评分下降。\n\n三、结论\ntheta 功率增强与右侧额顶网络连接增加先于明显行为改善出现，说明两项神经指标可能具有认知干预早期评价价值。',
        purpose: '连续刺激条件下行为与神经指标变化顺序分析',
        experimentType: '重复干预实验',
        plannedConditions: const [
          '任务类型：高负荷认知任务',
          '刺激方式：视听觉协同刺激',
          '刺激频率：5 Hz；单次刺激时长：20 min；连续干预 3 次',
          '测量时间点：第一次刺激后、第三次刺激后',
          '观测指标：任务正确率、主观疲劳评分、额中线 theta 功率、右侧额顶网络功能连接',
        ],
        actualOperations: const ['连续进行三次 5 Hz 视听觉协同刺激', '比较第一次和第三次刺激后的行为与神经指标'],
        conditionChanges: const ['从单次刺激观察扩展为连续三次干预'],
        processObservations: const ['第一次刺激后神经指标先增强', '第三次刺激后任务正确率提高且疲劳评分下降'],
        resultMetrics: const [
          'theta 功率增强',
          '右侧额顶网络连接增加',
          '任务正确率提高',
          '主观疲劳评分下降',
        ],
        rawEvidence: [
          materialEvidence(
            'h005',
            '脑电电极帽 1 套；导电膏 6 mL；酒精棉片 6 片',
            '2026-05-18 11:10',
          ),
        ],
        nextSuggestions: const ['继续验证神经指标是否能预测后续行为改善'],
      ),
      'H006': StructuredReport(
        title: 'H006 假刺激条件下行为与神经指标变化',
        body:
            '一、实验概况\n本次实验设置 Sham假刺激 对照条件，流程与有效刺激条件保持一致，观测任务正确率、主观疲劳评分、额中线 theta 功率和右侧额顶网络功能连接。\n\n二、主要结果\n假刺激条件下，各项行为与神经指标均未呈现稳定变化。\n\n三、结论\nSham假刺激 未观察到疲劳下降、theta 功率增强和右侧额顶网络连接增加的稳定联合变化，可作为有效刺激实验的对照记录。',
        purpose: '假刺激条件下行为与神经指标变化',
        experimentType: '对照实验',
        plannedConditions: const [
          '任务类型：高负荷认知任务',
          '刺激方式：Sham 假刺激；刺激时长：20 min',
          '观测指标：任务正确率、主观疲劳评分、额中线 theta 功率、右侧额顶网络功能连接',
        ],
        actualOperations: const ['执行 Sham 假刺激对照流程', '按有效刺激实验相同指标记录行为和神经变化'],
        conditionChanges: const ['将有效 5 Hz 协同刺激替换为 Sham 假刺激'],
        processObservations: const ['任务正确率未稳定变化', '疲劳评分、theta 功率和额顶网络连接均未稳定变化'],
        resultMetrics: const [
          '未观察到稳定疲劳下降',
          '未观察到 theta 功率增强',
          '未观察到右侧额顶网络连接增加',
        ],
        rawEvidence: [
          materialEvidence(
            'h006',
            '脑电电极帽 1 套；导电膏 3 mL；酒精棉片 2 片',
            '2026-05-19 16:00',
          ),
        ],
        nextSuggestions: const ['作为后续有效刺激关联分析的对照分支'],
      ),
    };
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
