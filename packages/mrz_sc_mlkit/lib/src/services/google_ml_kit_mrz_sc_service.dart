import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_sc/mrz_sc.dart';

/// An implementation of [IMrzScannerService] that uses Google's ML Kit
/// Text Recognition v2 engine to process and extract MRZ data.
///
/// This service requires Google Play Services on Android but operates
/// 100% locally on-device.
class GoogleMlKitMrzScannerService implements IMrzScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<MrzData?> scanImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final fullText = recognizedText.text;

      final mrzLines = MrzParser.findMrzLines(fullText);
      if (mrzLines == null) return null;

      return MrzParser.parseMrz(mrzLines[0], mrzLines[1]);
    } catch (e) {
      throw MrzScanException('Failed to process image file: $e');
    }
  }

  /// Scans a raw [CameraImage] streamed from the camera.
  /// Converts the raw frame into Google ML Kit's [InputImage] format.
  @override
  Future<MrzData?> scanCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    try {
      final inputImage = _inputImageFromCameraImage(image, camera);
      if (inputImage == null) return null;

      final recognizedText = await _textRecognizer.processImage(inputImage);
      final fullText = recognizedText.text;

      final mrzLines = MrzParser.findMrzLines(fullText);
      if (mrzLines == null) return null;

      return MrzParser.parseMrz(mrzLines[0], mrzLines[1]);
    } catch (e) {
      throw MrzScanException('Processing error during OCR: $e');
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + sensorOrientation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - sensorOrientation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  /// Closes the underlying ML Kit TextRecognizer to release memory resources.
  void dispose() {
    _textRecognizer.close();
  }
}
