import 'package:hiddify/core/http_client/http_client_provider.dart';
import 'package:hiddify/features/core_update/data/core_update_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'core_update_data_providers.g.dart';

@Riverpod(keepAlive: true)
CoreUpdateRepository coreUpdateRepository(CoreUpdateRepositoryRef ref) {
  return CoreUpdateRepositoryImpl(httpClient: ref.watch(httpClientProvider));
}
