import 'package:flutter/services.dart';

class BackgroundSyncService {
  const BackgroundSyncService();

  static const _channel = MethodChannel('zerotrace_mobile/background_sync');

  Future<void> start() {
    return _channel.invokeMethod<void>('start');
  }

  Future<void> stop() {
    return _channel.invokeMethod<void>('stop');
  }
}
