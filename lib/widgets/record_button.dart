import 'dart:math';

import 'package:flutter/material.dart';

import '../core/extensions/context_extensions.dart';

enum RecordButtonState { idle, recording, recognizing, speaking }

class RecordButton extends StatefulWidget {
  final RecordButtonState state;
  final VoidCallback onPressed;

  const RecordButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with TickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    _pulseController?.dispose();
    if (widget.state == RecordButtonState.recording) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      )..repeat(reverse: true);
    } else {
      _pulseController = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final color = _color(cs);
    final icon = _icon();
    final size = widget.state == RecordButtonState.recording ? 84.0 : 72.0;

    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.state == RecordButtonState.recording) ...[
            if (_pulseController != null)
              AnimatedBuilder(
                animation: _pulseController!,
                builder: (context, child) {
                  final t = _pulseController!.value;
                  final scale = 1.0 + 0.4 * t;
                  final opacity = 0.5 * (1.0 - t);
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: size + 32,
                  height: size + 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                ),
              ),
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
            ),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: widget.state == RecordButtonState.recording
                ? _WaveformIndicator(color: Colors.white)
                : widget.state == RecordButtonState.recognizing
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Color _color(ColorScheme cs) {
    switch (widget.state) {
      case RecordButtonState.idle:
        return cs.primary;
      case RecordButtonState.recording:
        return cs.error;
      case RecordButtonState.recognizing:
        return Colors.orange;
      case RecordButtonState.speaking:
        return cs.tertiary;
    }
  }

  IconData _icon() {
    switch (widget.state) {
      case RecordButtonState.idle:
        return Icons.mic_none_rounded;
      case RecordButtonState.recording:
        return Icons.stop_rounded;
      case RecordButtonState.recognizing:
        return Icons.hourglass_top_rounded;
      case RecordButtonState.speaking:
        return Icons.volume_up_rounded;
    }
  }
}

class _WaveformIndicator extends StatefulWidget {
  final Color color;

  const _WaveformIndicator({required this.color});

  @override
  State<_WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<_WaveformIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final phase = i * 0.3;
            final t = (sin((_controller.value * pi * 2) + phase) + 1) / 2;
            final h = 12.0 + t * 36.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
