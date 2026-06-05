import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';
import 'package:hiddify/features/core_update/notifier/core_update_notifier.dart';
import 'package:hiddify/features/core_update/notifier/core_update_state.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CoreUpdateDialog extends HookConsumerWidget {
  const CoreUpdateDialog(this.currentVersion, this.newVersion, {super.key, this.canIgnore = true});

  final String currentVersion;
  final CoreVersionEntity newVersion;
  final bool canIgnore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);
    final updateState = ref.watch(coreUpdateNotifierProvider);

    return AlertDialog(
      title: Text("Core Update"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("A new version of hiddify-core is available."),
          const Gap(8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "Current: ", style: theme.textTheme.bodySmall),
                TextSpan(text: currentVersion, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "New: ", style: theme.textTheme.bodySmall),
                TextSpan(text: newVersion.version, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
          const Gap(16),
          switch (updateState) {
            CoreUpdateStateDownloading(:final progress) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const Gap(4),
                  Text("${(progress * 100).toStringAsFixed(0)}%", style: theme.textTheme.bodySmall),
                ],
              ),
            CoreUpdateStateInstalling() => const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  Gap(8),
                  Text("Installing..."),
                ],
              ),
            CoreUpdateStateError() => Text(
                "Update failed. Please try again.",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
      actions: [
        if (canIgnore && updateState is! CoreUpdateStateDownloading && updateState is! CoreUpdateStateInstalling)
          TextButton(
            onPressed: () async {
              await ref.read(coreUpdateNotifierProvider.notifier).ignoreVersion(newVersion);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(t.common.ignore),
          ),
        if (updateState is! CoreUpdateStateDownloading && updateState is! CoreUpdateStateInstalling)
          TextButton(
            onPressed: () async {
              await ref.read(coreUpdateNotifierProvider.notifier).downloadAndInstall();
            },
            child: Text("Update Now"),
          ),
        if (updateState is! CoreUpdateStateDownloading && updateState is! CoreUpdateStateInstalling)
          TextButton(
            onPressed: () async {
              await UriUtils.tryLaunch(Uri.parse(newVersion.url));
            },
            child: Text("View on GitHub"),
          ),
      ],
    );
  }
}
