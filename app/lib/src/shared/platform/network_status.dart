import 'package:flutter/services.dart';

class NetworkStatus {
  const NetworkStatus();

  static const _channel = MethodChannel('zerotrace_mobile/network_status');

  Future<bool> isWifiConnected() async {
    return await _channel.invokeMethod<bool>('isWifiConnected') ?? false;
  }
}
