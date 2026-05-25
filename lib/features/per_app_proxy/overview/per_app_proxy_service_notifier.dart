import 'dart:async';

import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/notification/in_app_notification_controller.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/selected_data_provider.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/per_app_proxy/model/pkg_flag.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_notifier.dart';
import 'package:installed_apps/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'per_app_proxy_service_notifier.g.dart';

const _presetExcludePackages = [
  'ru.dublgis.dgismobile',
  'ru.ozon.app.android',
  'ru.wildberries',
  'ru.rostel',
  'ru.gosuslugi',
  'ru.fns.lkfl',
  'com.gosuslugi',
  'com.android.vending',
  'ru.sberbank.mobile',
  'ru.tinkoff',
  'com.vtb24.online',
  'ru.alfabank.mobile',
  'ru.gazprombank.android',
  'com.openbank',
  'com.aliexpress.ru',
  'ru.beru',
  'com.avito.android',
  'ru.yandex.taxi',
  'ru.yandex.yandexmaps',
  'com.citymobil',
  'ru.foodfox.app',
  'com.yandex.delivery',
  'ru.sbermarket.app',
  'org.telegram.messenger',
  'com.vkontakte.android',
  'ru.ok.android',
  'ru.mail.mailapp',
  'ru.yandex.searchplugin',
  'ru.yandex.music',
  'ru.ivi.client',
  'ru.okko.app',
  'ru.kinopoisk',
  'ru.yandex.zen',
  'ru.yandex.mail',
  'com.boonmarket',
  'ru.ykt.doska',
  'com.aoomost.most',
  'com.punicapp.whoosh',
  'com.drivee.taxi.rides',
  'ru.hh.android',
  'ru.albank.tk.app',
  'ru.albank.online.aebit',
  'ru.smmd.superdelivery',
  'com.fsgpay',
  'ru.scid.minicen',
  'com.nvk.sakhs',
  'ru.pyaterechka.app.browser',
  'io.ionic.stng',
  'su.pkc.tnazs',
  'com.yandex.iot',
  'ru.bus62SmartTransport',
  'com.iserv.JKHMobileCabinet.yakutEnergy',
  'com.iserv.JKHMobileCabinet.PrimEnergy',
  'com.iserv.JKHMobileCabinet.fareastWarm',
  'ru.raiffeisen.newsapp',
  'ru.pochta.bank',
  'ru.mtsbank.mobile',
  'ru.rshb.dbo',
  'ru.comcard',
  'ru.unicredit',
];

const _presetInitializedKey = 'per_app_proxy_preset_initialized';

@riverpod
class PerAppProxyService extends _$PerAppProxyService {
  StreamSubscription? _includeSubscription;
  StreamSubscription? _excludeSubscription;
  Timer? _timer;
  @override
  Future<void> build() async {
    final phonePkgs = (await InstalledApps.getInstalledApps(false)).map((e) => e.packageName).toSet();
    _includeSubscription = ref
        .read(appProxyDataSourceProvider)
        .watchActivePackages(phonePkgs: phonePkgs, mode: AppProxyMode.include)
        .listen((pkgs) => ref.read(Preferences.includeApps.notifier).update(pkgs));
    _excludeSubscription = ref
        .read(appProxyDataSourceProvider)
        .watchActivePackages(phonePkgs: phonePkgs, mode: AppProxyMode.exclude)
        .listen((pkgs) => ref.read(Preferences.excludeApps.notifier).update(pkgs));

    _timer = Timer.periodic(const Duration(days: 1), (_) async => await _autoSelectionUpdate());
    ref.onDispose(() {
      _includeSubscription?.cancel();
      _excludeSubscription?.cancel();
      _timer?.cancel();
    });
    await _applyPresetIfNeeded(phonePkgs);
    await _autoSelectionUpdate();
  }

  Future<void> _applyPresetIfNeeded(Set<String> phonePkgs) async {
    final prefs = ref.read(sharedPreferencesProvider).requireValue;
    if (prefs.getBool(_presetInitializedKey) == true) return;
    final installedPresets = _presetExcludePackages.where(phonePkgs.contains).toList();
    if (installedPresets.isEmpty) return;
    await ref.read(Preferences.perAppProxyMode.notifier).update(PerAppProxyMode.exclude);
    final ds = ref.read(appProxyDataSourceProvider);
    for (final pkg in installedPresets) {
      await ds.updatePkg(pkg: pkg, mode: AppProxyMode.exclude);
    }
    await prefs.setBool(_presetInitializedKey, true);
  }

  Future<void> _autoSelectionUpdate() async {
    final autoRegion = ref.read(Preferences.autoAppsSelectionRegion);
    if (autoRegion == null) return;
    final mode = ref.read(Preferences.perAppProxyMode).toAppProxy();
    final lastUpdate = ref.read(Preferences.autoAppsSelectionLastUpdate);
    final days = ref.read(Preferences.autoAppsSelectionUpdateInterval).round();
    final interval = Duration(days: days);
    if (mode != null && (lastUpdate == null || DateTime.now().difference(lastUpdate) > interval)) {
      final rs = await ref.read(PerAppProxyProvider(mode).notifier).applyAutoSelection();
      if (rs) {
        final t = ref.read(translationsProvider).requireValue;
        ref
            .read(inAppNotificationControllerProvider)
            .showSuccessToast(t.pages.settings.routing.perAppProxy.autoSelection.toast.success);
      }
    }
  }
}
