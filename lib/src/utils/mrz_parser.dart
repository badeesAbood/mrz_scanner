import '../models/mrz_data.dart';

/// A utility class for parsing standard TD3 Machine Readable Zone (MRZ) strings.
class MrzParser {
  /// Finds valid TD3 MRZ lines (two lines of 44 characters) in a raw text string.
  static List<String>? findMrzLines(String text) {
    final lines = text.split('\n').map((l) => l.replaceAll(' ', '')).toList();

    for (int i = 0; i < lines.length - 1; i++) {
      final line1 = lines[i];
      final line2 = lines[i + 1];

      if (line1.length == 44 && line2.length == 44 && line1.startsWith('P')) {
        final mrzRegex = RegExp(r'^[A-Z0-9<]+$');
        if (mrzRegex.hasMatch(line1) && mrzRegex.hasMatch(line2)) {
          return [line1, line2];
        }
      }
    }
    return null;
  }

  /// Parses two standard TD3 MRZ lines into an [MrzData] object.
  static MrzData? parseMrz(String line1, String line2) {
    try {
      final documentType = line1.substring(0, 2).replaceAll('<', '');
      final countryCode = line1.substring(2, 5).replaceAll('<', '');

      final namesString = line1.substring(5);
      final nameParts = namesString.split('<<');
      final surname = nameParts.isNotEmpty
          ? nameParts[0].replaceAll('<', ' ').trim()
          : '';
      final givenNames = nameParts.length > 1
          ? nameParts[1].replaceAll('<', ' ').trim()
          : '';

      final documentNumber = line2.substring(0, 9).replaceAll('<', '');
      final nationality = line2.substring(10, 13).replaceAll('<', '');

      final dobRaw = line2.substring(13, 19);
      final dob = parseDate(dobRaw, isDob: true);

      final sex = line2.substring(20, 21);

      final expirationRaw = line2.substring(21, 27);
      final expirationDate = parseDate(expirationRaw, isDob: false);

      final personalNumber = line2.substring(28, 42).replaceAll('<', '');

      if (dob == null || expirationDate == null) {
        return null;
      }

      return MrzData(
        documentType: documentType.isEmpty ? 'P' : documentType,
        countryCode: countryCode,
        surname: surname,
        givenNames: givenNames,
        documentNumber: documentNumber,
        nationalityCountryCode: nationality,
        dateOfBirth: dob,
        sex: sex == '<' ? 'Unknown' : sex,
        expirationDate: expirationDate,
        personalNumber: personalNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parses a generic YYMMDD date format based on heuristics.
  static DateTime? parseDate(String yymmdd, {required bool isDob}) {
    if (yymmdd.length != 6 || yymmdd.contains('<')) return null;

    try {
      final yy = int.parse(yymmdd.substring(0, 2));
      final mm = int.parse(yymmdd.substring(2, 4));
      final dd = int.parse(yymmdd.substring(4, 6));

      final currentYearStr = DateTime.now().year.toString();
      final currentCenturyRaw = currentYearStr.substring(0, 2);
      final currentDecadeRaw = currentYearStr.substring(2, 4);

      int year;
      if (isDob) {
        if (yy > int.parse(currentDecadeRaw)) {
          year = int.parse('${int.parse(currentCenturyRaw) - 1}') * 100 + yy;
        } else {
          year = int.parse(currentCenturyRaw) * 100 + yy;
        }
      } else {
        year = int.parse(currentCenturyRaw) * 100 + yy;
      }

      return DateTime(year, mm, dd);
    } catch (e) {
      return null;
    }
  }
}
