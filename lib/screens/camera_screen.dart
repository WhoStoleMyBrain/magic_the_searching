import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../helpers/google_mlkit_helper.dart';
import '../helpers/constants.dart';
import '../providers/color_provider.dart';
import '../providers/scryfall_provider.dart';
import '../widgets/fire_query_image_taken_alert_dialog.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera-screen';
  const CameraScreen(this._cameras, {super.key});
  final List<CameraDescription> _cameras;
  @override
  State<CameraScreen> createState() {
    return _CameraScreenState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;

  bool enableAudio = false;

  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  ScryfallProvider? scryfallProvider;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onNewCameraSelected(widget._cameras.first);
      scryfallProvider = Provider.of<ScryfallProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    _focusModeControlRowAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
          stops: const [0.1, 0.9],
          colors: [
            colorProvider.backgroundColor1,
            colorProvider.backgroundColor2,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Take a picture of your card!'),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color:
                        controller != null && controller!.value.isRecordingVideo
                            ? Colors.redAccent
                            : Colors.grey,
                    width: 3.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
            ),
            _captureControlRowWidget(),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  _cameraTogglesRowWidget(),
                  _thumbnailWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (imageFile == null)
              Container()
            else
              SizedBox(
                  width: 64.0,
                  height: 64.0,
                  child: Image.file(File(imageFile!.path)))
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.flash_on),
          iconSize: 32.0,
          color: Colors.blue,
          onPressed: controller != null ? onFlashModeButtonPressed : null,
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt),
          iconSize: 32.0,
          color: Colors.blue,
          onPressed:
              cameraController != null && cameraController.value.isInitialized
                  ? onTakePictureButtonPressed
                  : null,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (widget._cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in widget._cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (mounted) {
        if (file != null) {
          return GoogleMlkitHelper.getCardNameFromXfile(file,
              scryfallProvider: scryfallProvider);
        }
      }
    }).then((value) async {
      if (value != null && value.isNotEmpty) {
        if (kDebugMode) {
          print('returned map: $value');
        }
        showDialog<void>(
          context: context,
          builder: (bCtx) {
            return FireQueryImageTakenAlertDialog(
                value[Constants.imageTextMapCardName],
                value[Constants.imageTextMapCardType],
                value[Constants.imageTextMapCreatureType],
                value[Constants.imageTextMapLanguages]);
          },
        );
      } else {
        showDialog<void>(
          context: context,
          builder: (bCtx) {
            return AlertDialog(
                title: const Text('Error detecting the card!'),
                titlePadding: const EdgeInsets.all(24.0),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32))),
                backgroundColor: Colors.blueGrey.shade200,
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Could not detect any card on screen."),
                    SizedBox(
                      height: 16,
                    ),
                    Text(" Please try again!"),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ]);
          },
        );
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      controller!.setFlashMode(FlashMode.torch);
      _flashModeControlRowAnimationController.reverse();
    } else {
      controller!.setFlashMode(FlashMode.off);
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    if (kDebugMode) {
      _logError(e.code, e.description);
    }
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
