import 'package:flutter/material.dart';

import 'screens/ideas_screen.dart';
import 'screens/project_history_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/start_experiment_screen.dart';
import 'theme.dart';

void main() => runApp(const LabAssistantApp());

class LabAssistantApp extends StatelessWidget {
  const LabAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 实验助手',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _entered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _entered
          ? const RootShell(key: ValueKey('root'))
          : SplashScreen(
              key: const ValueKey('splash'),
              onEnter: () => setState(() => _entered = true),
            ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _goto(int i) => setState(() => _index = i);

  Future<void> _enterRecordingFlow() async {
    final nav = Navigator.of(context);
    await nav.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (recordingCtx) => Scaffold(
          backgroundColor: AppColors.bg,
          body: RecordingScreen(
            onFinish: () {
              Navigator.of(recordingCtx).pushReplacement(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (summaryCtx) => Scaffold(
                    backgroundColor: AppColors.bg,
                    body: StructuredReportScreen(
                      onSaved: () {
                        Navigator.of(summaryCtx).pop();
                        _onArchived();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onArchived() {
    if (!mounted) return;
    setState(() => _index = 1);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已保存到报告历史'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: [
          StartExperimentScreen(onConfirmStart: _enterRecordingFlow),
          const ProjectHistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.science_outlined, '开始'),
                _navItem(
                  1,
                  Icons.account_tree_outlined,
                  '报告历史',
                  key: const ValueKey('nav-projects'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label, {Key? key}) {
    final active = _index == i;
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          key: key,
          onTap: () => _goto(i),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
