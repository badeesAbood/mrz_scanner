import 'package:flutter/material.dart';
import '../models/mrz_data.dart';
import 'mrz_sc.dart';
import 'mrz_sc_overlay.dart';

/// A ready-to-use, fullscreen passport scanner page.
///
/// It combines the [MrzScanner] camera logic and the [MrzScannerOverlay]
/// cutout into a simple Scaffold that returns the [MrzData] upon success.
class PassportScannerPage extends StatefulWidget {
  /// The text displayed when the camera is active, asking the user to align the passport.
  final String alignPassportText;

  /// The text displayed when an MRZ is successfully parsed.
  final String passportDetectedText;

  /// The text displayed if a processing error occurs.
  final String processingErrorText;

  /// Creates a ready-to-use passport scanner page.
  const PassportScannerPage({
    super.key,
    this.alignPassportText = 'Align passport MRZ within the box',
    this.passportDetectedText = 'Passport Detected!',
    this.processingErrorText = 'Processing Error',
  });

  @override
  State<PassportScannerPage> createState() => _PassportScannerPageState();
}

class _PassportScannerPageState extends State<PassportScannerPage> {
  late String _scanStatus;
  Color _borderColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _scanStatus = widget.alignPassportText;
  }

  void _onSuccess(MrzData mrzData) {
    setState(() {
      _scanStatus = widget.passportDetectedText;
      _borderColor = Colors.green;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, mrzData);
      }
    });
  }

  void _onError(Exception e) {
    setState(() {
      _scanStatus = widget.processingErrorText;
      _borderColor = Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MrzScanner(
        onSuccess: _onSuccess,
        onError: _onError,
        builder: (context, isDetecting) {
          return Stack(
            fit: StackFit.expand,
            children: [
              MrzScannerOverlay(borderColor: _borderColor),

              // Top Bar Actions
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Status Text
              Positioned(
                bottom: size.height * 0.15,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _scanStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading Indicator
              if (isDetecting && _borderColor != Colors.green)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 20,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
