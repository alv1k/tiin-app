import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_update_failure.freezed.dart';

@freezed
sealed class CoreUpdateFailure with _$CoreUpdateFailure {
  const factory CoreUpdateFailure.unexpected([Object? error, StackTrace? stackTrace]) = CoreUpdateUnexpectedFailure;
  const factory CoreUpdateFailure.noAssetForPlatform() = CoreUpdateNoAssetFailure;
  const factory CoreUpdateFailure.downloadFailed() = CoreUpdateDownloadFailure;
  const factory CoreUpdateFailure.installFailed() = CoreUpdateInstallFailure;
}
