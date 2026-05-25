import 'package:hiddify/core/http_client/http_client_provider.dart';
import 'package:hiddify/features/profile/data/tiin_api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tiin_api_client_provider.g.dart';

@riverpod
TiinApiClient tiinApiClient(Ref ref) {
  return TiinApiClient(httpClient: ref.watch(httpClientProvider));
}
