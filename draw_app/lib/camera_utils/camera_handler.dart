import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


class CameraHandler {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  Future<void> initializeCamera() async {
    if (_cameras == null) {
      try {
        _cameras = await availableCameras();
      } on CameraException catch (e) {
        debugPrint('Error fetching Cameras: $e');
        return;
      }
    }

    if (_cameras == null || _cameras!.isEmpty) {
      debugPrint('No cameras available');
      return;
    }

    //利用可能なカメラの最初のカメラを使用する
    final firstCamera = _cameras!.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false, //音声は必要ないので無効化
    );

    try {
      await _controller!.initialize();
      _isCameraInitialized = true;
      debugPrint('Camera initialized successfully');
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
      _isCameraInitialized = false;
    }
  }

  bool get isCameraInitialized => _isCameraInitialized;
  CameraController? get controller => _controller;

  Future<XFile?> takePicture() async {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      debugPrint('Error: Camera not initialized or controller is null');
      return null;
    }

    if (_controller!.value.isTakingPicture) {
      //すでに写真の撮影中の場合は何もしない
      return null;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      debugPrint('Picture saved to ${picture.path}');
      return picture;
    } on CameraException catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isCameraInitialized = false;
    debugPrint('Camera disposed');
  }
}

//カメラプレビューを表示するためのウィジェット
class CameraPreviewWidget extends StatefulWidget {
  final CameraHandler cameraHandler;

  const CameraPreviewWidget({Key? key, required this.cameraHandler})
    : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  void initState() {
    super.initState();
    if (!widget.cameraHandler.isCameraInitialized) {
      widget.cameraHandler.initializeCamera().then((_) {
        if (mounted && widget.cameraHandler.isCameraInitialized) {
          setState(() {}); //カメラが初期化されたら再描画
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cameraHandler.isCameraInitialized ||
        widget.cameraHandler.controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(widget.cameraHandler.controller!);
  }

  @override
  void dispose() {
    //このウィジェットが破棄されるときにカメラは破棄しない
    //cameraHandlerのライフサイクルはpage2_draw.dartで管理される想定
    super.dispose();
  }
}
