import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_assistant_app/main.dart';
import 'package:lab_assistant_app/state/app_state.dart';

void main() {
  testWidgets('App boots and shows the start screen', (tester) async {
    await tester.pumpWidget(const LabAssistantApp());
    expect(find.text('开始实验'), findsOneWidget);
  });

  testWidgets('Core product loop is interactive from recording to insights', (
    tester,
  ) async {
    await tester.pumpWidget(const LabAssistantApp());

    await tester.enterText(find.bySemanticsLabel('实验标题'), '脑电疲劳预实验 v4');
    await tester.enterText(find.bySemanticsLabel('实验目标'), '验证疲劳下降线索');
    await tester.ensureVisible(
      find.byKey(const ValueKey('start-recording-button')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('start-recording-button')));
    await tester.pump(const Duration(milliseconds: 900));
    expect(appState.isRecording, isTrue);

    expect(find.text('实时记录'), findsOneWidget);
    expect(find.text('证据'), findsOneWidget);
    expect(find.text('标记步骤'), findsOneWidget);

    await tester.tap(find.text('证据'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('过程证据'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.ensureVisible(find.text('结束'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('结束'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('结构化报告'), findsOneWidget);
    expect(find.text('版本对比'), findsOneWidget);
    expect(find.text('探索线索'), findsOneWidget);
    expect(find.text('导出报告'), findsOneWidget);

    await tester.ensureVisible(find.text('导出报告'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('导出报告'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(appState.exportedReportCount, greaterThan(0));
    expect(find.textContaining('已导出'), findsOneWidget);

    await tester.ensureVisible(find.text('采纳').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('采纳').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('已采纳'), findsWidgets);
  });

  testWidgets('Project history tab opens projects tree and node report', (
    tester,
  ) async {
    await tester.pumpWidget(const LabAssistantApp());

    await tester.tap(find.byKey(const ValueKey('nav-projects')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('project-history-screen')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('project-card-proj-eeg')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('project-card-proj-eeg')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('history-tree')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-report-detail')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('history-node-eeg-v3')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('history-node-eeg-v3')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(appState.selectedHistoryNode.id, 'eeg-v3');
    expect(find.textContaining('v3'), findsWidgets);
  });
}
