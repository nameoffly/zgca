import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/start_experiment_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/ideas_screen.dart';
import 'state/app_state.dart';

void main() => runApp(const LabAssistantApp());

class LabAssistantApp extends StatelessWidget {
  const LabAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 实验助手',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootShell(),
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
  late final PageController _pageCtrl = PageController(initialPage: _index);

  @override
  void initState() {
    super.initState();
    appState.addListener(_syncWorkflowPage);
  }

  void _syncWorkflowPage() {
    if (appState.isRecording && _index == 0) {
      _goto(1);
    }
  }

  void _goto(int i) {
    setState(() => _index = i);
    if (_pageCtrl.hasClients) {
      _pageCtrl.jumpToPage(i);
    }
  }

  @override
  void dispose() {
    appState.removeListener(_syncWorkflowPage);
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _index = i),
        children: [
          StartExperimentScreen(onGoToRecording: () => _goto(1)),
          RecordingScreen(onFinish: () => _goto(2)),
          const IdeasScreen(),
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
                _navItem(1, Icons.graphic_eq, '记录'),
                _navItem(2, Icons.lightbulb_outline, '整理'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final active = _index == i;
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
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
