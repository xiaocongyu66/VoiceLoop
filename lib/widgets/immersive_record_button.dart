import 'package:flutter/material.dart';

import 'translation_widgets.dart';

class ImmersiveRecordButton extends StatelessWidget {
  final ImmersiveButtonState state;
  final VoidCallback onPressed;

  const ImmersiveRecordButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(context);
    final icon = _stateIcon();

    return GestureDetector(
      onTap: onPressed,
      child: PulsingGlow(
        isActive: state == ImmersiveButtonState.recording,
        color: color,
        size: 72,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(0.7)]),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: state == ImmersiveButtonState.recognizing
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Color _stateColor(BuildContext context) {
    switch (state) {
      case ImmersiveButtonState.idle:
        return Theme.of(context).colorScheme.primary;
      case ImmersiveButtonState.recording:
        return const Color(0xFFEF5350);
      case ImmersiveButtonState.recognizing:
        return const Color(0xFFFFB74D);
      case ImmersiveButtonState.speaking:
        return const Color(0xFF66BB6A);
    }
  }

  IconData _stateIcon() {
    switch (state) {
      case ImmersiveButtonState.idle:
        return Icons.mic_none_rounded;
      case ImmersiveButtonState.recording:
        return Icons.stop_rounded;
      case ImmersiveButtonState.recognizing:
        return Icons.graphic_eq_rounded;
      case ImmersiveButtonState.speaking:
        return Icons.volume_up_rounded;
    }
  }
}

enum ImmersiveButtonState { idle, recording, recognizing, speaking }
