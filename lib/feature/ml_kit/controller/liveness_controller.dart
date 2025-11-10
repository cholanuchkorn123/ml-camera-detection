// import 'package:camera/camera.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:test_camera_detection/feature/ml_kit/repo/ml_kit_repo.dart';
// import 'package:test_camera_detection/utils/enum/enum_extension.dart';
// import 'package:test_camera_detection/utils/utils_scanner.dart';

// class LivenessController extends StateNotifier<LivenessState> {
//   final MlKitRepo mlKitRepo;
//   final CameraController cameraController;
//   final FaceDetector faceDetector;
//   bool isWorking = false;
//   LivenessController(this.mlKitRepo, this.cameraController, this.faceDetector)
//     : super(LivenessState.init);

//   Future<void> initCamera() async {
//     await mlKitRepo.setUpCamera().then((_) async {
//       if (!mounted) {
//         return;
//       }

//       await mlKitRepo.streamImage((value) {
//         if (!isWorking) {
//           isWorking = true;
//           performDetectionOnStreamFrames(value, cameraController);
//         }
//       });
//     });
//   }

//   Future<void> performDetectionOnStreamFrames(
//     CameraImage cameraImage,
//     CameraController cameraController,
//   ) async {
//     UtilsScanner.detect<List<Face>>(
//           image: cameraImage,
//           controller: cameraController,
//           detectInImage: faceDetector.processImage,
//         )
//         .then((List<Face> result) async {
//           // setup state
//           state = LivenessState.init;
//           // check camera bright
//           if (cameraImage.isImageTooDark()) {
//             state = LivenessState.tooDark;
//           } else if (result.isNotEmpty) {
//             // check  result []
//             state = checkCondition(result.first);
//           }
//           final tempV =
//               (state == LivenessState.init && result.isNotEmpty)
//                   ? LivenessState.valid
//                   : tempErr;

//           if (errorLiveness != tempV) {
//             state = tempV;
//           }

//           if (errorLiveness == LivenessState.valid) {
//             validStartTime ??= DateTime.now();
//             final elapsed =
//                 DateTime.now().difference(validStartTime!).inSeconds;
//             if (elapsed >= 3) {
//               try {
//                 await takePic();
//               } catch (e) {
//                 if (!mounted) return;
//                 navigator.pop();
//                 if (kDebugMode) {
//                   print(e);
//                 }
//               }
//               validStartTime = null;
//             }
//           } else {
//             validStartTime = null;
//           }
//         })
//         .whenComplete(() {
//           isWorking = false;
//         });
//   }
// }
