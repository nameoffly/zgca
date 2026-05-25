enum EvidenceType { voice, transcript, image, instrumentFile, safetySource }

enum ExperimentStatus { draft, recording, completed }

class TranscriptEntry {
  final String id;
  final String time;
  final String text;
  final List<String> evidenceIds;
  bool flagged;

  TranscriptEntry(
    this.time,
    this.text, {
    String? id,
    this.flagged = false,
    this.evidenceIds = const [],
  }) : id = id ?? 'tr-$time';

  TranscriptEntry copyWith({
    String? id,
    String? time,
    String? text,
    bool? flagged,
    List<String>? evidenceIds,
  }) {
    return TranscriptEntry(
      time ?? this.time,
      text ?? this.text,
      id: id ?? this.id,
      flagged: flagged ?? this.flagged,
      evidenceIds: evidenceIds ?? this.evidenceIds,
    );
  }
}

class Evidence {
  final String id;
  final EvidenceType type;
  final String title;
  final String detail;
  final String timestamp;
  final String source;

  const Evidence({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.timestamp,
    required this.source,
  });
}

class Experiment {
  final String id;
  final String title;
  final String goal;
  final String domain;
  final String experimentType;
  final ExperimentStatus status;
  final List<TranscriptEntry> transcript;
  final List<Evidence> evidence;
  final String resultLabel;

  const Experiment({
    required this.id,
    required this.title,
    required this.goal,
    required this.domain,
    required this.experimentType,
    required this.status,
    required this.transcript,
    required this.evidence,
    required this.resultLabel,
  });

  Experiment copyWith({
    String? id,
    String? title,
    String? goal,
    String? domain,
    String? experimentType,
    ExperimentStatus? status,
    List<TranscriptEntry>? transcript,
    List<Evidence>? evidence,
    String? resultLabel,
  }) {
    return Experiment(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      domain: domain ?? this.domain,
      experimentType: experimentType ?? this.experimentType,
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      evidence: evidence ?? this.evidence,
      resultLabel: resultLabel ?? this.resultLabel,
    );
  }
}

class StructuredReport {
  final String purpose;
  final String experimentType;
  final List<String> plannedConditions;
  final List<String> actualOperations;
  final List<String> conditionChanges;
  final List<String> processObservations;
  final List<String> resultMetrics;
  final List<Evidence> rawEvidence;
  final List<String> nextSuggestions;

  const StructuredReport({
    required this.purpose,
    required this.experimentType,
    required this.plannedConditions,
    required this.actualOperations,
    required this.conditionChanges,
    required this.processObservations,
    required this.resultMetrics,
    required this.rawEvidence,
    required this.nextSuggestions,
  });
}

class ExperimentDiff {
  final List<String> changedVariables;
  final List<String> resultDifferences;
  final List<String> repeatedSignals;
  final List<String> anomalyHints;

  const ExperimentDiff({
    required this.changedVariables,
    required this.resultDifferences,
    required this.repeatedSignals,
    required this.anomalyHints,
  });
}

class ResearchInsight {
  final String id;
  final String title;
  final String summary;
  final List<String> evidenceIds;
  final String uncertainty;
  final String nextExperimentAction;
  final String riskLabel;
  final bool adopted;

  const ResearchInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.evidenceIds,
    required this.uncertainty,
    required this.nextExperimentAction,
    required this.riskLabel,
    this.adopted = false,
  });

  ResearchInsight copyWith({bool? adopted}) {
    return ResearchInsight(
      id: id,
      title: title,
      summary: summary,
      evidenceIds: evidenceIds,
      uncertainty: uncertainty,
      nextExperimentAction: nextExperimentAction,
      riskLabel: riskLabel,
      adopted: adopted ?? this.adopted,
    );
  }
}
