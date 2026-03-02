import '../models/mrz_data.dart';
import '../models/nfc_passport_data.dart';

/// Define the interface used by mrz_sc to initiate NFC communication
/// when a passport is scanned. The actual implementation will live
/// in federated extension packages (e.g., mrz_sc_nfc_core).
abstract class INfcPassportReader {
  /// Establish an NFC connection using the BAC unlock codes sourced
  /// from the scanned MRZ data. Parses and returns the chip's data.
  Future<NfcPassportData?> readPassport(MrzData mrzData);

  /// Allows for early cancellation of the NFC session.
  Future<void> cancel();
}
