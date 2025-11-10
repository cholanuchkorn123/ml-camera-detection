import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_camera_detection/utils/enum/enum_extension.dart';
import 'package:test_camera_detection/utils/extension/camera_extension.dart';
import 'package:test_camera_detection/utils/extension/face_extension.dart';
import 'package:test_camera_detection/utils/scanner/utils_scanner.dart';
import 'package:test_camera_detection/feature/ml_kit/widget/overlay_widget.dart';
import 'package:test_camera_detection/feature/ml_kit/widget/state_mapping_text_widget.dart';

class FaceLivenessEkycPage extends StatefulWidget {
  const FaceLivenessEkycPage({super.key});

  @override
  State<FaceLivenessEkycPage> createState() => _FaceLivenessEkycPageState();
}

class _FaceLivenessEkycPageState extends State<FaceLivenessEkycPage> {
  late final Rect ovalRect;
  bool isWorking = false;
  CameraController? cameraController;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.2,
      performanceMode: FaceDetectorMode.fast,
      enableTracking: true,
    ),
  );
  late CameraDescription description;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  LivenessState errorLiveness = LivenessState.init;
  LivenessState tempErr = LivenessState.valid;
  DateTime? eyeClosedStart;
  DateTime? validStartTime;
  Future<void> initCamera() async {
    description = await UtilsScanner.getCamera(cameraLensDirection);
    cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController!.startImageStream((imageFromStream) {
        if (!isWorking) {
          isWorking = true;
          performDetectionOnStreamFrames(imageFromStream, cameraController!);
        }
      });
    }).onError(((_,__){
      Navigator.pop(context);
    }));
  }

  LivenessState checkCondition(Face face) {
    if (!face.isFaceInFrame()) {
      return LivenessState.notInShape;
    }
    if (!face.isFaceBlocked()) {
      return LivenessState.blocked;
    }
    if (face.checkSmile()) {
      return LivenessState.smile;
    }
    if (face.checkStraight()) {
      return LivenessState.notStraight;
    }
    if (face.isEyesClosed(
      getRef: () => eyeClosedStart,
      setRef: (v) => eyeClosedStart = v,
    )) {
      return LivenessState.closeEye;
    }
    return LivenessState.init;
  }

  Future<void> performDetectionOnStreamFrames(
    CameraImage cameraImage,
    CameraController cameraController,
  ) async {
    final navigator = Navigator.of(context);
    UtilsScanner.detect<List<Face>>(
          image: cameraImage,
          controller: cameraController,
          detectInImage: faceDetector.processImage,
        )
        .then((List<Face> result) async {
          tempErr = LivenessState.init;
          if (cameraImage.isImageTooDark()) {
            tempErr = LivenessState.tooDark;
          } else if (result.isNotEmpty) {
            tempErr = checkCondition(result.first);
          }
          final tempV =
              (tempErr == LivenessState.init && result.isNotEmpty)
                  ? LivenessState.valid
                  : tempErr;

          if (errorLiveness != tempV) {
            setState(() => errorLiveness = tempV);
          }

          if (errorLiveness == LivenessState.valid) {
            validStartTime ??= DateTime.now();
            final elapsed =
                DateTime.now().difference(validStartTime!).inSeconds;
            if (elapsed >= 3) {
              try {
                await takePic();
              } catch (e) {
                if (!mounted) return;
                navigator.pop();
                if (kDebugMode) {
                  print(e);
                }
              }
              validStartTime = null;
            }
          } else {
            validStartTime = null;
          }
        })
        .whenComplete(() {
          isWorking = false;
        });
  }

  Future<void> takePic() async {
    final navigator = Navigator.of(context);
    await cameraController?.setFlashMode(FlashMode.off);
    final file = await cameraController?.takePicture();
    if (!mounted) return;
    navigator.pop(file);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: size.width * 0.7,
      height: size.height * 0.4,
    );
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
    faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (cameraController != null &&
              cameraController!.value.isInitialized) ...[
            Positioned(
              child: ClipRRect(
                child: SizedOverflowBox(
                  size: const Size(1200, 1200),
                  alignment: Alignment.center,
                  child: CameraPreview(cameraController!),
                ),
              ),
            ),
          ],
          Positioned.fill(child: CustomPaint(painter: FaceOverlayPainter())),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(40),
              child: StateMapping(item: errorLiveness),
            ),
          ),
        ],
      ),
    );
  }
}
