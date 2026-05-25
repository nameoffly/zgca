import 'package:flutter/material.dart';
import '../theme.dart';
import '../state/app_state.dart';
import '../widgets/section_card.dart';
import '../widgets/wave_decoration.dart';

const _languages = ['中文', 'English', '中英混合'];

class RecordingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const RecordingScreen({super.key, this.onFinish});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  @override
  void initState() {
    super.initState();
    appState.addListener(_onState);
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    appState.removeListener(_onState);
    super.dispose();
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

  Future<void> _pickLanguage() async {
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
            const SizedBox(height: 12),
            const Text(
              '转写语言',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ..._languages.map(
              (l) => ListTile(
                title: Text(l, style: const TextStyle(fontSize: 14)),
                trailing: l == appState.language
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(l),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) appState.setLanguage(picked);
  }

  void _openSessionList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '历史记录会话',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              _SessionRow(title: '酯化反应 · v3', time: '今天 10:24', tag: '预实验'),
              _SessionRow(title: '酯化反应 · v2', time: '昨天 16:10', tag: '条件优化'),
              _SessionRow(title: '酯化反应 · v1', time: '5/22 09:32', tag: '预实验'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildTranscriptCard(),
            const SizedBox(height: 18),
            _buildRecordSegmentButton(),
            const SizedBox(height: 12),
            _buildFinishButton(),
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
            width: 30,
            height: 30,
            alignment: Alignment.center,
            child: const Icon(
              Icons.graphic_eq,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '实时记录',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _openSessionList,
            icon: const Icon(
              Icons.list_alt_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard() {
    final entries = appState.transcript;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '实时转写',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                onTap: _openEvidenceSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '证据',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                onTap: _pickLanguage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        appState.language,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < entries.length; i++) ...[
            _transcriptLine(i, entries[i]),
            if (i < entries.length - 1)
              const Divider(color: AppColors.divider, height: 20, thickness: 1),
          ],
          const SizedBox(height: 16),
          AnimatedCenteredWave(height: 64, active: appState.isRecording),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                appState.flagEntry(entries.isEmpty ? 0 : entries.length - 1);
                _toast('已标记当前步骤');
              },
              icon: const Icon(
                Icons.flag_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              label: const Text(
                '标记步骤',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryLight),
                backgroundColor: AppColors.primarySoft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEvidenceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '过程证据',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      for (final evidence in appState.evidence)
                        _EvidenceRow(
                          title: evidence.title,
                          detail: evidence.detail,
                          source: evidence.source,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _transcriptLine(int idx, TranscriptEntry e) {
    final highlight = e.flagged;
    final color = highlight ? AppColors.primary : AppColors.textPrimary;
    return Semantics(
      button: true,
      selected: highlight,
      label: '标记 ${e.time} 实验步骤',
      onTap: () {
        appState.flagEntry(idx);
      },
      child: InkWell(
        onTap: () {
          appState.flagEntry(idx);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.time,
              style: TextStyle(
                color: highlight ? AppColors.primary : AppColors.textTertiary,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                e.text,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (highlight) ...[
              const SizedBox(width: 6),
              const Icon(Icons.graphic_eq, color: AppColors.primary, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSegmentButton() {
    final active = appState.isRecording;
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        key: const ValueKey('segment-record-button'),
        onPressed: appState.toggleRecordingSegment,
        icon: Icon(active ? Icons.stop_rounded : Icons.mic_rounded, size: 20),
        label: Text(
          active ? '停止本段录音' : '开始录音',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? AppColors.danger : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          appState.finishRecording();
          widget.onFinish?.call();
        },
        icon: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        label: const Text(
          '结束记录',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final String title;
  final String detail;
  final String source;

  const _EvidenceRow({
    required this.title,
    required this.detail,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.folder_copy_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TagChip(
                      label: source,
                      color: AppColors.primary,
                      bgColor: AppColors.primarySoft,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final String title;
  final String time;
  final String tag;
  const _SessionRow({
    required this.title,
    required this.time,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TagChip(
            label: tag,
            color: AppColors.primary,
            bgColor: AppColors.primarySoft,
          ),
        ],
      ),
    );
  }
}
