import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/section_card.dart';

class ProjectHistoryScreen extends StatefulWidget {
  const ProjectHistoryScreen({super.key});

  @override
  State<ProjectHistoryScreen> createState() => _ProjectHistoryScreenState();
}

class _ProjectHistoryScreenState extends State<ProjectHistoryScreen> {
  String? _openedProjectId;

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

  void _openProject(LabProject project) {
    appState.selectProject(project.id);
    setState(() => _openedProjectId = project.id);
  }

  void _closeProject() {
    setState(() => _openedProjectId = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('project-history-screen'),
      child: _openedProjectId == null
          ? _ProjectList(onOpenProject: _openProject)
          : _ProjectHistoryDetail(onBack: _closeProject),
    );
  }
}

class _ProjectList extends StatelessWidget {
  final ValueChanged<LabProject> onOpenProject;

  const _ProjectList({required this.onOpenProject});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('project-list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ScreenHeader(
            icon: Icons.account_tree_outlined,
            title: '项目历史',
            subtitle: '按项目查看实验版本和报告',
          ),
          const SizedBox(height: 14),
          for (final project in appState.projects) ...[
            _ProjectCard(project: project, onTap: () => onOpenProject(project)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final LabProject project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final latest = project.historyNodes.firstWhere(
      (node) => node.id == project.defaultNodeId,
      orElse: () => project.historyNodes.last,
    );
    return Semantics(
      button: true,
      label: project.title,
      child: InkWell(
        key: ValueKey('project-card-${project.id}'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: SectionCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: const Icon(
                      Icons.folder_copy_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          project.domain,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.goal,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TagChip(
                    label: '${project.historyNodes.length} 个节点',
                    color: AppColors.primary,
                    bgColor: AppColors.primarySoft,
                  ),
                  const SizedBox(width: 8),
                  TagChip(
                    label: latest.resultLabel,
                    color: AppColors.success,
                    bgColor: AppColors.successBg,
                  ),
                  const Spacer(),
                  Text(
                    project.updatedAt,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectHistoryDetail extends StatelessWidget {
  final VoidCallback onBack;

  const _ProjectHistoryDetail({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final project = appState.selectedProject;
    final selectedNode = appState.selectedHistoryNode;
    final report = appState.selectedHistoryReport;
    final diff = appState.selectedHistoryDiff;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailHeader(project: project, onBack: onBack),
          const SizedBox(height: 14),
          _HistoryTree(project: project, selectedNode: selectedNode),
          const SizedBox(height: 14),
          _HistoryReportDetail(node: selectedNode, report: report, diff: diff),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final LabProject project;
  final VoidCallback onBack;

  const _DetailHeader({required this.project, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                project.domain,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryTree extends StatelessWidget {
  final LabProject project;
  final ExperimentHistoryNode selectedNode;

  const _HistoryTree({required this.project, required this.selectedNode});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      key: const ValueKey('history-tree'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.account_tree_outlined,
            title: '实验历史树',
          ),
          const SizedBox(height: 14),
          for (final node in project.historyNodes)
            _HistoryNodeTile(
              node: node,
              depth: _nodeDepth(project, node),
              selected: node.id == selectedNode.id,
              onTap: () => appState.selectHistoryNode(node.id),
            ),
        ],
      ),
    );
  }
}

class _HistoryNodeTile extends StatelessWidget {
  final ExperimentHistoryNode node;
  final int depth;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryNodeTile({
    required this.node,
    required this.depth,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textPrimary;
    return Padding(
      padding: EdgeInsets.only(left: depth * 18.0, bottom: 10),
      child: Semantics(
        button: true,
        selected: selected,
        label: node.title,
        child: InkWell(
          key: ValueKey('history-node-${node.id}'),
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: selected ? AppColors.primaryLight : AppColors.border,
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 42,
                  child: CustomPaint(
                    painter: _NodeMarkerPainter(
                      hasParent: node.parentId != null,
                      selected: selected,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              node.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TagChip(
                            label: node.resultLabel,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            bgColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        node.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        node.timestamp,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryReportDetail extends StatelessWidget {
  final ExperimentHistoryNode node;
  final StructuredReport report;
  final ExperimentDiff? diff;

  const _HistoryReportDetail({
    required this.node,
    required this.report,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      key: const ValueKey('history-report-detail'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle(
                icon: Icons.description_outlined,
                title: '节点实验报告',
              ),
              const Spacer(),
              TagChip(
                label: node.resultLabel,
                color: AppColors.success,
                bgColor: AppColors.successBg,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MiniLine(label: '节点', value: node.title),
          _MiniLine(label: '目的', value: report.purpose),
          _MiniLine(label: '类型', value: report.experimentType),
          _BulletGroup(
            title: '实际操作',
            items: report.actualOperations.take(3).toList(),
          ),
          _BulletGroup(title: '过程观察', items: report.processObservations),
          _BulletGroup(title: '结果指标', items: report.resultMetrics),
          if (diff != null)
            _BulletGroup(title: '相对上一节点', items: diff!.changedVariables),
          _BulletGroup(
            title: '原始证据',
            items: report.rawEvidence.map((e) => e.title).toList(),
          ),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ScreenHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

class _NodeMarkerPainter extends CustomPainter {
  final bool hasParent;
  final bool selected;

  const _NodeMarkerPainter({required this.hasParent, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.4;
    final center = Offset(size.width / 2, 15);

    if (hasParent) {
      canvas.drawLine(
        Offset(center.dx, 0),
        Offset(center.dx, size.height),
        linePaint,
      );
    } else {
      canvas.drawLine(
        Offset(center.dx, center.dy),
        Offset(center.dx, size.height),
        linePaint,
      );
    }

    final fillPaint = Paint()
      ..color = selected ? AppColors.primary : Colors.white;
    final strokePaint = Paint()
      ..color = selected ? AppColors.primary : AppColors.textTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, selected ? 6.5 : 5.5, fillPaint);
    canvas.drawCircle(center, selected ? 6.5 : 5.5, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _NodeMarkerPainter oldDelegate) {
    return hasParent != oldDelegate.hasParent ||
        selected != oldDelegate.selected;
  }
}

int _nodeDepth(LabProject project, ExperimentHistoryNode node) {
  var depth = 0;
  var parentId = node.parentId;
  final seen = <String>{node.id};

  while (parentId != null && !seen.contains(parentId)) {
    final parent = _findNode(project, parentId);
    if (parent == null) {
      break;
    }
    depth += 1;
    seen.add(parent.id);
    parentId = parent.parentId;
  }

  return depth;
}

ExperimentHistoryNode? _findNode(LabProject project, String id) {
  for (final node in project.historyNodes) {
    if (node.id == id) {
      return node;
    }
  }
  return null;
}
