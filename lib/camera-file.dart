import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'display-screen.dart';
import 'main.dart';

class TakePictureScreen extends StatefulWidget {
  TakePictureScreen({
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late ResolutionPreset resl;

  // ignore: non_constant_identifier_names

  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print("permission is $permission");
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      //nothing
      openAppSettings();
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        loctn1 = position.latitude.toString();
        loctn2 = position.longitude.toString();
      });
    }
    print("latitude is $loctn1 and longitude is $loctn2");
  }

  @override
  void initState() {
    super.initState();

    resl = ResolutionPreset.medium;
    _controller = CameraController(
      widget.camera,
      resl,
    );
    _initializeControllerFuture = _controller.initialize();
    getLocation();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var body = Container(
      child: Column(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicatos.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                // Provide an onPressed callback.
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final image = await _controller.takePicture();
                    //image is saved as cache, so we need to transfer it to gallery
                    await GallerySaver.saveImage(image.path,
                        toDcim: true); //here we transfer from cache to gallery
                    // If the picture was taken, display it on a new screen.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImagePreview(
                          // Pass the automatically generated path to
                          // the DisplayPictureScreen widget.
                          imagePath: image.path,
                          latitd: loctn1,
                          longitd: loctn2,
                        ),
                      ),
                    );
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')), body: body);
  }
}

// A widget that displays the picture taken by the user.
