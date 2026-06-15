import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Phase 2.3 — gold mic button shown next to the chat input. Tap to start
/// recording, tap again to stop. On stop, fires [onRecorded] with the
/// recorded file path so the caller can upload to Firebase Storage and
/// send the chat message.
class VoiceRecorderButton extends StatefulWidget {
  final Future<void> Function(File file, Duration duration) onRecorded;
  const VoiceRecorderButton({Key? key, required this.onRecorded})
      : super(key: key);

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final _rec = AudioRecorder();
  bool _isRecording = false;
  String? _path;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    _rec.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isRecording) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    if (!await _rec.hasPermission()) {
      Get.snackbar('Microphone'.tr,
          'Microphone permission is required to record voice notes.'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }
    final tmp = await getTemporaryDirectory();
    final p = '${tmp.path}/vn_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 96000,
        sampleRate: 44100,
      ),
      path: p,
    );
    _path = p;
    _elapsed = Duration.zero;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    final path = await _rec.stop();
    if (mounted) setState(() => _isRecording = false);
    final useDuration = _elapsed;
    _elapsed = Duration.zero;
    final out = path ?? _path;
    if (out == null) return;
    final f = File(out);
    if (!await f.exists() || await f.length() < 200) return;
    await widget.onRecorded(f, useDuration);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.redAccent, width: 1),
        ),
        child: InkWell(
          onTap: _toggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(),
              const SizedBox(width: 6),
              Text(
                _fmt(_elapsed),
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.stop_rounded,
                  color: Colors.redAccent, size: 18),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: 'Voice note'.tr,
        icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
        onPressed: _toggle,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c.drive(Tween(begin: 0.3, end: 1.0)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Inline player for received voice messages.
class VoiceMessageBubble extends StatefulWidget {
  final String url;
  final Color foreground;
  final Color trackColor;
  const VoiceMessageBubble({
    Key? key,
    required this.url,
    this.foreground = Colors.white,
    this.trackColor = const Color(0x33FFFFFF),
  }) : super(key: key);

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = AudioPlayer();
  Duration _total = Duration.zero;
  Duration _pos = Duration.zero;
  bool _playing = false;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _total = d);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() {
          _playing = s == PlayerState.playing;
          if (s == PlayerState.completed) _pos = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total.inMilliseconds == 0
        ? 0.0
        : _pos.inMilliseconds / _total.inMilliseconds;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _toggle,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.foreground.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: widget.foreground,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: widget.trackColor,
                  color: widget.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _total > Duration.zero
                    ? '${_fmt(_pos)} / ${_fmt(_total)}'
                    : 'Voice note',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: widget.foreground.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
