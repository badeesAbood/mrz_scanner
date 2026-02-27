import 'package:flutter/material.dart';

/// A highly customizable overlay for the [MrzScanner].
///
/// It draws a dimmed background over the entire screen and cuts out a clear
/// rectangle in the center, framing the area where the user should hold their document.
class MrzScannerOverlay extends StatelessWidget {
  /// The color of the dimmed background outside the cutout.
  final Color overlayColor;

  /// The color of the corner border braces framing the cutout.
  final Color borderColor;

  /// The width of the corner border braces.
  final double borderStrokeWidth;

  /// The length of the corner border braces.
  final double cornerLength;

  /// The ratio of the cutout's width relative to the screen width.
  /// Defaults to `0.9` (90% of the screen width).
  final double widthRatio;

  /// The aspect ratio (height / width) of the cutout.
  /// Defaults to `0.704` to match standard ID-3 passports (88mm / 125mm).
  final double aspectRatio;

  /// Creates a customizable overlay for document scanning.
  const MrzScannerOverlay({
    super.key,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.white,
    this.borderStrokeWidth = 4.0,
    this.cornerLength = 30.0,
    this.widthRatio = 0.9,
    this.aspectRatio = 0.704,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MrzOverlayPainter(
          overlayColor: overlayColor,
          borderColor: borderColor,
          borderStrokeWidth: borderStrokeWidth,
          cornerLength: cornerLength,
          widthRatio: widthRatio,
          aspectRatio: aspectRatio,
        ),
        child: Container(),
      ),
    );
  }
}

class _MrzOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color borderColor;
  final double borderStrokeWidth;
  final double cornerLength;
  final double widthRatio;
  final double aspectRatio;

  _MrzOverlayPainter({
    required this.overlayColor,
    required this.borderColor,
    required this.borderStrokeWidth,
    required this.cornerLength,
    required this.widthRatio,
    required this.aspectRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boxWidth = size.width * widthRatio;
    final boxHeight = boxWidth * aspectRatio;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      const Radius.circular(16),
    );

    // Draw the dimmed background
    final paint = Paint()..color = overlayColor;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rrect),
      ),
      paint,
    );

    // Draw corner braces
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderStrokeWidth;

    final rect = rrect.outerRect;

    // Top-Left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLength)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerLength, rect.top),
      borderPaint,
    );
    // Top-Right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerLength),
      borderPaint,
    );
    // Bottom-Left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLength)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerLength, rect.bottom),
      borderPaint,
    );
    // Bottom-Right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLength, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MrzOverlayPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderStrokeWidth != borderStrokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.widthRatio != widthRatio ||
        oldDelegate.aspectRatio != aspectRatio;
  }
}
