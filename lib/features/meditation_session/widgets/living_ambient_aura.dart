import 'package:flutter/material.dart';

class LivingAmbientAura extends StatefulWidget {
  final bool isRunning;
  final Color baseColor;
  final double baseSize;
  final Widget? child;
  final String? label;

  const LivingAmbientAura({
    super.key,
    required this.isRunning,
    required this.baseColor,
    required this.baseSize,
    this.child,
    this.label,
  });

  @override
  State<LivingAmbientAura> createState() => _LivingAmbientAuraState();
}

class _LivingAmbientAuraState extends State<LivingAmbientAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.06).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRunning) {
      _breathController.repeat(reverse: true);
    } else {
      _breathController.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant LivingAmbientAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _breathController.repeat(reverse: true);
      } else {
        _breathController.stop();
      }
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: widget.baseSize,
      height: widget.baseSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.baseColor,
        boxShadow: [
          BoxShadow(
            color: widget.baseColor.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.child != null ? Center(child: widget.child) : null,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.baseSize * 4,
          height: widget.baseSize * 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Living Outer Aura Ring
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final scale = widget.isRunning ? _scaleAnimation.value : 1.3;
                  final opacity =
                      widget.isRunning ? _opacityAnimation.value : 0.15;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.baseSize * 2.2,
                      height: widget.baseSize * 2.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.baseColor.withValues(alpha: opacity),
                      ),
                    ),
                  );
                },
              ),

              // Living Middle Aura Ring
              AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final midScale =
                      widget.isRunning ? 1.0 + (_scaleAnimation.value - 1.0) * 0.5 : 1.15;
                  final midOpacity =
                      widget.isRunning ? _opacityAnimation.value * 1.5 : 0.22;
                  return Transform.scale(
                    scale: midScale,
                    child: Container(
                      width: widget.baseSize * 1.6,
                      height: widget.baseSize * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.baseColor.withValues(alpha: midOpacity.clamp(0.0, 1.0)),
                      ),
                    ),
                  );
                },
              ),

              // Core Dot / Focal Point
              core,
            ],
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 32),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              color: widget.baseColor.withValues(alpha: 0.65),
            ),
          ),
        ],
      ],
    );
  }
}
