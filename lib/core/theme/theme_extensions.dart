import 'package:flutter/material.dart';

class ConnectionButtonTheme extends ThemeExtension<ConnectionButtonTheme> {
  const ConnectionButtonTheme({this.idleColor, this.connectedColor});

  final Color? idleColor;
  final Color? connectedColor;

  static const ConnectionButtonTheme light = ConnectionButtonTheme(
    idleColor: Color(0xFF4a4d8b),
    connectedColor: Color(0xFF44a334),
  );

  static const ConnectionButtonTheme warm = ConnectionButtonTheme(
    idleColor: Color(0xFFe37c33),
    connectedColor: Color(0xFF44a334),
  );

  @override
  ThemeExtension<ConnectionButtonTheme> copyWith({Color? idleColor, Color? connectedColor}) => ConnectionButtonTheme(
        idleColor: idleColor ?? this.idleColor,
        connectedColor: connectedColor ?? this.connectedColor,
      );

  @override
  ThemeExtension<ConnectionButtonTheme> lerp(covariant ThemeExtension<ConnectionButtonTheme>? other, double t) {
    if (other is! ConnectionButtonTheme) {
      return this;
    }
    return ConnectionButtonTheme(
      idleColor: Color.lerp(idleColor, other.idleColor, t),
      connectedColor: Color.lerp(connectedColor, other.connectedColor, t),
    );
  }
}

class WarmThemeColors extends ThemeExtension<WarmThemeColors> {
  const WarmThemeColors({
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiary,
    required this.secondary,
    required this.outline,
    required this.outlineVariant,
    required this.glassBorder,
    required this.warmGlow,
  });

  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onTertiary;
  final Color secondary;
  final Color outline;
  final Color outlineVariant;
  final Color glassBorder;
  final Color warmGlow;

  static const WarmThemeColors dark = WarmThemeColors(
    surface: Color(0xFF19120f),
    surfaceContainer: Color(0xFF261e1b),
    surfaceContainerLow: Color(0xFF221a17),
    surfaceContainerHigh: Color(0xFF312825),
    onSurface: Color(0xFFefdfdb),
    onSurfaceVariant: Color(0xFFdcc1b3),
    primary: Color(0xFFffb68a),
    primaryContainer: Color(0xFFe37c33),
    onPrimary: Color(0xFF522300),
    onPrimaryContainer: Color(0xFF512200),
    tertiary: Color(0xFFffb68c),
    tertiaryContainer: Color(0xFFd8824c),
    onTertiary: Color(0xFF532200),
    secondary: Color(0xFFccc6be),
    outline: Color(0xFFa48c7f),
    outlineVariant: Color(0xFF554338),
    glassBorder: Color(0x1affb68a),
    warmGlow: Color(0x4de37c33),
  );

  @override
  ThemeExtension<WarmThemeColors> copyWith() => this;

  @override
  ThemeExtension<WarmThemeColors> lerp(covariant ThemeExtension<WarmThemeColors>? other, double t) {
    if (other is! WarmThemeColors) return this;
    return WarmThemeColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      warmGlow: Color.lerp(warmGlow, other.warmGlow, t)!,
    );
  }
}
