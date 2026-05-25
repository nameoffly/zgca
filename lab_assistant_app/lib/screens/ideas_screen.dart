import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/section_card.dart';

class StructuredReportScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const StructuredReportScreen({super.key, this.onSaved});

  @override
  State<StructuredReportScreen> createState() => _StructuredReportScreenState();
}

class _StructuredReportScreenState extends State<StructuredReportScreen> {
  late final StructuredReport _reportSnapshot;
  late final ExperimentDiff _diffSnapshot;

  @override
  void initState() {
    super.initState();
    if (appState.report == null || appState.versionDiff == null) {
      appState.finishRecording();
    }
    _reportSnapshot = appState.report!;
    _diffSnapshot = appState.versionDiff!;
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

  @override
  Widget build(BuildContext context) {
    final report = _reportSnapshot;
    final diff = _diffSnapshot;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _ReportCard(report: report),
                  const SizedBox(height: 14),
                  _DiffCard(diff: diff),
                ],
              ),
            ),
          ),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            appState.archiveCurrentRecord();
            widget.onSaved?.call();
          },
          icon: const Icon(Icons.archive_outlined, size: 18),
          label: const Text(
            '保存并归档',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
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
              Icons.description_outlined,
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
                  '结构化报告',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '本次记录报告 · 版本对比',
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
          if (report.body.isNotEmpty) ...[
            Text(
              report.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.body,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
          ],
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
