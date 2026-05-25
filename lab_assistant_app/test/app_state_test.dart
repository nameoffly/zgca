import 'package:flutter_test/flutter_test.dart';
import 'package:lab_assistant_app/state/app_state.dart';

void main() {
  test('draft metadata updates before recording starts', () {
    final state = AppState();

    state.setTitle('脑电疲劳预实验 v4');
    state.setGoal('验证刺激频率变化是否影响疲劳评分');
    state.setDomain('神经调控 / 脑电');

    expect(state.title, '脑电疲劳预实验 v4');
    expect(state.goal, '验证刺激频率变化是否影响疲劳评分');
    expect(state.domain, '神经调控 / 脑电');
  });

  test('recording lifecycle creates report diff and insights', () {
    final state = AppState();

    state.startRecording();
    expect(state.isRecording, isTrue);

    state.finishRecording();
    expect(state.isRecording, isFalse);
    expect(state.report, isNotNull);
    expect(state.versionDiff, isNotNull);
    expect(state.insights, hasLength(greaterThanOrEqualTo(3)));
  });

  test('interactive actions update observable state', () {
    final state = AppState();

    state.flagEntry(0);
    expect(state.transcript.first.flagged, isTrue);

    state.finishRecording();
    state.exportReport();
    expect(state.exportedReportCount, 1);

    final firstInsightId = state.insights.first.id;
    state.adoptInsight(firstInsightId);
    expect(
      state.insights
          .firstWhere((insight) => insight.id == firstInsightId)
          .adopted,
      isTrue,
    );
  });

  test('project history initializes with selectable demo projects', () {
    final state = AppState();

    expect(state.projects, hasLength(greaterThanOrEqualTo(2)));
    expect(state.selectedProject.historyNodes, isNotEmpty);
    expect(
      state.selectedProject.historyNodes.map((node) => node.id),
      contains(state.selectedHistoryNode.id),
    );
    expect(
      state.selectedHistoryReport.purpose,
      state.selectedHistoryNode.experiment.goal,
    );
  });

  test('selecting a project and history node updates the selected report', () {
    final state = AppState();
    final targetProject = state.projects.last;
    final targetNode = targetProject.historyNodes.first;

    state.selectProject(targetProject.id);
    expect(state.selectedProject.id, targetProject.id);
    expect(state.selectedHistoryNode.id, targetProject.defaultNodeId);

    state.selectHistoryNode(targetNode.id);
    expect(state.selectedHistoryNode.id, targetNode.id);
    expect(state.selectedHistoryReport.purpose, targetNode.experiment.goal);
  });

  test('selected history node exposes parent diff when a parent exists', () {
    final state = AppState();

    state.selectProject('proj-eeg');
    state.selectHistoryNode('eeg-v3');

    expect(state.selectedHistoryParent?.id, 'eeg-v2');
    expect(state.selectedHistoryDiff, isNotNull);
  });

  test('project history parent references resolve inside each project', () {
    final state = AppState();

    for (final project in state.projects) {
      final nodeIds = project.historyNodes.map((node) => node.id).toSet();
      expect(nodeIds, contains(project.defaultNodeId));

      for (final node in project.historyNodes) {
        if (node.parentId != null) {
          expect(nodeIds, contains(node.parentId));
        }
      }
    }
  });
}
