import 'package:dartx/dartx.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';

abstract class CoreReleaseParser {
  static const _platformPatterns = {
    'windows': ['windows-amd64', 'windows-x64', 'win-amd64', 'win-x64'],
    'linux': ['linux-amd64', 'linux-x64', 'linux-arm64', 'linux-aarch64'],
    'macos': ['macos', 'macos-universal', 'darwin', 'darwin-universal', 'osx'],
    'android': ['android', 'android-aar'],
    'ios': ['ios', 'ios-xcframework'],
  };

  static CoreVersionEntity parse(Map<String, dynamic> json) {
    final fullTag = json['tag_name'] as String;
    final version = fullTag.removePrefix("v");
    final preRelease = json["prerelease"] as bool;
    final publishedAt = DateTime.parse(json["published_at"] as String);
    final htmlUrl = json["html_url"] as String;

    final assets = (json["assets"] as List<dynamic>?) ?? [];
    final assetUrls = <String, String>{};
    for (final asset in assets) {
      final assetMap = asset as Map<String, dynamic>;
      final name = assetMap["name"] as String? ?? "";
      final downloadUrl = assetMap["browser_download_url"] as String? ?? "";
      if (downloadUrl.isEmpty) continue;

      for (final entry in _platformPatterns.entries) {
        for (final pattern in entry.value) {
          if (name.toLowerCase().contains(pattern)) {
            assetUrls[entry.key] = downloadUrl;
            break;
          }
        }
      }
    }

    return CoreVersionEntity(
      version: version,
      releaseTag: fullTag,
      preRelease: preRelease,
      url: htmlUrl,
      publishedAt: publishedAt,
      assetUrls: assetUrls,
    );
  }

  static String getPlatformKey() {
    return 'unknown';
  }
}
