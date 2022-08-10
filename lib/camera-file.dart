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
  var loctn1 = "";
  var loctn2 = "";
  // ignore: non_constant_identifier_names
  Future<http.Response> SendData(
      dynamic name, dynamic usnm, dynamic pwd) async {
    var response = null;
    try {
      var url = Uri.parse("http://10.179.28.7:8080/api/store-data");
      print("password is $pwd");
      var data = {'name': name, 'usnm': usnm, 'pwd': pwd};
      //encode Map to JSON
      var body = json.encode(data);

      response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      print("${response.statusCode}");
      print("${response.body}");
      return response;
    } catch (e) {
      response = 'e';
      return response;
      // ignore: dead_code_catch_following_catch
    } on SocketException catch (_) {
      response = 'e';
      return response;
    }
  }

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

    print('Printing text before getCurrentLocation()');
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    resl = ResolutionPreset.medium;
    _controller = CameraController(
      widget.camera,
      resl,
    );
    _initializeControllerFuture = _controller.initialize();
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
                // Otherwise, display a loading indicator.
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
                        builder: (context) => DisplayPictureScreen(
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
        appBar: AppBar(title: const Text('Take a picture')),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: body);
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final latitd;
  final longitd;
  const DisplayPictureScreen(
      {required this.imagePath, this.latitd, this.longitd});

  @override
  Widget build(BuildContext context) {
    var lat = latitd;
    print("latitude is $lat");
    var body = Container(
      child: Column(children: [
        Image.file(File(imagePath)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              // Provide an onPressed callback.
              onPressed: () async {
                try {} catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: body,
    );
  }
}
