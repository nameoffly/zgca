import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_assistant_app/main.dart';
import 'package:lab_assistant_app/state/app_state.dart';

Future<void> _pumpEnteredApp(WidgetTester tester) async {
  await tester.pumpWidget(const LabAssistantApp());
  await tester.tapAt(const Offset(20, 20));
  await tester.pump(const Duration(milliseconds: 1600));
}

void main() {
  testWidgets('App boots and shows the start screen', (tester) async {
    await _pumpEnteredApp(tester);
    expect(find.text('开始实验'), findsOneWidget);
    expect(find.text('报告历史'), findsOneWidget);
    expect(find.text('记录'), findsNothing);
    expect(find.text('整理'), findsNothing);
    expect(find.byKey(const ValueKey('start-recording-button')), findsNothing);
    expect(find.text('确定 · 进入实时记录'), findsOneWidget);
  });

  testWidgets('Core product loop is isolated from bottom navigation', (
    tester,
  ) async {
    await _pumpEnteredApp(tester);

    await tester.enterText(find.byType(TextField).at(0), '脑电疲劳预实验 v4');
    await tester.enterText(find.byType(TextField).at(1), '验证疲劳下降线索');
    await tester.ensureVisible(
      find.byKey(const ValueKey('confirm-start-button')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('confirm-start-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(appState.isRecordSessionActive, isTrue);
    expect(appState.isRecording, isFalse);

    expect(find.text('实时记录'), findsOneWidget);
    expect(find.text('开始'), findsNothing);
    expect(find.text('报告历史'), findsNothing);
    expect(find.textContaining('警告'), findsNothing);
    expect(find.text('证据'), findsOneWidget);
    expect(find.text('标记步骤'), findsOneWidget);
    expect(find.byKey(const ValueKey('segment-record-button')), findsOneWidget);
    expect(find.text('开始录音'), findsOneWidget);
    expect(find.text('结束记录'), findsOneWidget);

    final beforeTranscriptCount = appState.transcript.length;
    await tester.tap(find.byKey(const ValueKey('segment-record-button')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(appState.isRecording, isTrue);
    expect(find.text('停止本段录音'), findsOneWidget);
    expect(find.text('结构化报告'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('segment-record-button')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(appState.isRecording, isFalse);
    expect(appState.transcript.length, beforeTranscriptCount + 1);
    expect(find.text('实时记录'), findsOneWidget);
    expect(find.text('结构化报告'), findsNothing);

    await tester.tap(find.text('证据'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('过程证据'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.ensureVisible(find.text('结束记录'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('结束记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('结构化报告'), findsWidgets);
    expect(find.text('版本对比'), findsOneWidget);
    expect(find.text('探索线索'), findsNothing);
    expect(find.textContaining('Idea'), findsNothing);
    expect(find.text('采纳'), findsNothing);
    expect(find.text('导出报告'), findsOneWidget);

    await tester.ensureVisible(find.text('导出报告'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('导出报告'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(appState.exportedReportCount, greaterThan(0));
    expect(find.textContaining('已导出'), findsWidgets);

    await tester.ensureVisible(find.text('保存并归档'));
    await tester.tap(find.text('保存并归档'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.byKey(const ValueKey('project-history-screen')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('project-card-proj-eeg')), findsOneWidget);
  });

  testWidgets('Project history tab opens projects tree and node report', (
    tester,
  ) async {
    await _pumpEnteredApp(tester);

    await tester.tap(find.byKey(const ValueKey('nav-projects')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('project-history-screen')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('project-card-proj-eeg')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('project-card-proj-eeg')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.byKey(const ValueKey('experiment-detail-screen')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('history-tree')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-tree-graph')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-report-detail')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-generated-idea')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('history-node-eeg-v3')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('history-node-eeg-v3')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(appState.selectedHistoryNode.id, 'eeg-v3');
    expect(find.textContaining('v3'), findsWidgets);
    expect(
      find.byKey(const ValueKey('history-generated-idea')),
      findsOneWidget,
    );
    expect(find.text('基于历史对比的科研 idea'), findsOneWidget);
  });
}
