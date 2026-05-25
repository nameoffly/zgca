import 'package:flutter/foundation.dart';

import '../models/experiment.dart';
import '../services/lab_workflow_service.dart';

export '../models/experiment.dart';

class AppState extends ChangeNotifier {
  AppState({LabWorkflowService? workflowService})
    : _workflowService = workflowService ?? LabWorkflowService() {
    _previousExperiment = _workflowService.createPreviousDemoExperiment();
    _currentExperiment = _workflowService.createCurrentDemoExperiment();
    _projects = _workflowService.createDemoProjects();
    _selectedProjectId = _projects.first.id;
    _selectedHistoryNodeId = _projects.first.defaultNodeId;
    _title = _currentExperiment.title;
    _goal = _currentExperiment.goal;
    _domain = _currentExperiment.domain;
  }

  final LabWorkflowService _workflowService;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  late Experiment _previousExperiment;
  late Experiment _currentExperiment;
  Experiment get currentExperiment => _currentExperiment;
  Experiment get previousExperiment => _previousExperiment;

  late List<LabProject> _projects;
  List<LabProject> get projects => List.unmodifiable(_projects);

  late String _selectedProjectId;
  String get selectedProjectId => _selectedProjectId;

  late String _selectedHistoryNodeId;
  String get selectedHistoryNodeId => _selectedHistoryNodeId;

  LabProject get selectedProject => _projects.firstWhere(
    (project) => project.id == _selectedProjectId,
    orElse: () => _projects.first,
  );

  ExperimentHistoryNode get selectedHistoryNode =>
      selectedProject.historyNodes.firstWhere(
        (node) => node.id == _selectedHistoryNodeId,
        orElse: () => selectedProject.historyNodes.first,
      );

  StructuredReport get selectedHistoryReport =>
      _workflowService.structureReport(selectedHistoryNode.experiment);

  ExperimentHistoryNode? get selectedHistoryParent {
    final parentId = selectedHistoryNode.parentId;
    if (parentId == null) {
      return null;
    }
    for (final node in selectedProject.historyNodes) {
      if (node.id == parentId) {
        return node;
      }
    }
    return null;
  }

  ExperimentDiff? get selectedHistoryDiff {
    final parent = selectedHistoryParent;
    if (parent == null) {
      return null;
    }
    return _workflowService.compareVersions(
      previous: parent.experiment,
      current: selectedHistoryNode.experiment,
    );
  }

  late String _title;
  String get title => _title;

  late String _goal;
  String get goal => _goal;

  late String _domain;
  String get domain => _domain;

  String _language = '中文';
  String get language => _language;

  bool _continuousMode = true;
  bool get continuousMode => _continuousMode;

  StructuredReport? _report;
  StructuredReport? get report => _report;

  ExperimentDiff? _versionDiff;
  ExperimentDiff? get versionDiff => _versionDiff;

  List<ResearchInsight> _insights = [];
  List<ResearchInsight> get insights => List.unmodifiable(_insights);

  int _exportedReportCount = 0;
  int get exportedReportCount => _exportedReportCount;

  List<TranscriptEntry> get transcript =>
      List.unmodifiable(_currentExperiment.transcript);

  List<Evidence> get evidence => List.unmodifiable(_currentExperiment.evidence);

  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void startRecording() {
    _isRecording = true;
    _currentExperiment = _currentExperiment.copyWith(
      title: _title,
      goal: _goal,
      domain: _domain,
      status: ExperimentStatus.recording,
    );
    notifyListeners();
  }

  void stopRecording() {
    if (_isRecording) {
      _isRecording = false;
      notifyListeners();
    }
  }

  void finishRecording() {
    _isRecording = false;
    _currentExperiment = _currentExperiment.copyWith(
      title: _title,
      goal: _goal,
      domain: _domain,
      status: ExperimentStatus.completed,
    );
    _report = _workflowService.structureReport(_currentExperiment);
    _versionDiff = _workflowService.compareVersions(
      previous: _previousExperiment,
      current: _currentExperiment,
    );
    _insights = _workflowService.generateInsights(
      experiment: _currentExperiment,
      report: _report!,
      diff: _versionDiff!,
    );
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    _currentExperiment = _currentExperiment.copyWith(title: value);
    notifyListeners();
  }

  void setGoal(String value) {
    _goal = value;
    _currentExperiment = _currentExperiment.copyWith(goal: value);
    notifyListeners();
  }

  void setDomain(String v) {
    _domain = v;
    _currentExperiment = _currentExperiment.copyWith(domain: v);
    notifyListeners();
  }

  void setLanguage(String v) {
    _language = v;
    notifyListeners();
  }

  void setContinuousMode(bool continuous) {
    _continuousMode = continuous;
    notifyListeners();
  }

  void flagEntry(int idx) {
    final updated = [..._currentExperiment.transcript];
    final entry = updated[idx];
    updated[idx] = entry.copyWith(flagged: !entry.flagged);
    _currentExperiment = _currentExperiment.copyWith(transcript: updated);
    notifyListeners();
  }

  void exportReport() {
    if (_report == null) {
      finishRecording();
    }
    _exportedReportCount += 1;
    notifyListeners();
  }

  void adoptInsight(String id) {
    _insights = [
      for (final insight in _insights)
        insight.id == id ? insight.copyWith(adopted: true) : insight,
    ];
    notifyListeners();
  }

  void selectProject(String id) {
    final project = _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => selectedProject,
    );
    _selectedProjectId = project.id;
    _selectedHistoryNodeId = project.defaultNodeId;
    notifyListeners();
  }

  void selectHistoryNode(String id) {
    final hasNode = selectedProject.historyNodes.any((node) => node.id == id);
    if (!hasNode) {
      return;
    }
    _selectedHistoryNodeId = id;
    notifyListeners();
  }
}

final appState = AppState();
