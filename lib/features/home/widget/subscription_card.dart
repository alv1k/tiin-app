import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.expiryText,
    required this.renewText,
    required this.onRenew,
  });

  final String planName;
  final String expiryText;
  final String renewText;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (warm?.surfaceContainer ?? const Color(0xFF261e1b)).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (warm?.tertiary ?? const Color(0xFFffb68c)).withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -80,
                top: -80,
                child: Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (warm?.tertiary ?? const Color(0xFFffb68c)).withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -80,
                bottom: -80,
                child: Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (warm?.primaryContainer ?? const Color(0xFFe37c33)).withValues(alpha: 0.05),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: warm?.tertiary ?? const Color(0xFFffb68c),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        planName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: warm?.onSurface ?? const Color(0xFFefdfdb),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (warm?.onSurfaceVariant ?? const Color(0xFFdcc1b3)).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            warm?.primaryContainer ?? const Color(0xFFe37c33),
                            warm?.tertiaryContainer ?? const Color(0xFFd8824c),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (warm?.primaryContainer ?? const Color(0xFFe37c33)).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onRenew,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              renewText,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: warm?.onPrimary ?? const Color(0xFF522300),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
