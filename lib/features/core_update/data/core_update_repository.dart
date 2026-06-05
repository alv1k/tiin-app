import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/core_update/data/core_release_parser.dart';
import 'package:hiddify/features/core_update/model/core_update_failure.dart';
import 'package:hiddify/features/core_update/model/core_version_entity.dart';
import 'package:hiddify/utils/utils.dart';

abstract interface class CoreUpdateRepository {
  TaskEither<CoreUpdateFailure, CoreVersionEntity> getLatestVersion({
    bool includePreReleases = false,
  });

  TaskEither<CoreUpdateFailure, String> downloadCore({
    required String url,
    required String destinationPath,
    required void Function(double progress) onProgress,
  });
}

class CoreUpdateRepositoryImpl with ExceptionHandler, InfraLogger implements CoreUpdateRepository {
  CoreUpdateRepositoryImpl({required this.httpClient});

  final DioHttpClient httpClient;

  @override
  TaskEither<CoreUpdateFailure, CoreVersionEntity> getLatestVersion({
    bool includePreReleases = false,
  }) {
    return exceptionHandler(() async {
      final response = await httpClient.get<List>(Constants.coreGithubReleasesApiUrl);
      if (response.statusCode != 200 || response.data == null) {
        loggy.warning("failed to fetch latest core version info");
        return left(const CoreUpdateFailure.unexpected());
      }

      final releases = response.data!.map((e) => CoreReleaseParser.parse(e as Map<String, dynamic>));
      late CoreVersionEntity latest;
      if (includePreReleases) {
        latest = releases.first;
      } else {
        latest = releases.firstWhere((e) => e.preRelease == false);
      }
      return right(latest);
    }, CoreUpdateFailure.unexpected);
  }

  @override
  TaskEither<CoreUpdateFailure, String> downloadCore({
    required String url,
    required String destinationPath,
    required void Function(double progress) onProgress,
  }) {
    return exceptionHandler(() async {
      final response = await httpClient.download(
        url,
        destinationPath,
        cancelToken: null,
      );
      if (response.statusCode != 200) {
        loggy.warning("failed to download core: ${response.statusCode}");
        return left(const CoreUpdateFailure.downloadFailed());
      }
      return right(destinationPath);
    }, CoreUpdateFailure.unexpected);
  }
}
