# MRZ Scanner

A highly customizable, on-device Machine Readable Zone (MRZ) hardware scanner for Flutter, powered by Google ML Kit.

This package provides both a ready-to-use full-screen passport scanner, and highly decoupled widget building blocks so you can design your own custom scanning UI.

## Features
- **On-Device OCR**: Fast text recognition powered by Google ML Kit without making network calls.
- **Accurate Parsing**: Automatically finds and parses standard 2-line TD3 MRZ codes (like passports) even with image distortion or extra text.
- **Ready-to-Use UI**: Includes a fully functional `PassportScannerPage` for a quick integration.
- **Highly Customizable**: Decoupled `MrzScanner` logic controller and customizable `MrzScannerOverlay` widget. Let's you design literally whatever UI you want on top of the camera stream.

## Setup

Since this package uses the device camera, you need to configure permissions for both iOS and Android.

### iOS Configuration
Add the following keys to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to scan passport MRZ elements.</string>
```

### Android Configuration
Ensure your `android/app/build.gradle` has a minimum SDK version of at least `21`.

## Usage

### 1. The Quick Start (Ready-to-use UI)

For a drop-in solution, use `PassportScannerPage`:

```dart
import 'package:mrz_scanner/mrz_scanner.dart';

void startScan(BuildContext context) async {
  final MrzData? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PassportScannerPage(
        alignPassportText: 'Align passport MRZ within the box',
        passportDetectedText: 'Passport Detected!',
        processingErrorText: 'Processing Error',
      ),
    ),
  );

  if (result != null) {
    print('Scanned Document: ${result.documentNumber}');
    print('First Name: ${result.givenNames}');
  }
}
```

### 2. Custom Layouts

If you want to build your own custom interface (e.g., adding specific buttons, different overlay shapes, or embedding it as a smaller widget inside another page instead of fullscreen), compose the `MrzScanner` component yourself:

```dart
import 'package:mrz_scanner/mrz_scanner.dart';

class MyCustomScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MrzScanner(
      onSuccess: (mrzData) {
        Navigator.pop(context, mrzData);
      },
      onError: (exception) {
         print(exception);
      },
      builder: (context, isDetecting) {
        return Stack(
          children: [
            // Adds the dimmed background and cutout box
            MrzScannerOverlay(
              borderColor: isDetecting ? Colors.yellow : Colors.white,
            ),
            
            // Your custom UI here
            Positioned(
               bottom: 50,
               child: Text('Scanning...'),
            )
          ]
        );
      },
    );
  }
}
```
