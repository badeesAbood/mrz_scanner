import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/mrz_data.dart';
import '../services/i_mrz_sc_service.dart';

/// Builder function for creating the scanner UI overlay.
typedef MrzOverlayBuilder =
    Widget Function(BuildContext context, bool isDetecting);

/// A headless MRZ scanner widget that handles camera initialization and
/// Machine Readable Zone (MRZ) frame processing.
///
/// It allows full UI customization via the [builder] parameter while
/// managing the lifecycle of the camera controller and vision tools internally.
class MrzScanner extends StatefulWidget {
  /// The scanning logic engine (e.g. Google ML Kit, TFLite).
  final IMrzScannerService scannerService;

  /// Callback triggered when valid MRZ data is successfully scanned.
  final void Function(MrzData mrzData) onSuccess;

  /// Callback triggered when a scanning error occurs.
  final void Function(Exception e)? onError;

  /// A function that returns the UI layer (overlay) stacked on top of the camera stream.
  final MrzOverlayBuilder builder;

  /// Creates a customizable MRZ hardware scanner.
  const MrzScanner({
    super.key,
    required this.scannerService,
    required this.onSuccess,
    required this.builder,
    this.onError,
  });

  @override
  State<MrzScanner> createState() => _MrzScannerState();
}

class _MrzScannerState extends State<MrzScanner> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isBusy = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller?.initialize();
      if (!mounted) return;

      setState(() {});

      _controller?.startImageStream(_processCameraFrame);
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(MrzScanException('Failed to initialize camera'));
      }
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isBusy || !mounted) return;
    _isBusy = true;

    try {
      setState(() {
        _isDetecting = true;
      });

      final result = await widget.scannerService.scanCameraImage(
        image,
        _controller!.description,
      );

      if (!mounted) return;

      if (result != null) {
        _controller?.stopImageStream();
        widget.onSuccess(result);
      }
    } catch (e) {
      if (mounted && widget.onError != null) {
        widget.onError!(MrzScanException('Camera frame processing error'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
      _isBusy = false;
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        widget.builder(context, _isDetecting),
      ],
    );
  }
}
