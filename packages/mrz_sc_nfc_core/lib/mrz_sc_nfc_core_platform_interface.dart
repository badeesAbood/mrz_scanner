import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mrz_sc_nfc_core_method_channel.dart';

abstract class MrzScNfcCorePlatform extends PlatformInterface {
  /// Constructs a MrzScNfcCorePlatform.
  MrzScNfcCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static MrzScNfcCorePlatform _instance = MethodChannelMrzScNfcCore();

  /// The default instance of [MrzScNfcCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelMrzScNfcCore].
  static MrzScNfcCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MrzScNfcCorePlatform] when
  /// they register themselves.
  static set instance(MrzScNfcCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
