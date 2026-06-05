import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_version_entity.freezed.dart';

@Freezed()
class CoreVersionEntity with _$CoreVersionEntity {
  const factory CoreVersionEntity({
    required String version,
    required String releaseTag,
    required bool preRelease,
    required String url,
    required DateTime publishedAt,
    required Map<String, String> assetUrls,
  }) = _CoreVersionEntity;
}
