import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StealthOptionsPage extends HookConsumerWidget {
  const StealthOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final stealth = t.pages.settings.routing.stealth;

    return Scaffold(
      appBar: AppBar(title: Text(stealth.title)),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: Text(stealth.enableStealth),
            subtitle: Text(stealth.enableStealthMsg),
            secondary: const Icon(Icons.shield_rounded),
            value: ref.watch(ConfigOptions.stealthMode),
            onChanged: (value) {
              ref.read(ConfigOptions.stealthMode.notifier).update(value);
              if (value) {
                ref.read(ConfigOptions.disableIPv6.notifier).update(true);
                ref.read(ConfigOptions.enableUTLS.notifier).update(true);
                ref.read(ConfigOptions.blockQUIC.notifier).update(true);
              }
            },
          ),
          const Divider(),
          SwitchListTile.adaptive(
            title: Text(stealth.disableIPv6),
            subtitle: Text(stealth.disableIPv6Msg),
            secondary: const Icon(Icons.looks_6_rounded),
            value: ref.watch(ConfigOptions.disableIPv6),
            onChanged: ref.read(ConfigOptions.disableIPv6.notifier).update,
          ),
          SwitchListTile.adaptive(
            title: Text(stealth.enableUTLS),
            subtitle: Text(stealth.enableUTLSMsg),
            secondary: const Icon(Icons.fingerprint_rounded),
            value: ref.watch(ConfigOptions.enableUTLS),
            onChanged: ref.read(ConfigOptions.enableUTLS.notifier).update,
          ),
          SwitchListTile.adaptive(
            title: Text(stealth.blockQUIC),
            subtitle: Text(stealth.blockQUICMsg),
            secondary: const Icon(Icons.block_rounded),
            value: ref.watch(ConfigOptions.blockQUIC),
            onChanged: ref.read(ConfigOptions.blockQUIC.notifier).update,
          ),
          SwitchListTile.adaptive(
            title: Text(stealth.hideVPNNotification),
            subtitle: Text(stealth.hideVPNNotificationMsg),
            secondary: const Icon(Icons.notifications_off_rounded),
            value: ref.watch(ConfigOptions.hideVPNNotification),
            onChanged: ref.read(ConfigOptions.hideVPNNotification.notifier).update,
          ),
        ],
      ),
    );
  }
}
