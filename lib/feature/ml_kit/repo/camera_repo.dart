import 'package:camera/camera.dart';
// unfinished to change state to clean architecture
abstract class CameraRepo {
  Future<XFile?> takePic();
}
