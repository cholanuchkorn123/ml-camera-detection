// import 'package:camera/camera.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:test_camera_detection/utils/utils_scanner.dart';

// final livenessCameraController =
//     FutureProvider.family<CameraController, CameraLensDirection>((
//       ref,
//       cameraLensDirection,
//     ) async {
//       final description = await UtilsScanner.getCamera(cameraLensDirection);
//       final controller = CameraController(
//         description,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//       await controller.initialize();

//       ref.onDispose(() {
//         controller.dispose();
//       });

//       return controller;
//     });
