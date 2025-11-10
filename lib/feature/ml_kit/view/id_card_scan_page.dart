import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:test_camera_detection/utils/scanner/utils_scanner.dart';
import 'package:test_camera_detection/feature/ml_kit/widget/id_card_overlay_widget.dart';

class IdCardScanPage extends StatefulWidget {
  const IdCardScanPage({super.key});

  @override
  State<IdCardScanPage> createState() => _IdCardScanPageState();
}

class _IdCardScanPageState extends State<IdCardScanPage> {
  late final Rect cardRect;
  CameraController? cameraController;
  late CameraDescription description;
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  bool isWorking = false;
  DateTime? validStartTime;
  Color borderColor = Colors.red;
  Rect? lastDetectedCardRect;
  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    description = await UtilsScanner.getCamera(cameraLensDirection);
    cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController!.initialize().then((v) {
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
    }));;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    const double cardAspectRatio = 1.586;
    final double frameWidth = size.width * 0.85;
    final double frameHeight = frameWidth / cardAspectRatio;

    cardRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );
  }

  Future<void> performDetectionOnStreamFrames(
    CameraImage image,
    CameraController cameraController,
  ) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    UtilsScanner.detect<RecognizedText>(
          image: image,
          controller: cameraController,
          detectInImage: textRecognizer.processImage,
        )
        .then((RecognizedText text) async {
          final containsIdCardWords =
              (text.text.contains("Thai National ") ||
                  text.text.contains("ID Card")) &&
              (text.text.contains("Name") || text.text.contains("Last name")) &&
              (text.text.contains("Identification") ||
                  text.text.contains("Number"));
          setState(
            () => borderColor = containsIdCardWords ? Colors.green : Colors.red,
          );
          if (containsIdCardWords) {
            validStartTime ??= DateTime.now();
            final elapsed =
                DateTime.now().difference(validStartTime!).inSeconds;
            if (elapsed >= 0.15) {
              try {
                final allBoxes =
                    text.blocks
                        .expand((block) => block.lines)
                        .map((line) => line.boundingBox)
                        .toList();

                if (allBoxes.isNotEmpty) {
                  final minX = allBoxes.map((e) => e.left).reduce(min);
                  final minY = allBoxes.map((e) => e.top).reduce(min);
                  final maxX = allBoxes.map((e) => e.right).reduce(max);
                  final maxY = allBoxes.map((e) => e.bottom).reduce(max);

                  lastDetectedCardRect = Rect.fromLTRB(minX, minY, maxX, maxY);
                }
                await takePicAndCrop();
              } catch (e) {
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

  Future<void> takePicAndCrop() async {
    final navigator = Navigator.of(context);

    await cameraController?.setFlashMode(FlashMode.off);
    final XFile? rawFile = await cameraController?.takePicture();

    if (rawFile == null || !mounted) return;

    final Rect? cardBox = lastDetectedCardRect;

    if (cardBox != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: rawFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.586, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(aspectRatioLockEnabled: false),
        ],
      );
      if (croppedFile != null) {
        navigator.pop(File(croppedFile.path));
        return;
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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

          Positioned.fill(
            child: CustomPaint(
              painter: ThaiIDCardOverlayPainter(
                frameRect: cardRect,
                isGood: borderColor == Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
