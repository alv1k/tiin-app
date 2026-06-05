import 'dart:io';

import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/core/utils/preferences_utils.dart';
import 'package:hiddify/features/core_update/data/core_update_data_providers.dart';
import 'package:hiddify/features/core_update/model/core_update_failure.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';
import 'package:hiddify/features/core_update/notifier/core_update_state.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:version/version.dart';

part 'core_update_notifier.g.dart';

String _getCoreFileName() {
  if (PlatformUtils.isWindows) return 'hiddify-core.dll';
  if (PlatformUtils.isMacOS) return 'hiddify-core.dylib';
  if (PlatformUtils.isLinux) return 'hiddify-core.so';
  return 'hiddify-core';
}

String _getArchiveExtension() {
  if (PlatformUtils.isWindows) return '.zip';
  return '.tar.gz';
}

String _getPlatformAssetKey() {
  if (PlatformUtils.isWindows) return 'windows';
  if (PlatformUtils.isLinux) return 'linux';
  if (PlatformUtils.isMacOS) return 'macos';
  if (PlatformUtils.isAndroid) return 'android';
  if (PlatformUtils.isIOS) return 'ios';
  return 'unknown';
}

@Riverpod(keepAlive: true)
class CoreUpdateNotifier extends _$CoreUpdateNotifier with AppLogger {
  @override
  CoreUpdateState build() => const CoreUpdateState.initial();

  PreferencesEntry<String?, dynamic> get _ignoreCoreVersionPref => PreferencesEntry(
        preferences: ref.read(sharedPreferencesProvider).requireValue,
        key: 'ignored_core_version',
        defaultValue: null,
      );

  String _getCurrentCoreVersion() {
    try {
      final file = File(p.join('dependencies.properties'));
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final match = RegExp(r'core\.version=(\S+)').firstMatch(content);
        return match?.group(1) ?? '0.0.0';
      }
    } catch (_) {}
    return '0.0.0';
  }

  Future<CoreUpdateState> check() async {
    loggy.debug("checking for core update");
    state = const CoreUpdateState.checking();

    if (PlatformUtils.isMobile) {
      return _checkMobile();
    }
    return _checkDesktop();
  }

  Future<CoreUpdateState> _checkMobile() async {
    return ref
        .watch(coreUpdateRepositoryProvider)
        .getLatestVersion()
        .match(
          (err) {
            loggy.warning("failed to get latest core version", err);
            return state = CoreUpdateState.error(err);
          },
          (remote) {
            try {
              final latestVersion = Version.parse(remote.version);
              final currentVersion = Version.parse(_getCurrentCoreVersion());
              if (latestVersion > currentVersion) {
                loggy.debug("new core version available: ${remote.version}");
                return state = CoreUpdateState.mobileNotification(remote);
              }
              loggy.info("already using latest core version[$currentVersion], remote: [${remote.version}]");
              return state = const CoreUpdateState.notAvailable();
            } catch (error, stackTrace) {
              loggy.warning("error parsing core versions", error, stackTrace);
              return state = CoreUpdateState.error(CoreUpdateFailure.unexpected(error, stackTrace));
            }
          },
        )
        .run();
  }

  Future<CoreUpdateState> _checkDesktop() async {
    return ref
        .watch(coreUpdateRepositoryProvider)
        .getLatestVersion()
        .match(
          (err) {
            loggy.warning("failed to get latest core version", err);
            return state = CoreUpdateState.error(err);
          },
          (remote) {
            try {
              final latestVersion = Version.parse(remote.version);
              final currentVersion = Version.parse(_getCurrentCoreVersion());
              if (latestVersion > currentVersion) {
                if (remote.version == _ignoreCoreVersionPref.read()) {
                  loggy.debug("ignored core release [${remote.version}]");
                  return state = const CoreUpdateState.notAvailable();
                }
                loggy.debug("new core version available: ${remote.version}");
                return state = CoreUpdateState.available(remote);
              }
              loggy.info("already using latest core version[$currentVersion], remote: [${remote.version}]");
              return state = const CoreUpdateState.notAvailable();
            } catch (error, stackTrace) {
              loggy.warning("error parsing core versions", error, stackTrace);
              return state = CoreUpdateState.error(CoreUpdateFailure.unexpected(error, stackTrace));
            }
          },
        )
        .run();
  }

  Future<bool> downloadAndInstall() async {
    final currentState = state;
    if (currentState is! CoreUpdateStateAvailable) return false;

    final remote = currentState.versionInfo;
    final platformKey = _getPlatformAssetKey();
    final downloadUrl = remote.assetUrls[platformKey];
    if (downloadUrl == null) {
      loggy.warning("no asset found for platform: $platformKey");
      state = const CoreUpdateState.error(CoreUpdateFailure.noAssetForPlatform());
      return false;
    }

    final coreDir = _getCoreDirectory();
    if (coreDir == null) {
      loggy.warning("could not determine core directory");
      state = const CoreUpdateState.error(CoreUpdateFailure.installFailed());
      return false;
    }

    final archiveName = 'hiddify-core-$platformKey${_getArchiveExtension()}';
    final archivePath = p.join(coreDir, archiveName);
    final tempDir = Directory(p.join(coreDir, 'update_temp'));
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    tempDir.createSync(recursive: true);

    state = const CoreUpdateState.downloading(0);

    final downloadResult = await ref.read(coreUpdateRepositoryProvider).downloadCore(
          url: downloadUrl,
          destinationPath: archivePath,
          onProgress: (progress) {
            state = CoreUpdateState.downloading(progress);
          },
        ).run();

    if (downloadResult.isLeft()) {
      loggy.warning("failed to download core update");
      state = const CoreUpdateState.error(CoreUpdateFailure.downloadFailed());
      _cleanup(archivePath, tempDir);
      return false;
    }

    state = const CoreUpdateState.installing();

    try {
      await _extractAndInstall(archivePath, tempDir, coreDir);
      _cleanup(archivePath, tempDir);
      loggy.info("core update installed successfully: ${remote.version}");
      state = const CoreUpdateState.notAvailable();
      return true;
    } catch (e, st) {
      loggy.warning("failed to install core update", e, st);
      state = const CoreUpdateState.error(CoreUpdateFailure.installFailed());
      _cleanup(archivePath, tempDir);
      return false;
    }
  }

  String? _getCoreDirectory() {
    if (PlatformUtils.isWindows || PlatformUtils.isLinux || PlatformUtils.isMacOS) {
      return 'tiin_vpn-core/bin';
    }
    return null;
  }

  Future<void> _extractAndInstall(String archivePath, Directory tempDir, String coreDir) async {
    if (PlatformUtils.isWindows) {
      await _extractZip(archivePath, tempDir.path);
    } else {
      await _extractTarGz(archivePath, tempDir.path);
    }

    final coreFileName = _getCoreFileName();
    final extractedFiles = tempDir.listSync(recursive: true);
    final coreFile = extractedFiles.whereType<File>().where((f) => p.basename(f.path) == coreFileName).firstOrNull;

    if (coreFile == null) {
      throw Exception("core binary not found in archive: $coreFileName");
    }

    final targetPath = p.join(coreDir, coreFileName);
    final backupPath = '$targetPath.backup';

    final existingFile = File(targetPath);
    if (existingFile.existsSync()) {
      existingFile.copySync(backupPath);
    }

    coreFile.copySync(targetPath);

    final backupFile = File(backupPath);
    if (backupFile.existsSync()) {
      backupFile.deleteSync();
    }
  }

  Future<void> _extractZip(String zipPath, String destPath) async {
    final result = await Process.run('powershell', [
      '-Command',
      'Expand-Archive -Path "$zipPath" -DestinationPath "$destPath" -Force',
    ]);
    if (result.exitCode != 0) {
      throw Exception("failed to extract zip: ${result.stderr}");
    }
  }

  Future<void> _extractTarGz(String tarPath, String destPath) async {
    final result = await Process.run('tar', ['xzf', tarPath, '-C', destPath]);
    if (result.exitCode != 0) {
      throw Exception("failed to extract tar.gz: ${result.stderr}");
    }
  }

  void _cleanup(String archivePath, Directory tempDir) {
    try {
      final archiveFile = File(archivePath);
      if (archiveFile.existsSync()) {
        archiveFile.deleteSync();
      }
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }

  Future<void> ignoreVersion(CoreVersionEntity version) async {
    await _ignoreCoreVersionPref.write(version.version);
    state = const CoreUpdateState.notAvailable();
  }
}
