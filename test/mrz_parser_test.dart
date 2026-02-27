import 'package:flutter_test/flutter_test.dart';
import 'package:mrz_sc/src/utils/mrz_parser.dart';

void main() {
  group('MrzParser', () {
    test(
      'findMrzLines should correctly extract 2 valid lines from noisy OCR text',
      () {
        final text = '''
      REPUBLIQUE FRANCAISE
      PASSEPORT
      P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<<<<<<<<<
      C01X0022G2D<<6408125F1710319<<<<<<<<<<<<<<<0
      P A S S E P O R T
      ''';

        final lines = MrzParser.findMrzLines(text);

        expect(lines, isNotNull);
        expect(lines!.length, 2);
        expect(lines[0], 'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<<<<<<<<<');
        expect(lines[1], 'C01X0022G2D<<6408125F1710319<<<<<<<<<<<<<<<0');
      },
    );

    test(
      'findMrzLines should ignore spaces dynamically added by OCR inside the MRZ',
      () {
        final text = '''
      P< D<< M UST ERMA NN<< E RIKA<<<<<<<<< <<<<<<<<<<<<<
      C 01X0 022G2D<< 6408 125F 171 0319<<< <<<<<<<<<<<<0
      ''';

        final lines = MrzParser.findMrzLines(text);

        expect(lines, isNotNull);
        expect(lines![0].length, 44);
        expect(lines[1].length, 44);
      },
    );

    test('findMrzLines should return null if no valid MRZ is found', () {
      final text = '''
      JUST SOME RANDOM TEXT
      THAT HAS NO MRZ LINES
      1123123123
      ''';

      final lines = MrzParser.findMrzLines(text);
      expect(lines, isNull);
    });

    test('parseMrz should accurately map TD3 strings to MrzData', () {
      final line1 = 'P<D<<MUSTERMANN<<ERIKA<<<<<<<<<<<<<<<<<<<<<<';
      final line2 = 'C01X0022G2D<<6408125F1710319<<<<<<<<<<<<<<<0';

      final data = MrzParser.parseMrz(line1, line2);

      expect(data, isNotNull);
      expect(data!.documentType, 'P');
      expect(data.countryCode, 'D');
      expect(data.surname, 'MUSTERMANN');
      expect(data.givenNames, 'ERIKA');
      expect(data.documentNumber, 'C01X0022G');
      expect(data.nationalityCountryCode, 'D');
      expect(data.sex, 'F');
      expect(data.personalNumber, '');

      // Check dates
      expect(data.dateOfBirth.year, 1964);
      expect(data.dateOfBirth.month, 8);
      expect(data.dateOfBirth.day, 12);

      expect(data.expirationDate.year, 2017);
      expect(data.expirationDate.month, 10);
      expect(data.expirationDate.day, 31);
    });

    test(
      'parseDate should correctly assign century based on DOB vs Expiry heuristics',
      () {
        // Current year heuristic context (assuming run in 2026, decade is 26)

        // DOB of 85 (e.g., 1985)
        final dob1 = MrzParser.parseDate('850101', isDob: true);
        expect(
          dob1?.year,
          1985,
        ); // Since 85 > current decade (26), must be 1900s

        // DOB of 15 (e.g., 2015)
        final dob2 = MrzParser.parseDate('150101', isDob: true);
        expect(dob2?.year, 2015); // Since 15 < 26, must be 2000s

        // Expiration of 30 (e.g., 2030)
        final exp1 = MrzParser.parseDate('300101', isDob: false);
        expect(
          exp1?.year,
          2030,
        ); // Expirations are generally the current century
      },
    );

    test('parseMrz should return null if passed invalid lines', () {
      final data = MrzParser.parseMrz('INVALID', 'SHORT');
      expect(data, isNull);
    });
  });
}
