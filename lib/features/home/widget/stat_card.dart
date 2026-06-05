import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/core/widget/glass_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: warm?.primaryContainer ?? const Color(0xFFe37c33)),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: warm?.onSurfaceVariant ?? const Color(0xFFdcc1b3),
            ),
          ),
          const Spacer(),
          if (trailing != null)
            trailing!
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFe37c33),
                fontFamily: 'JetBrains Mono',
              ),
            ),
        ],
      ),
    );
  }
}
