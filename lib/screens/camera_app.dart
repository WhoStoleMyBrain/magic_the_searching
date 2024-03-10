import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraApp extends StatefulWidget {
  static const routeName = '/camera-app';
  List<CameraDescription> _cameras;
  CameraApp(
    this._cameras, {
    super.key,
  });

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  @override
  void initState() {
    super.initState();

    // _cameras = await availableCameras();
    print('available cameras: ${widget._cameras}');
    controller = CameraController(widget._cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: CameraPreview(controller),
    );
  }
}
