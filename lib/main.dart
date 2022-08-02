import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/camera-file.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  dynamic tkn;
  // removeValue() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('key', "");
  // }

  saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('key', "value");
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? strx = prefs.getString('key');
    return strx;
  }

  myfunc() {
    tkn = 1;
  }

  @override
  void initState() {
    super.initState();
    print("App started");
    saveValue();
    getValue().then((vals) {
      setState(() {
        tkn = vals;
      });
    });
    initwidgets();
  }

  @override
  void dispose() {
    print("App closed");
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
        title: const Text("Camera App"),
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
        //tooltip: tkn != "" ? 'Take Picture' : 'take pics',
        child: tkn == "value"
            ? const Icon(Icons.camera_alt)
            : const Icon(Icons.access_alarm),
      ),
    );
  }
}
