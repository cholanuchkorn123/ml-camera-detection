import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_camera_detection/config/app_config.dart';

extension FaceExtension on Face {
  bool isFaceInFrame() {
    return boundingBox.left >= 0 &&
        boundingBox.top >= 0 &&
        boundingBox.right >= 0 &&
        boundingBox.bottom >= 0;
  }

  bool isInsideOval(Rect ovalRect) =>
      ovalRect.contains(boundingBox.topLeft) &&
      ovalRect.contains(boundingBox.bottomRight);

  bool checkSmile() =>
      (smilingProbability ?? AppFaceConfig.defaultConfig) > 0.3;
  bool checkStraight() {
    final angleY = headEulerAngleY ?? AppFaceConfig.defaultConfig;
    final angleZ = headEulerAngleZ ?? AppFaceConfig.defaultConfig;
    final angleX = headEulerAngleX ?? AppFaceConfig.defaultConfig;
    return angleZ.abs() > 10 || angleY.abs() > 10|| angleX.abs() > 10;
  }

  bool isEyesClosed({
    required DateTime? Function() getRef,
    required void Function(DateTime?) setRef,
    int ms = 300,
  }) {
    final leftEye = leftEyeOpenProbability ?? AppFaceConfig.defaultConfig;
    final rightEye = rightEyeOpenProbability ?? AppFaceConfig.defaultConfig;

    if (leftEye < 0.4 && rightEye < 0.4) {
      setRef(getRef() ?? DateTime.now());

      final start = getRef();
      if (start == null) return false;
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      return elapsed > ms;
    } else {
      setRef(null);
      return false;
    }
  }

  bool isFaceSizeOk() {
    final size = const Size(1080, 1080);
    final faceArea = boundingBox.width * boundingBox.height;
    final imageArea = size.width * size.height;
    final ratio = faceArea / imageArea;
    return ratio >= 0.7 && ratio <= 0.8;
  }

  bool isFaceBlocked() {
    final requiredLandmarks = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.bottomMouth,
    ];

    for (var type in requiredLandmarks) {
      final landmark = landmarks[type];
      if (landmark == null) {
        return true;
      }
    }

    return false;
  }
}
