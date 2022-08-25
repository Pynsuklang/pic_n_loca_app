import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  List<CameraDescription> cameras = [];
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();
    cameraController
        .getMaxZoomLevel()
        .then((value) => _maxAvailableZoom = value);

    cameraController
        .getMinZoomLevel()
        .then((value) => _minAvailableZoom = value);
    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initWidgets();
    onNewCameraSelected(cameras[0]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  initWidgets() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error in fetching the cameras: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: controller!.buildPreview(),
            )
          : Column(
              children: [
                Container(
                  child: DropdownButton<ResolutionPreset>(
                    dropdownColor: Colors.black87,
                    underline: Container(),
                    value: currentResolutionPreset,
                    items: [
                      for (ResolutionPreset preset in resolutionPresets)
                        DropdownMenuItem(
                          child: Text(
                            preset.toString().split('.')[1].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                          value: preset,
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        currentResolutionPreset = value!;
                        _isCameraInitialized = false;
                      });
                      onNewCameraSelected(controller!.description);
                    },
                    hint: Text("Select item"),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _currentZoomLevel,
                        min: _minAvailableZoom,
                        max: _maxAvailableZoom,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                        onChanged: (value) async {
                          setState(() {
                            _currentZoomLevel = value;
                          });
                          await controller!.setZoomLevel(value);
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _currentZoomLevel.toStringAsFixed(1) + 'x',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
