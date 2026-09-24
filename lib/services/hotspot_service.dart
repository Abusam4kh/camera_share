import 'package:flutter/services.dart';

class HotspotService {
  static const _channel =
      MethodChannel('camera_share/system');

  static Future<void>
      openHotspotSettings() async {
    try {
      await _channel.invokeMethod<void>(
        'openHotspotSettings',
      );
    } on PlatformException {
      await _channel.invokeMethod<void>(
        'openWirelessSettings',
      );
    }
  }
}
