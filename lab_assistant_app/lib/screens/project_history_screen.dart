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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: AppColors.bg,
          body: ExperimentDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('project-history-screen'),
      child: _ProjectList(onOpenProject: _openProject),
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
            title: '实验库',
            subtitle: '按完整实验查看记录树和报告',
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
                latest.summary,
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
                    label: '${project.records.length} 次记录',
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

class ExperimentDetailScreen extends StatefulWidget {
  const ExperimentDetailScreen({super.key});

  @override
  State<ExperimentDetailScreen> createState() => _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState extends State<ExperimentDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    final project = appState.selectedProject;
    final selectedNode = appState.selectedHistoryNode;
    final report = appState.selectedHistoryReport;
    final diff = appState.selectedHistoryDiff;
    final idea = appState.selectedHistoryIdea;
    return SafeArea(
      key: const ValueKey('experiment-detail-screen'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(project: project),
            const SizedBox(height: 14),
            _HistoryTree(project: project, selectedNode: selectedNode),
            const SizedBox(height: 14),
            _HistoryReportDetail(
              node: selectedNode,
              report: report,
              diff: diff,
              idea: idea,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final LabProject project;

  const _DetailHeader({required this.project});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
                '${project.domain} · ${project.records.length} 次记录',
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
    final treeData = _TreeGraphData.build(project.historyNodes);
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
          SingleChildScrollView(
            key: const ValueKey('history-tree-graph'),
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: treeData.totalWidth,
              height: treeData.totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(treeData.totalWidth, treeData.totalHeight),
                    painter: _TreeEdgePainter(treeData: treeData),
                  ),
                  for (final entry in treeData.positions.entries)
                    Positioned(
                      left: entry.value.dx - _TreeGraphData.nodeWidth / 2,
                      top: entry.value.dy - _TreeGraphData.nodeHeight / 2,
                      child: _TreeNodeCard(
                        key: ValueKey('history-node-${entry.key.id}'),
                        node: entry.key,
                        selected: entry.key.id == selectedNode.id,
                        onTap: () => appState.selectHistoryNode(entry.key.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeGraphData {
  static const double nodeWidth = 122;
  static const double nodeHeight = 72;
  static const double horizontalGap = 18;
  static const double verticalGap = 36;

  final Map<ExperimentHistoryNode, Offset> positions;
  final List<_TreeEdge> edges;
  final double totalWidth;
  final double totalHeight;

  const _TreeGraphData({
    required this.positions,
    required this.edges,
    required this.totalWidth,
    required this.totalHeight,
  });

  static _TreeGraphData build(List<ExperimentHistoryNode> nodes) {
    if (nodes.isEmpty) {
      return const _TreeGraphData(
        positions: {},
        edges: [],
        totalWidth: nodeWidth,
        totalHeight: nodeHeight,
      );
    }

    final childrenOf = <String, List<ExperimentHistoryNode>>{};
    final nodeById = <String, ExperimentHistoryNode>{};
    for (final node in nodes) {
      nodeById[node.id] = node;
      childrenOf.putIfAbsent(node.parentId ?? '__root__', () => []).add(node);
    }

    final nodeIds = nodeById.keys.toSet();
    final roots = nodes
        .where(
          (node) => node.parentId == null || !nodeIds.contains(node.parentId),
        )
        .toList();
    if (roots.isEmpty) {
      roots.add(nodes.first);
    }

    final depth = <String, int>{for (final root in roots) root.id: 0};
    final queue = <ExperimentHistoryNode>[...roots];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final child in childrenOf[current.id] ?? <ExperimentHistoryNode>[]) {
        if (depth.containsKey(child.id)) {
          continue;
        }
        depth[child.id] = depth[current.id]! + 1;
        queue.add(child);
      }
    }
    for (final node in nodes) {
      depth.putIfAbsent(node.id, () => 0);
    }

    final subtreeWidth = <String, double>{};
    final visiting = <String>{};

    double computeSubtreeWidth(ExperimentHistoryNode node) {
      if (subtreeWidth.containsKey(node.id)) {
        return subtreeWidth[node.id]!;
      }
      if (!visiting.add(node.id)) {
        return nodeWidth;
      }

      final children = childrenOf[node.id] ?? <ExperimentHistoryNode>[];
      if (children.isEmpty) {
        visiting.remove(node.id);
        subtreeWidth[node.id] = nodeWidth;
        return nodeWidth;
      }

      var width = 0.0;
      for (final child in children) {
        width += computeSubtreeWidth(child);
      }
      width += (children.length - 1) * horizontalGap;
      visiting.remove(node.id);
      subtreeWidth[node.id] = width;
      return width;
    }

    var totalRootsWidth = 0.0;
    for (final root in roots) {
      totalRootsWidth += computeSubtreeWidth(root);
    }
    totalRootsWidth += (roots.length - 1) * horizontalGap;

    final positions = <ExperimentHistoryNode, Offset>{};
    void positionSubtree(ExperimentHistoryNode node, double left, int level) {
      final width = subtreeWidth[node.id] ?? nodeWidth;
      final centerX = left + width / 2;
      final centerY = level * (nodeHeight + verticalGap) + nodeHeight / 2 + 8;
      positions[node] = Offset(centerX, centerY);

      var childLeft = left;
      for (final child in childrenOf[node.id] ?? <ExperimentHistoryNode>[]) {
        final childWidth = subtreeWidth[child.id] ?? nodeWidth;
        positionSubtree(child, childLeft, level + 1);
        childLeft += childWidth + horizontalGap;
      }
    }

    var rootLeft = 0.0;
    for (final root in roots) {
      positionSubtree(root, rootLeft, 0);
      rootLeft += (subtreeWidth[root.id] ?? nodeWidth) + horizontalGap;
    }

    final edges = <_TreeEdge>[];
    for (final node in nodes) {
      final parent = node.parentId == null ? null : nodeById[node.parentId];
      if (parent != null &&
          positions.containsKey(parent) &&
          positions.containsKey(node)) {
        edges.add(_TreeEdge(from: positions[parent]!, to: positions[node]!));
      }
    }

    final maxDepth = depth.values.fold(
      0,
      (max, value) => value > max ? value : max,
    );
    final totalWidth = totalRootsWidth < nodeWidth * 2
        ? nodeWidth * 2 + horizontalGap
        : totalRootsWidth;
    final totalHeight = (maxDepth + 1) * (nodeHeight + verticalGap) + 16;

    return _TreeGraphData(
      positions: positions,
      edges: edges,
      totalWidth: totalWidth,
      totalHeight: totalHeight,
    );
  }
}

class _TreeEdge {
  final Offset from;
  final Offset to;

  const _TreeEdge({required this.from, required this.to});
}

class _TreeEdgePainter extends CustomPainter {
  final _TreeGraphData treeData;

  const _TreeEdgePainter({required this.treeData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in treeData.edges) {
      final from = edge.from;
      final to = edge.to;
      final midY = (from.dy + to.dy) / 2;
      final path = Path()
        ..moveTo(from.dx, from.dy + _TreeGraphData.nodeHeight / 2)
        ..cubicTo(
          from.dx,
          midY,
          to.dx,
          midY,
          to.dx,
          to.dy - _TreeGraphData.nodeHeight / 2,
        );
      canvas.drawPath(path, paint);

      final arrowTip = Offset(to.dx, to.dy - _TreeGraphData.nodeHeight / 2);
      final arrowPath = Path()
        ..moveTo(arrowTip.dx, arrowTip.dy)
        ..lineTo(arrowTip.dx - 4, arrowTip.dy - 7)
        ..lineTo(arrowTip.dx + 4, arrowTip.dy - 7)
        ..close();
      canvas.drawPath(
        arrowPath,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreeEdgePainter oldDelegate) {
    return treeData != oldDelegate.treeData;
  }
}

class _TreeNodeCard extends StatelessWidget {
  final ExperimentHistoryNode node;
  final bool selected;
  final VoidCallback onTap;

  const _TreeNodeCard({
    super.key,
    required this.node,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: node.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          width: _TreeGraphData.nodeWidth,
          height: _TreeGraphData.nodeHeight,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (selected ? AppColors.primary : Colors.black).withValues(
                  alpha: selected ? 0.12 : 0.05,
                ),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${node.displayName} · ${node.resultLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                node.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                node.timestamp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ],
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
  final GeneratedIdea? idea;

  const _HistoryReportDetail({
    required this.node,
    required this.report,
    required this.diff,
    required this.idea,
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
          if (idea != null) ...[
            const SizedBox(height: 12),
            _GeneratedIdeaPanel(idea: idea!),
            const SizedBox(height: 12),
          ],
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

class _GeneratedIdeaPanel extends StatelessWidget {
  final GeneratedIdea idea;

  const _GeneratedIdeaPanel({required this.idea});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('history-generated-idea'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '基于历史对比的科研 idea',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TagChip(
                label: idea.title,
                color: AppColors.primary,
                bgColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            idea.body,
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
