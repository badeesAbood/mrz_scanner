import 'package:camera/camera.dart';
import '../models/mrz_data.dart';

/// Exception thrown when MRZ scanning fails.
class MrzScanException implements Exception {
  final String message;
  MrzScanException(this.message);

  @override
  String toString() => message;
}

abstract class IMrzScannerService {
  /// Scans a file path for MRZ data.
  Future<MrzData?> scanImage(String imagePath);

  /// Scans an active camera frame for MRZ data.
  /// Implementations must handle the conversion from raw [cameraImage]
  /// to their specific format using the provided [cameraDescription].
  Future<MrzData?> scanCameraImage(
    CameraImage cameraImage,
    CameraDescription cameraDescription,
  );
}
