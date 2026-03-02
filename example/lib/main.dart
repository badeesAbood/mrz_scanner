import 'package:flutter/material.dart';
import 'package:mrz_sc/mrz_sc.dart';
import 'package:mrz_sc_mlkit/mrz_sc_mlkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRZ Scanner Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TestScannerPage(),
    );
  }
}

class TestScannerPage extends StatefulWidget {
  const TestScannerPage({super.key});

  @override
  State<TestScannerPage> createState() => _TestScannerPageState();
}

class _TestScannerPageState extends State<TestScannerPage> {
  MrzData? _scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MRZ Scanner Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_scannedData != null) ...[
              Text('Given Name: ${_scannedData!.givenNames}'),
              Text('Surname: ${_scannedData!.surname}'),
              Text('Document Number: ${_scannedData!.documentNumber}'),
              Text('Country Code: ${_scannedData!.countryCode}'),
              Text(
                'Date of Birth: ${_scannedData!.dateOfBirth.toIso8601String().split('T').first}',
              ),
              Text(
                'Expiration Date: ${_scannedData!.expirationDate.toIso8601String().split('T').first}',
              ),
            ] else
              const Text('No Passport Scanned Yet'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PassportScannerPage(
                      scannerService: GoogleMlKitMrzScannerService(),
                    ),
                  ),
                );

                if (result != null && result is MrzData) {
                  setState(() {
                    _scannedData = result;
                  });
                }
              },
              child: const Text('Scan Passport'),
            ),
          ],
        ),
      ),
    );
  }
}
