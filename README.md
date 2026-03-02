# MRZ Scanner (`mrz_sc`)

A highly customizable, federated, on-device Machine Readable Zone (MRZ) hardware scanner for Flutter.

This package provides the core UI components (`PassportScannerPage`, `MrzScannerOverlay`) and abstract interfaces (`IMrzScannerService`). Because of its **Federated Architecture**, it contains *no direct ML dependencies*, keeping your app size incredibly small and giving you the power to choose your preferred processing engine (ML Kit, TFLite, etc.).

## Setup & Setup

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

Because `mrz_sc` is purely the UI and logical abstraction, you **must** provide it with an implementation of `IMrzScannerService` to do the actual scanning.

### 1. Choose an Engine
Add one of the officially supported engine extensions to your `pubspec.yaml`, alongside the core package:

```yaml
dependencies:
  mrz_sc: ^1.0.1
  mrz_sc_mlkit: ^1.0.0  # Uses Google ML Kit (Recommended)
  # OR
  # mrz_sc_tflite: ^1.0.0 # Bring your own TFLite model
```

### 2. The Quick Start (Ready-to-use UI)

For a drop-in solution, use `PassportScannerPage` and inject your chosen engine:

```dart
import 'package:mrz_sc/mrz_sc.dart';
import 'package:mrz_sc_mlkit/mrz_sc_mlkit.dart'; // Import your chosen engine

void startScan(BuildContext context) async {
  final MrzData? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PassportScannerPage(
        // Inject the specific scanner implementation here!
        scannerService: GoogleMlKitMrzScannerService(),
        
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

### 3. Custom Layouts

If you want to build your own custom interface (e.g., adding specific buttons, different overlay shapes, or embedding it as a smaller widget inside another page instead of fullscreen), compose the `MrzScanner` component yourself and pass the service to it:

```dart
import 'package:mrz_sc/mrz_sc.dart';
import 'package:mrz_sc_mlkit/mrz_sc_mlkit.dart';

class MyCustomScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MrzScanner(
      scannerService: GoogleMlKitMrzScannerService(), // Inject engine
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
            const Positioned(
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

## Creating Your Own Custom Engine

If you want to use a different ML framework or a custom cloud API to process the MRZ, simply create a class that implements `IMrzScannerService`. You only need to fulfill two methods (`scanImage` for static files, and `scanCameraImage` for live camera frames) and you can instantly plug it into the `PassportScannerPage`!
