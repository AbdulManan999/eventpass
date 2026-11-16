import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Logs every provider state change in debug builds.
/// Give providers a `name:` so the log is readable.
class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('{"provider": "${provider.name ?? provider.runtimeType}", "newValue": "$newValue"}');
    }
  }
}
