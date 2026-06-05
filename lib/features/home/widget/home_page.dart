import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:hiddify/core/router/dialog/dialog_notifier.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/home/widget/stat_card.dart';
import 'package:hiddify/features/home/widget/subscription_card.dart';
import 'package:hiddify/features/home/widget/warm_bottom_nav.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/features/settings/notifier/config_option/config_option_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/uri_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final warm = Theme.of(context).extension<WarmThemeColors>();
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;
    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (warm?.primaryContainer ?? const Color(0xFFe37c33)).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (warm?.primary ?? const Color(0xFFffb68a)).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _WarmAppBar(ref: ref),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Gap(8),
                        _buildConnectionSection(context, ref, connectionStatus, delay, requiresReconnect, t),
                        const Gap(16),
                        _buildStatsSection(context, ref, delay, t),
                        const Gap(16),
                        _buildSubscriptionSection(context, ref, t),
                        const Gap(100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ConnectionStatus> connectionStatus,
    int delay,
    bool? requiresReconnect,
    dynamic t,
  ) {
    final warm = Theme.of(context).extension<WarmThemeColors>();

    var secureLabel =
        (ref.watch(ConfigOptions.enableWarp) && ref.watch(ConfigOptions.warpDetourMode) == WarpDetourMode.warpOverProxy)
            ? t.connection.secure
            : "";
    if (delay <= 0 || delay > 65000 || connectionStatus.value != const Connected()) {
      secureLabel = "";
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (warm?.primaryContainer ?? const Color(0xFFe37c33)).withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (warm?.primaryContainer ?? const Color(0xFFe37c33)).withValues(alpha: 0.3),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
            _WarmConnectionButton(
              onTap: switch (connectionStatus) {
                AsyncData(value: Connected()) when requiresReconnect == true => () async {
                    final activeProfile = await ref.read(activeProfileProvider.future);
                    return await ref.read(connectionNotifierProvider.notifier).reconnect(activeProfile);
                  },
                AsyncData(value: Disconnected()) || AsyncError() => () async {
                    if (ref.read(activeProfileProvider).valueOrNull == null) {
                      await ref.read(dialogNotifierProvider.notifier).showNoActiveProfile();
                      ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile();
                    }
                    if (await ref.read(dialogNotifierProvider.notifier).showExperimentalFeatureNotice()) {
                      return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
                    }
                  },
                AsyncData(value: Connected()) => () async {
                    if (requiresReconnect == true &&
                        await ref.read(dialogNotifierProvider.notifier).showExperimentalFeatureNotice()) {
                      return await ref
                          .read(connectionNotifierProvider.notifier)
                          .reconnect(await ref.read(activeProfileProvider.future));
                    }
                    return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
                  },
                _ => () {},
              },
              enabled: switch (connectionStatus) {
                AsyncData(value: Connected()) || AsyncData(value: Disconnected()) || AsyncError() => true,
                _ => false,
              },
              connectionStatus: connectionStatus,
            ),
          ],
        ),
        const Gap(16),
        Column(
          children: [
            Text(
              switch (connectionStatus) {
                AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
                AsyncData(value: Connected()) => t.connection.connected,
                AsyncData(value: Connecting()) => t.connection.connecting,
                AsyncData(value: Disconnected()) => t.connection.connect,
                _ => "",
              },
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: warm?.primaryContainer ?? const Color(0xFFe37c33),
                fontFamily: 'Space Grotesk',
              ),
            ),
            if (secureLabel.isNotEmpty) ...[
              const Gap(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.shield_checkmark_16_filled, size: 16, color: warm?.secondary),
                  const Gap(4),
                  Text(
                    secureLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: warm?.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, WidgetRef ref, int delay, dynamic t) {
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final protocol = activeProxy.valueOrNull?.type ?? "VLESS";

    return Column(
      children: [
          StatCard(
            icon: FluentIcons.code_24_regular,
            label: t.components.home.protocol,
            value: protocol,
          ),
      ],
    );
  }

  Widget _buildSubscriptionSection(BuildContext context, WidgetRef ref, dynamic t) {
    return SubscriptionCard(
      planName: t.components.subscriptionInfo.planName,
      expiryText: t.components.subscriptionInfo.expiryText,
      renewText: t.components.subscriptionInfo.renew,
      onRenew: () async {
        await UriUtils.tryLaunch(Uri.parse("https://t.me/tiin_service_bot"));
      },
    );
  }
}

class _WarmAppBar extends StatelessWidget {
  const _WarmAppBar({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();
    final t = ref.watch(translationsProvider).requireValue;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (warm?.surface ?? const Color(0xFF19120f)).withValues(alpha: 0.4),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  t.common.appTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Space Grotesk',
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          warm?.onPrimaryContainer ?? const Color(0xFF512200),
                          warm?.tertiary ?? const Color(0xFFffb68c),
                          warm?.onPrimaryContainer ?? const Color(0xFF512200),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(FluentIcons.add_24_regular, color: warm?.onSurfaceVariant),
                    onPressed: () => ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarmConnectionButton extends StatefulWidget {
  const _WarmConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.connectionStatus,
  });

  final VoidCallback onTap;
  final bool enabled;
  final AsyncValue<ConnectionStatus> connectionStatus;

  @override
  State<_WarmConnectionButton> createState() => _WarmConnectionButtonState();
}

class _WarmConnectionButtonState extends State<_WarmConnectionButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(_WarmConnectionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final status = widget.connectionStatus;
    if (status is AsyncData && (status.value == const Connected() || status.value == const Connecting())) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warm = Theme.of(context).extension<WarmThemeColors>();
    final isConnected = widget.connectionStatus is AsyncData &&
        (widget.connectionStatus as AsyncData).value == const Connected();
    final isConnecting = widget.connectionStatus is AsyncData &&
        (widget.connectionStatus as AsyncData).value == const Connecting();

    final buttonColor = isConnected
        ? (warm?.primaryContainer ?? const Color(0xFFe37c33))
        : const Color(0xFF6b6b6b);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = (isConnected || isConnecting) ? 1.0 + (_pulseController.value * 0.05) : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          width: 224,
          height: 224,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      buttonColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/images/acorn.png',
                    fit: BoxFit.contain,
                    color: buttonColor,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
