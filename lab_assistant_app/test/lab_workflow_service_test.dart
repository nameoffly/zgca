import 'package:flutter_test/flutter_test.dart';
import 'package:lab_assistant_app/models/experiment.dart';
import 'package:lab_assistant_app/services/lab_workflow_service.dart';

void main() {
  test('demo experiment preserves process evidence from multiple sources', () {
    final service = LabWorkflowService();
    final experiment = service.createCurrentDemoExperiment();

    expect(
      experiment.evidence.where((e) => e.type == EvidenceType.voice),
      isNotEmpty,
    );
    expect(
      experiment.evidence.where((e) => e.type == EvidenceType.image),
      isNotEmpty,
    );
    expect(
      experiment.evidence.where((e) => e.type == EvidenceType.instrumentFile),
      isNotEmpty,
    );
    expect(experiment.transcript.any((entry) => entry.flagged), isTrue);
  });

  test('structured report keeps required report modules from the plan', () {
    final service = LabWorkflowService();
    final experiment = service.createCurrentDemoExperiment();
    final report = service.structureReport(experiment);

    expect(report.purpose, isNotEmpty);
    expect(report.experimentType, isNotEmpty);
    expect(report.plannedConditions, isNotEmpty);
    expect(report.actualOperations, hasLength(greaterThanOrEqualTo(3)));
    expect(report.conditionChanges, isNotEmpty);
    expect(report.processObservations, isNotEmpty);
    expect(report.resultMetrics, isNotEmpty);
    expect(report.rawEvidence, hasLength(greaterThanOrEqualTo(3)));
    expect(report.nextSuggestions, isNotEmpty);
  });

  test('data sample records are stored as concise narrative reports', () {
    final service = LabWorkflowService();
    final projects = service.createDemoProjects();
    final eegProject = projects.firstWhere(
      (project) => project.id == 'proj-eeg',
    );

    expect(eegProject.historyNodes, hasLength(6));
    final firstReport = eegProject.historyNodes.first.report!;
    expect(firstReport.title, 'H001 高负荷认知任务下的协同刺激效果评估');
    expect(firstReport.body, contains('一、实验概况'));
    expect(firstReport.body, contains('5 Hz视听觉协同刺激后'));
    expect(firstReport.body, isNot(contains('本报告内容根据')));

    final controlNode = eegProject.historyNodes.firstWhere(
      (node) => node.id == 'eeg-h006',
    );
    expect(controlNode.parentId, 'eeg-v1');
    expect(controlNode.report!.body, contains('Sham假刺激'));
  });

  test('version diff exposes changed variables and result differences', () {
    final service = LabWorkflowService();
    final previous = service.createPreviousDemoExperiment();
    final current = service.createCurrentDemoExperiment();
    final diff = service.compareVersions(previous: previous, current: current);

    expect(diff.changedVariables, contains('刺激频率 / 反应温度'));
    expect(diff.resultDifferences, isNotEmpty);
    expect(diff.repeatedSignals, isNotEmpty);
    expect(diff.anomalyHints, isNotEmpty);
  });

  test('insights are traceable, uncertain, and actionable', () {
    final service = LabWorkflowService();
    final current = service.createCurrentDemoExperiment();
    final report = service.structureReport(current);
    final diff = service.compareVersions(
      previous: service.createPreviousDemoExperiment(),
      current: current,
    );
    final insights = service.generateInsights(
      experiment: current,
      report: report,
      diff: diff,
    );

    expect(insights, hasLength(greaterThanOrEqualTo(3)));
    for (final insight in insights) {
      expect(insight.title, isNotEmpty);
      expect(insight.evidenceIds, isNotEmpty);
      expect(insight.uncertainty, isNotEmpty);
      expect(insight.nextExperimentAction, isNotEmpty);
      expect(insight.adopted, isFalse);
    }
  });
}
