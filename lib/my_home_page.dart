import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/main2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera-file.dart';
import 'homepage.dart';
import 'login_screen.dart';
import 'main.dart';

class MYHome extends StatefulWidget {
  const MYHome({Key? key}) : super(key: key);

  @override
  State<MYHome> createState() => _MYHomeState();
}

class _MYHomeState extends State<MYHome> {
  late String username;
  late bool newuser;

  void check_if_already_login() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    print(newuser);
    if (newuser == true) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => MyLoginPage()));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context).pop();
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyLoginPage()));
    return Future.value(true);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_if_already_login();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username')!;
    });
  }

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
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late var cameras;

  @override
  void initState() {
    super.initState();
    print("App started");
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
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
