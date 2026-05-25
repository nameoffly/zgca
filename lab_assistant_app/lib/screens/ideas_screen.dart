import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/section_card.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  @override
  void initState() {
    super.initState();
    appState.addListener(_onState);
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    appState.removeListener(_onState);
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  StructuredReport get _report {
    if (appState.report == null) {
      appState.finishRecording();
    }
    return appState.report!;
  }

  ExperimentDiff get _diff {
    if (appState.versionDiff == null) {
      appState.finishRecording();
    }
    return appState.versionDiff!;
  }

  void _showInsight(ResearchInsight insight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _riskChip(insight.riskLabel),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight.summary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              _DetailBlock(title: '依据', value: insight.evidenceIds.join(' / ')),
              _DetailBlock(title: '不确定性', value: insight.uncertainty),
              _DetailBlock(title: '下一步', value: insight.nextExperimentAction),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: insight.adopted
                      ? null
                      : () {
                          appState.adoptInsight(insight.id);
                          Navigator.of(context).pop();
                          _toast('已加入下一轮实验计划');
                        },
                  icon: const Icon(Icons.add_task, size: 18),
                  label: Text(insight.adopted ? '已采纳' : '采纳'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final diff = _diff;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _ReportCard(report: report),
            const SizedBox(height: 14),
            _DiffCard(diff: diff),
            const SizedBox(height: 14),
            _InsightCard(
              insights: appState.insights,
              onOpen: _showInsight,
              onAdopt: (insight) {
                appState.adoptInsight(insight.id);
                _toast('已加入下一轮实验计划');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '整理与 Idea',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '报告 · 版本对比 · 探索线索',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              appState.exportReport();
              _toast('已导出报告 ${appState.exportedReportCount} 次');
            },
            icon: const Icon(
              Icons.upload_file_outlined,
              color: AppColors.textPrimary,
              size: 16,
            ),
            label: Text(
              appState.exportedReportCount > 0 ? '已导出' : '导出报告',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskChip(String label) {
    final high = label.contains('中');
    return TagChip(
      label: label,
      color: high ? AppColors.warning : AppColors.success,
      bgColor: high ? AppColors.warningBg : AppColors.successBg,
    );
  }
}

class _ReportCard extends StatelessWidget {
  final StructuredReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.description_outlined, title: '结构化报告'),
          const SizedBox(height: 12),
          _MiniLine(label: '目的', value: report.purpose),
          _MiniLine(label: '类型', value: report.experimentType),
          _BulletGroup(
            title: '实际操作',
            items: report.actualOperations.take(3).toList(),
          ),
          _BulletGroup(title: '过程观察', items: report.processObservations),
          _BulletGroup(
            title: '原始证据',
            items: report.rawEvidence.map((e) => e.title).toList(),
          ),
        ],
      ),
    );
  }
}

class _DiffCard extends StatelessWidget {
  final ExperimentDiff diff;

  const _DiffCard({required this.diff});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.compare_arrows, title: '版本对比'),
          const SizedBox(height: 12),
          _BulletGroup(title: '变量变化', items: diff.changedVariables),
          _BulletGroup(title: '结果差异', items: diff.resultDifferences),
          _BulletGroup(title: '重复信号', items: diff.repeatedSignals),
          _BulletGroup(title: '异常提示', items: diff.anomalyHints),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final List<ResearchInsight> insights;
  final ValueChanged<ResearchInsight> onOpen;
  final ValueChanged<ResearchInsight> onAdopt;

  const _InsightCard({
    required this.insights,
    required this.onOpen,
    required this.onAdopt,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.lightbulb_outline, title: '探索线索'),
          const SizedBox(height: 12),
          for (final insight in insights) ...[
            _InsightRow(
              insight: insight,
              onOpen: () => onOpen(insight),
              onAdopt: () => onAdopt(insight),
            ),
            if (insight != insights.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final ResearchInsight insight;
  final VoidCallback onOpen;
  final VoidCallback onAdopt;

  const _InsightRow({
    required this.insight,
    required this.onOpen,
    required this.onAdopt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              TagChip(
                label: insight.riskLabel,
                color: insight.riskLabel.contains('中')
                    ? AppColors.warning
                    : AppColors.success,
                bgColor: insight.riskLabel.contains('中')
                    ? AppColors.warningBg
                    : AppColors.successBg,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight.summary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                onTap: onOpen,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: TagChip(
                    label: '依据',
                    color: AppColors.primary,
                    bgColor: AppColors.primarySoft,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: insight.adopted ? null : onAdopt,
                child: Text(insight.adopted ? '已采纳' : '采纳'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String label;
  final String value;

  const _MiniLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletGroup extends StatelessWidget {
  final String title;
  final List<String> items;

  const _BulletGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String value;

  const _DetailBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
