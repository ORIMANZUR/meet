import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String? imageUrl, {
    required Color borderColor,
    double size = 150, // Increased size for better quality
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size / 2;
    final double borderWidth = size * 0.1; // 10% border
    final double imageRadius = radius - borderWidth;

    // Draw Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(radius, radius + 5), radius, shadowPaint);

    // Draw Border
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    // Draw Image
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ui.Image image = await _loadImage(imageUrl);
        
        // Create circular clip
        final Path clipPath = Path()
          ..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: imageRadius));
        canvas.clipPath(clipPath);

        // Draw and scale image
        final double scale = (imageRadius * 2) / image.width;
        // Ensure we cover the circle (maintain aspect ratio)
        final double imageAspect = image.width / image.height;
        final double targetSize = imageRadius * 2;
        
        double drawWidth, drawHeight;
        if (imageAspect > 1) {
           drawHeight = targetSize;
           drawWidth = targetSize * imageAspect;
        } else {
           drawWidth = targetSize;
           drawHeight = targetSize / imageAspect;
        }
        
        // Center the image
        final double dx = radius - (drawWidth / 2);
        final double dy = radius - (drawHeight / 2);

        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(dx, dy, drawWidth, drawHeight),
          image: image,
          fit: BoxFit.cover,
        );
      } catch (e) {
        debugPrint('Error creating marker image: $e');
        _drawFallback(canvas, radius, imageRadius);
      }
    } else {
      _drawFallback(canvas, radius, imageRadius);
    }

    // Convert to BitmapDescriptor
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  static void _drawFallback(Canvas canvas, double radius, double imageRadius) {
    final Paint paint = Paint()..color = Colors.grey[800]!;
    canvas.drawCircle(Offset(radius, radius), imageRadius, paint);
    
    // Draw initial or icon if needed
    // For now simplistic fallback
  }

  static Future<ui.Image> _loadImage(String url) async {
    final Completer<ui.Image> completer = Completer();
    
    // Using NetworkAssetBundle to fetch bytes
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
        completer.complete(img);
      });
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }
}
