import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mrz_sc_nfc_core_platform_interface.dart';

/// An implementation of [MrzScNfcCorePlatform] that uses method channels.
class MethodChannelMrzScNfcCore extends MrzScNfcCorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mrz_sc_nfc_core');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
