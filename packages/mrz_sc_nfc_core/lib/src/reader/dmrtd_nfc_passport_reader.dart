import 'package:dmrtd/dmrtd.dart';
import 'package:mrz_sc/mrz_sc.dart';

import '../native_nfc_provider.dart';

class DmrtdNfcPassportReader implements INfcPassportReader {
  final NativeNfcProvider _nfcProvider = NativeNfcProvider();

  @override
  Future<NfcPassportData?> readPassport(MrzData mrzData) async {
    try {
      // Clean padding from MRZ if necessary
      final docNum = mrzData.documentNumber.replaceAll('<', '');

      // 2. Open hardware tunnel
      await _nfcProvider.connect();

      // 3. Initiate dmrtd Passport Secure Messaging
      final passport = Passport(_nfcProvider);
      final dbak = DBAKey(docNum, mrzData.dateOfBirth, mrzData.expirationDate);
      await passport.startSession(dbak); // BAC Auth unlocks the chip

      // 4. Extract standard Data Groups
      final dg1 = await passport.readEfDG1();
      final dg2 = await passport.readEfDG2();

      // Ensure we disconnect gracefully
      await _nfcProvider.disconnect();

      // 5. Construct generic payload model
      return NfcPassportData(
        faceImage: dg2.imageData,
        fullName: '${mrzData.givenNames} ${mrzData.surname}'.trim(),
        rawDg1: dg1.toBytes(),
        rawDg2: dg2.toBytes(),
      );
    } catch (e) {
      await _nfcProvider.disconnect(errorMessage: e.toString());
      rethrow;
    }
  }

  @override
  Future<void> cancel() async {
    await _nfcProvider.disconnect(errorMessage: 'User cancelled');
  }
}
