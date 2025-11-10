import 'package:camera/camera.dart';
// unfinished change dependency coupling to di

abstract class MlKitRepo {
  Future<void> setUpCamera();
  Future<void> streamImage(void Function(CameraImage) onAvailable);
}

