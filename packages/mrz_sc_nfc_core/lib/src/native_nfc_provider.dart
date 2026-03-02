import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

// We import the ComProvider interface from dmrtd
import 'package:dmrtd/src/com/com_provider.dart';

class NativeNfcProvider extends ComProvider {
  static final _log = Logger('mrz_sc_nfc_core.provider');
  static const MethodChannel _channel = MethodChannel('mrz_sc_nfc_core');

  bool _isConnected = false;

  NativeNfcProvider() : super(_log) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTagDiscovered':
        _isConnected = true;
        break;
      case 'onError':
        _isConnected = false;
        // Optionally handle async tag drop errors
        break;
    }
  }

  @override
  Future<void> connect() async {
    if (_isConnected) return;
    try {
      await _channel.invokeMethod('startSession');
      // Wait for the native side to call "onTagDiscovered" before we return.
      // Easiest is to poll _isConnected.
      int attempts = 0;
      while (!_isConnected && attempts < 60) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      if (!_isConnected) {
        throw const ComProviderError('NFC connect timeout. No tag discovered.');
      }
    } catch (e) {
      throw ComProviderError('Failed to start session: $e');
    }
  }

  @override
  Future<void> disconnect({String? errorMessage}) async {
    try {
      await _channel.invokeMethod('stopSession', errorMessage);
    } catch (e) {
      // Ignore disconnect errors
    } finally {
      _isConnected = false;
    }
  }

  @override
  bool isConnected() => _isConnected;

  @override
  Future<Uint8List> transceive(Uint8List data) async {
    if (!_isConnected) {
      throw const ComProviderError('Cannot transceive: no tag connected.');
    }
    try {
      final result = await _channel.invokeMethod<Uint8List>('transceive', data);
      if (result == null) {
        throw const ComProviderError('Transceive returned null bytes.');
      }
      return result;
    } catch (e) {
      throw ComProviderError('Transceive failed: $e');
    }
  }
}
