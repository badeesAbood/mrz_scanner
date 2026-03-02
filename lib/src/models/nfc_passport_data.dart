import 'dart:typed_data';

/// The final parsed data retrieved from the NFC chip of an ePassport.
class NfcPassportData {
  /// The biometric image of the passport holder (typically JPEG or JPEG2000).
  final Uint8List? faceImage;

  /// Full name recorded in the chip.
  final String? fullName;

  /// Raw byte arrays stored inside Data Group 1 and Data Group 2, if needed for forensic verification.
  final Uint8List? rawDg1;
  final Uint8List? rawDg2;

  const NfcPassportData({
    this.faceImage,
    this.fullName,
    this.rawDg1,
    this.rawDg2,
  });
}
