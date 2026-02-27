import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_sc/src/models/mrz_data.dart';
import 'package:mrz_sc/src/services/i_mrz_sc_service.dart';
import 'package:mrz_sc/src/utils/mrz_parser.dart';

/// A concrete implementation of [IMrzScannerService] using Google ML Kit.
///
/// This service uses the local, on-device `TextRecognizer` to extract raw text
/// from camera frames or image files, and parses the text searching for a valid
/// 2-line Machine Readable Zone (MRZ) formatted according to ICAO Document 9303 (TD3).
class GoogleMlKitMrzScannerService implements IMrzScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Scans an image file from the given [imagePath] for MRZ data.
  ///
  /// Returns an [MrzData] object if MRZ is found and successfully parsed,
  /// otherwise returns `null`. Throws [MrzScanException] on processing errors.
  @override
  Future<MrzData?> scanImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await scanInputImage(inputImage);
    } catch (e) {
      throw MrzScanException('Failed to process image file: $e');
    }
  }

  /// Scans an [InputImage] object for MRZ data.
  ///
  /// Returns an [MrzData] object if MRZ is found and successfully parsed,
  /// otherwise returns `null`. Throws [MrzScanException] on processing errors.
  @override
  Future<MrzData?> scanInputImage(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final fullText = recognizedText.text;

      final mrzLines = MrzParser.findMrzLines(fullText);
      if (mrzLines == null) return null;

      return MrzParser.parseMrz(mrzLines[0], mrzLines[1]);
    } catch (e) {
      throw MrzScanException('Processing error during OCR: $e');
    }
  }

  /// Optional: dispose method if we ever want to close the recognizer manually
  void dispose() {
    _textRecognizer.close();
  }
}
