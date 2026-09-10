import 'package:flutter/material.dart';

class RunningTimerDisplay extends StatefulWidget {
  final int totalSeconds;
  final bool isRunning;
  final Color textColor;

  const RunningTimerDisplay({
    super.key,
    required this.totalSeconds,
    required this.isRunning,
    required this.textColor,
  });

  @override
  State<RunningTimerDisplay> createState() => _RunningTimerDisplayState();
}

class _RunningTimerDisplayState extends State<RunningTimerDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _colonOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _colonOpacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRunning) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant RunningTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 200),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = (widget.totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (widget.totalSeconds % 60).toString().padLeft(2, '0');

    final digitStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: widget.textColor.withValues(alpha: 0.85),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(m, style: digitStyle),
        AnimatedBuilder(
          animation: _colonOpacity,
          builder: (context, child) {
            return Opacity(
              opacity: widget.isRunning ? _colonOpacity.value : 1.0,
              child: Text(
                ':',
                style: digitStyle.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          },
        ),
        Text(s, style: digitStyle),
      ],
    );
  }
}
