import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16,
    this.borderOpacity = 0.1,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (warm?.surfaceContainer ?? const Color(0xFF261e1b)).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (warm?.primary ?? const Color(0xFFffb68a)).withValues(alpha: borderOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
