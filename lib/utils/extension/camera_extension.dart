import 'package:camera/camera.dart';

extension CameraExtension on CameraImage {
  bool isImageTooDark({int threshold = 50}) {
    final bytes = planes[0].bytes;
    int sum = 0;

    for (int i = 0; i < bytes.length; i += 100) {
      sum += bytes[i];
    }

    final avg = sum ~/ (bytes.length ~/ 100);
    return avg < threshold;
  }
}
