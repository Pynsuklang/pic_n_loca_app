import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
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
  double scale = 1.0;
  var loctn1 = "";
  var loctn2 = "";
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
    Map<String, String> location_data = {
      'latitude': loctn1,
      'longitude': loctn2,
    };
    print("latitude is $loctn1 and longitude is $loctn2");
    return location_data;
  }

  Future<bool> checkInternet() async {
    bool conn;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      conn = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      conn = true;
    } else {
      conn = false;
    }
    return conn;
  }

  @override
  void initState() {
    super.initState();

    resl = ResolutionPreset.medium;
    _controller = CameraController(
      widget.camera,
      resl,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  getStorageDirectory() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory())!
          .path; // OR return "/storage/emulated/0/Download";
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
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
                    var chkInternet = await checkInternet().then((conn2) {
                      return conn2;
                    });
                    if (chkInternet == true) {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();
                      Map<String, String> locationdata =
                          await getLocation().then((locdata) {
                        return locdata;
                      });
                      String clickdatetime = DateTime.now().toString();

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImagePreview(
                            imagePath: image.path,
                            latitd: locationdata["latitude"],
                            longitd: locationdata["longitude"],
                            clickedDateTime: clickdatetime,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('No internet connection at the moment')));
                      //trigger submit later
                    }
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error within the app')));
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
                      // await GallerySaver.saveImage(image.path, toDcim: true);
                      // var counter = 5;
                      // Timer.periodic(const Duration(seconds: 2), (timer) {
                      //   print(timer.tick);
                      //   counter--;
                      //   if (counter == 0) {
                      //     print('Cancel timer');
                      //     timer.cancel();
                      //   }
                      // });