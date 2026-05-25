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
}
