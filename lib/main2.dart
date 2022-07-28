import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/camera-file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({Key? key, required this.title}) : super(key: key);

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late var cameras;
  @override
  void initState() {
    super.initState();
    initwidgets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initwidgets() async {
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Click on the camera button below',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var firstCamera = cameras.first;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TakePictureScreen(camera: firstCamera)),
          );
        },
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
