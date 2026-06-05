import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class WarmBottomNav extends StatelessWidget {
  const WarmBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();

    final items = List.generate(labels.length, (index) {
      final iconData = [
        [FluentIcons.shield_24_filled, FluentIcons.shield_24_regular],
        [FluentIcons.globe_24_filled, FluentIcons.globe_24_regular],
        [FluentIcons.data_histogram_24_filled, FluentIcons.data_histogram_24_regular],
        [FluentIcons.settings_24_filled, FluentIcons.settings_24_regular],
      ][index];
      return _NavItem(iconData[0], iconData[1], labels[index]);
    });

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: (warm?.surfaceContainerLow ?? const Color(0xFF221a17)).withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: isActive ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.inactiveIcon,
                        color: isActive
                            ? warm?.primaryContainer ?? const Color(0xFFe37c33)
                            : (warm?.onSurfaceVariant ?? const Color(0xFFdcc1b3)).withValues(alpha: 0.5),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          color: isActive
                              ? warm?.primaryContainer ?? const Color(0xFFe37c33)
                              : (warm?.onSurfaceVariant ?? const Color(0xFFdcc1b3)).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
}
