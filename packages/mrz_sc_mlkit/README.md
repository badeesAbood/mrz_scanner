# mrz_sc_mlkit

An official extension package for `mrz_sc` that utilizes **Google ML Kit** for fast, 100% offline, on-device MRZ (Machine Readable Zone) parsing.

By decoupling the engine from the UI, `mrz_sc` keeps your app's base bundle size small. When you need highly accurate passport scanning, simply drop in this package!

## Installation

Add both the core package and this extension to your `pubspec.yaml`:

```yaml
dependencies:
  mrz_sc: ^1.0.1
  mrz_sc_mlkit: ^1.0.0
```

## Setup Requirements

Since this library uses the camera and ML Kit:

**iOS:**
Add to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to scan passport MRZ elements.</string>
```

**Android:**
Ensure your `app/build.gradle` `minSdkVersion` is at least `21`.
Google ML Kit models are downloaded automatically by Google Play Services, meaning the library won't bloat your app size.

## Usage

Simply instantiate the `GoogleMlKitMrzScannerService` and pass it to the UI components provided by the core `mrz_sc` package.

```dart
import 'package:mrz_sc/mrz_sc.dart';
import 'package:mrz_sc_mlkit/mrz_sc_mlkit.dart';

void startScan(BuildContext context) async {
  final MrzData? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PassportScannerPage(
        // Inject the ML Kit Engine!
        scannerService: GoogleMlKitMrzScannerService(),
        
        alignPassportText: 'Align passport MRZ within the box',
      ),
    ),
  );

  if (result != null) {
    print('Scanned MRZ: ${result.documentNumber}');
  }
}
```
