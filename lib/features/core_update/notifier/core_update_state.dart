import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';
import 'package:hiddify/features/core_update/model/core_update_failure.dart';

part 'core_update_state.freezed.dart';

@freezed
class CoreUpdateState with _$CoreUpdateState {
  const factory CoreUpdateState.initial() = CoreUpdateStateInitial;
  const factory CoreUpdateState.checking() = CoreUpdateStateChecking;
  const factory CoreUpdateState.error(CoreUpdateFailure error) = CoreUpdateStateError;
  const factory CoreUpdateState.available(CoreVersionEntity versionInfo) = CoreUpdateStateAvailable;
  const factory CoreUpdateState.downloading(double progress) = CoreUpdateStateDownloading;
  const factory CoreUpdateState.installing() = CoreUpdateStateInstalling;
  const factory CoreUpdateState.notAvailable() = CoreUpdateStateNotAvailable;
  const factory CoreUpdateState.mobileNotification(CoreVersionEntity versionInfo) = CoreUpdateStateMobileNotification;
}
