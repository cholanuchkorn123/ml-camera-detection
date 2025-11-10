import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class UtilsScanner {
  UtilsScanner._();

  static Future<CameraDescription> getCamera(
    CameraLensDirection cameraLensDirection,
  ) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription cameraDescription) =>
            cameraDescription.lensDirection == cameraLensDirection,
      ),
    );
  }
  static Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static InputImage buildInputImage(
    CameraImage image,
    CameraController controller,
    InputImageRotation? forceRotation,
  ) {
    final InputImageFormat? format = switch (image.format.group) {
      ImageFormatGroup.yuv420 =>
        Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.yuv420,
      ImageFormatGroup.bgra8888 => InputImageFormat.bgra8888,
      _ => null,
    };

    if (format == null) {
      throw Exception('Unsupported image format: ${image.format.group}');
    }
    final sensorOrientation = controller.description.sensorOrientation;
    final rotation = rotationToInputImageRotation(sensorOrientation);

    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: concatenatePlanes(image.planes),
      metadata: metadata,
    );
  }

  static InputImageRotation rotationToInputImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      default:
        assert(rotation == 270);
        return InputImageRotation.rotation270deg;
    }
  }

  static Future<T> detect<T>({
    required CameraImage image,
    required CameraController controller,
    required Future<T> Function(InputImage inputImage) detectInImage,
  }) async {
    final inputImage = buildInputImage(image, controller, null);
    return await detectInImage(inputImage);
  }
}
