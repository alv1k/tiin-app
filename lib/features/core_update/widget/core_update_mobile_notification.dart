import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CoreUpdateMobileNotification extends HookConsumerWidget {
  const CoreUpdateMobileNotification(this.newVersion, {super.key});

  final CoreVersionEntity newVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text("Core Update Available"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("A new version of hiddify-core (${newVersion.version}) is available."),
          const Gap(8),
          Text(
            "To update the core, please update the full app from the app store.",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.later),
        ),
        TextButton(
          onPressed: () async {
            await UriUtils.tryLaunch(Uri.parse(newVersion.url));
          },
          child: Text("View Release"),
        ),
      ],
    );
  }
}
