import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../widgets/section_card.dart';
import '../widgets/wave_decoration.dart';

const _domains = ['有机化学', '神经调控 / 脑电', '细胞培养', '材料合成', '设备性能测试', '药物刺激实验'];

class StartExperimentScreen extends StatefulWidget {
  final VoidCallback? onGoToRecording;
  const StartExperimentScreen({super.key, this.onGoToRecording});

  @override
  State<StartExperimentScreen> createState() => _StartExperimentScreenState();
}

class _StartExperimentScreenState extends State<StartExperimentScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = appState.title;
    _goalCtrl.text = appState.goal;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    appState.addListener(_onState);
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    appState.removeListener(_onState);
    _pulseCtrl.dispose();
    _titleCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDomain() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '所属领域',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ..._domains.map(
              (d) => ListTile(
                title: Text(d, style: const TextStyle(fontSize: 14)),
                trailing: d == appState.domain
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(d),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) appState.setDomain(picked);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _onMicTap() {
    if (appState.isRecording) {
      appState.stopRecording();
      _toast('已暂停录音');
    } else {
      appState.startRecording();
      _toast('正在录音…');
      widget.onGoToRecording?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = appState.isRecording;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabeledInput(
                    label: '实验标题',
                    controller: _titleCtrl,
                    hint: '如：硫酸酯化反应条件优化',
                    maxLength: 30,
                  ),
                  const SizedBox(height: 18),
                  _LabeledInput(
                    label: '实验目标',
                    controller: _goalCtrl,
                    hint: '如：提高酯化反应产率',
                    maxLength: 30,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        '所属领域',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _DomainSelector(
                        value: appState.domain,
                        onTap: _pickDomain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildMicArea(recording),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: recording
                  ? _buildGoToRecordingHint()
                  : const SizedBox(height: 0),
            ),
            const SizedBox(height: 14),
            _buildDraftCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.science_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '开始实验',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'AI 实验助手 · 语音驱动',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _openSettingsSheet,
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '记录设置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _SettingRow(
                icon: Icons.language,
                title: '转写语言',
                value: appState.language,
              ),
              _SettingRow(
                icon: Icons.mic_none_outlined,
                title: '录音模式',
                value: appState.continuousMode ? '持续监听' : '按住说话',
              ),
              _SettingRow(
                icon: Icons.lock_outline,
                title: '数据范围',
                value: '本地演示数据',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicArea(bool recording) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (recording) ...[
            Positioned(
              left: 0,
              child: AnimatedWaveBars(
                barCount: 12,
                maxHeight: 40,
                color: AppColors.primary.withValues(alpha: 0.65),
                seed: 4,
                active: true,
              ),
            ),
            Positioned(
              right: 0,
              child: AnimatedWaveBars(
                barCount: 12,
                maxHeight: 40,
                color: AppColors.primary.withValues(alpha: 0.65),
                seed: 9,
                active: true,
              ),
            ),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final scale = recording ? 1.0 + _pulseCtrl.value * 0.05 : 1.0;
                  final ringAlpha = recording
                      ? 0.18 + _pulseCtrl.value * 0.18
                      : 0.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: ringAlpha,
                            ),
                            blurRadius: 30,
                            spreadRadius: 14,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: Semantics(
                  button: true,
                  label: recording ? '停止记录' : '开始记录',
                  child: InkWell(
                    key: const ValueKey('start-recording-button'),
                    customBorder: const CircleBorder(),
                    onTap: _onMicTap,
                    child: Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: recording
                              ? const [Color(0xFFFB7185), AppColors.danger]
                              : const [Color(0xFF2DD4BF), AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (recording
                                        ? AppColors.danger
                                        : AppColors.primary)
                                    .withValues(alpha: 0.35),
                            blurRadius: 26,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        recording ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                        size: recording ? 46 : 50,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                recording ? '正在记录 · 点击停止' : '开始记录',
                style: TextStyle(
                  color: recording ? AppColors.danger : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoToRecordingHint() {
    return Semantics(
      button: true,
      label: '查看实时转写',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: widget.onGoToRecording,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.primaryLight, width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.graphic_eq, color: AppColors.primary, size: 16),
              SizedBox(width: 6),
              Text(
                '查看实时转写',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftCard() {
    final draftTitle = appState.title.trim().isEmpty ? '未命名实验' : appState.title;
    return Semantics(
      button: true,
      label: '打开最近草稿',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: _openDraftSheet,
        child: SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近草稿',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draftTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const TagChip(
                label: '已保存',
                color: AppColors.success,
                bgColor: AppColors.successBg,
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDraftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '最近草稿',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                appState.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                appState.goal,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLength;
  final TextEditingController controller;

  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.maxLength,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: label,
                  textField: true,
                  child: TextField(
                    controller: controller,
                    maxLength: maxLength,
                    onChanged: (value) {
                      if (label == '实验标题') {
                        appState.setTitle(value);
                      } else if (label == '实验目标') {
                        appState.setGoal(value);
                      }
                    },
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, v, _) => Text(
                  '${v.text.characters.length}/$maxLength',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainSelector extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _DomainSelector({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '选择所属领域',
      value: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.input),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.science_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
