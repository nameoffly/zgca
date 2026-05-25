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

  bool _isRecordSessionActive = false;
  bool get isRecordSessionActive => _isRecordSessionActive;

  int _recordingSegmentIndex = 0;

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
      selectedHistoryNode.report ??
      _workflowService.structureReport(selectedHistoryNode.experiment);

  GeneratedIdea? get selectedHistoryIdea => selectedHistoryNode.idea;

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
    if (selectedHistoryNode.diff != null) {
      return selectedHistoryNode.diff;
    }
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
    toggleRecordingSegment();
  }

  void startRecording() {
    startRecordingSegment();
  }

  void startRecordingSession() {
    _isRecordSessionActive = true;
    _isRecording = false;
    _recordingSegmentIndex = 0;
    _report = null;
    _versionDiff = null;
    _insights = [];
    _currentExperiment = _workflowService
        .createCurrentDemoExperiment(
          title: _title,
          goal: _goal,
          domain: _domain,
        )
        .copyWith(
          id: 'exp-current-${DateTime.now().microsecondsSinceEpoch}',
          status: ExperimentStatus.recording,
          transcript: const <TranscriptEntry>[],
          evidence: const <Evidence>[],
        );
    notifyListeners();
  }

  void toggleRecordingSegment() {
    if (_isRecording) {
      stopRecordingSegment();
    } else {
      startRecordingSegment();
    }
  }

  void startRecordingSegment() {
    if (!_isRecordSessionActive) {
      startRecordingSession();
    }
    if (_isRecording) {
      return;
    }
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
    stopRecordingSegment();
  }

  void stopRecordingSegment() {
    if (!_isRecording) {
      return;
    }
    _appendMockRecordingSegment();
    _isRecording = false;
    notifyListeners();
  }

  void finishRecording() {
    if (_isRecording) {
      _appendMockRecordingSegment();
    }
    _isRecording = false;
    _isRecordSessionActive = false;
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
    _insights = [];
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
    if (_currentExperiment.transcript.isEmpty ||
        idx < 0 ||
        idx >= _currentExperiment.transcript.length) {
      return;
    }
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

  void archiveCurrentRecord() {
    if (_report == null) {
      finishRecording();
    }

    final completed = _currentExperiment.copyWith(
      status: ExperimentStatus.completed,
    );
    final projectIndex = _projects.indexWhere(
      (project) => project.domain == completed.domain,
    );
    final existingProject = projectIndex >= 0 ? _projects[projectIndex] : null;
    final nodeCount = existingProject?.historyNodes.length ?? 0;
    final node = ExperimentHistoryNode(
      id: 'record-${DateTime.now().microsecondsSinceEpoch}',
      parentId: existingProject?.defaultNodeId,
      experiment: completed,
      title: 'v${nodeCount + 1} ${completed.title}',
      summary: _report!.processObservations.isEmpty
          ? completed.goal
          : _report!.processObservations.first,
      timestamp: '刚刚',
      resultLabel: completed.resultLabel,
      versionNumber: nodeCount + 1,
      report: _report,
      diff: _versionDiff,
      transcript: completed.transcript,
      evidence: completed.evidence,
    );

    if (existingProject == null) {
      final project = LabProject(
        id: 'proj-${DateTime.now().microsecondsSinceEpoch}',
        title: completed.title.trim().isEmpty ? '未命名实验' : completed.title,
        domain: completed.domain,
        goal: completed.goal,
        updatedAt: '刚刚',
        defaultNodeId: node.id,
        historyNodes: [node],
      );
      _projects = [project, ..._projects];
      _selectedProjectId = project.id;
    } else {
      final updatedProject = LabProject(
        id: existingProject.id,
        title: existingProject.title,
        domain: existingProject.domain,
        goal: existingProject.goal,
        updatedAt: '刚刚',
        defaultNodeId: node.id,
        historyNodes: [...existingProject.historyNodes, node],
      );
      _projects = [
        for (int i = 0; i < _projects.length; i++)
          i == projectIndex ? updatedProject : _projects[i],
      ];
      _selectedProjectId = updatedProject.id;
    }
    _selectedHistoryNodeId = node.id;
    _previousExperiment = completed;
    _currentExperiment = _workflowService.createCurrentDemoExperiment(
      title: _title,
      goal: _goal,
      domain: _domain,
    );
    _report = null;
    _versionDiff = null;
    _insights = [];
    _isRecording = false;
    _isRecordSessionActive = false;
    notifyListeners();
  }

  void _appendMockRecordingSegment() {
    _recordingSegmentIndex += 1;
    final segment = _recordingSegmentIndex;
    final second = (segment * 12).toString().padLeft(2, '0');
    final evidenceId = 'ev-segment-$segment';
    final entry = TranscriptEntry(
      '00:00:$second',
      '第 $segment 段记录：记录本轮实验条件、现象变化和关键观察。',
      id: 'tr-segment-$segment',
      evidenceIds: [evidenceId],
      flagged: segment == 1,
    );
    final evidence = Evidence(
      id: evidenceId,
      type: EvidenceType.voice,
      title: '第 $segment 段语音记录',
      detail: 'Mock 转写片段，后续可替换为真实 STT 返回内容。',
      timestamp: entry.time,
      source: '录音',
    );
    _currentExperiment = _currentExperiment.copyWith(
      transcript: [..._currentExperiment.transcript, entry],
      evidence: [..._currentExperiment.evidence, evidence],
      status: ExperimentStatus.recording,
    );
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
