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

  test('recording session only creates report when the full record ends', () {
    final state = AppState();

    state.startRecordingSession();
    expect(state.isRecordSessionActive, isTrue);
    expect(state.isRecording, isFalse);
    expect(state.report, isNull);

    state.toggleRecordingSegment();
    expect(state.isRecording, isTrue);
    expect(state.report, isNull);

    state.toggleRecordingSegment();
    expect(state.isRecording, isFalse);
    expect(state.transcript.last.text, startsWith('第 1 段记录'));
    expect(state.transcript.last.evidenceIds, isNotEmpty);
    expect(state.evidence.last.title, contains('第 1 段'));
    expect(state.report, isNull);

    state.finishRecording();
    expect(state.isRecordSessionActive, isFalse);
    expect(state.isRecording, isFalse);
    expect(state.report, isNotNull);
    expect(state.versionDiff, isNotNull);
    expect(state.insights, isEmpty);
  });

  test('interactive actions update observable state', () {
    final state = AppState();

    state.flagEntry(0);
    expect(state.transcript.first.flagged, isTrue);

    state.finishRecording();
    state.exportReport();
    expect(state.exportedReportCount, 1);
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

  test('selected history node exposes generated idea only when present', () {
    final state = AppState();

    state.selectProject('proj-eeg');
    state.selectHistoryNode('eeg-v1');
    expect(state.selectedHistoryIdea, isNull);

    state.selectHistoryNode('eeg-v3');
    expect(state.selectedHistoryIdea, isNotNull);
    expect(state.selectedHistoryIdea!.title, isNotEmpty);
    expect(state.selectedHistoryIdea!.body, contains('历史现象'));
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

  test('archiving adds records under an experiment project tree', () {
    final state = AppState();
    final projectBefore = state.projects.firstWhere(
      (project) => project.id == 'proj-eeg',
    );
    final beforeCount = projectBefore.records.length;

    state.setTitle('脑电疲劳调控项目');
    state.setGoal('记录一次新的疲劳干预实验');
    state.setDomain(projectBefore.domain);
    state.startRecordingSession();
    state.toggleRecordingSegment();
    state.toggleRecordingSegment();
    state.finishRecording();
    state.archiveCurrentRecord();

    final projectAfter = state.projects.firstWhere(
      (project) => project.id == 'proj-eeg',
    );
    expect(projectAfter.records, hasLength(beforeCount + 1));
    expect(projectAfter.records.last.parentId, projectBefore.defaultNodeId);
    expect(projectAfter.records.last.report, isNotNull);
    expect(projectAfter.records.last.diff, isNotNull);
    expect(projectAfter.records.last.transcript, isNotEmpty);
    expect(projectAfter.records.last.evidence, isNotEmpty);
    expect(state.selectedProject.id, projectAfter.id);
    expect(state.selectedHistoryNode.id, projectAfter.records.last.id);
  });

  test('finishing a record auto-closes an active segment before reporting', () {
    final state = AppState();

    state.startRecordingSession();
    state.toggleRecordingSegment();
    state.finishRecording();

    expect(state.isRecording, isFalse);
    expect(state.isRecordSessionActive, isFalse);
    expect(state.transcript, hasLength(1));
    expect(state.report, isNotNull);
    expect(state.report!.actualOperations.single, startsWith('第 1 段记录'));
  });
}
