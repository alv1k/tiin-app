import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/profile/data/tiin_api_client.dart';
import 'package:hiddify/features/profile/data/tiin_api_client_provider.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/profile_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TiinLoginPage extends HookConsumerWidget {
  const TiinLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final tokenController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.images.logo.svg(width: 120, height: 120),
                    const Gap(16),
                    Text(
                      'TIIN',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Введите ваш ключ подписки',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),
                    TextFormField(
                      controller: tokenController,
                      decoration: InputDecoration(
                        labelText: 'Ключ подписки',
                        hintText: 'Вставьте ваш ключ',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите ключ подписки';
                        }
                        return null;
                      },
                      enabled: !isLoading.value,
                    ),
                    if (errorMessage.value != null) ...[
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                errorMessage.value!,
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Gap(24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                isLoading.value = true;
                                errorMessage.value = null;

                                final token = tokenController.text.trim();
                                final tiinApi = ref.read(tiinApiClientProvider);
                                final url = tiinApi.buildSubscriptionUrl(token);

                                try {
                                  await ref
                                      .read(addProfileNotifierProvider.notifier)
                                      .addManual(
                                        url: url,
                                        userOverride: UserOverride(
                                          name: 'TIIN',
                                          updateInterval: 12,
                                        ),
                                      );

                                  await ref.read(Preferences.introCompleted.notifier).update(true);
                                } catch (e) {
                                  errorMessage.value = 'Ошибка: проверьте ключ и подключение';
                                  isLoading.value = false;
                                }
                              },
                        child: isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Подключиться'),
                      ),
                    ),
                    const Gap(16),
                    TextButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                              await ref.read(Preferences.introCompleted.notifier).update(true);
                            },
                      child: const Text('Пропустить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
