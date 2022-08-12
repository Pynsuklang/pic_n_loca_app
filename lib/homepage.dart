import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pic_n_loca_app/my_home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'camera-file.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences logindata;

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeplayon Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MYHome(),
    );
  }
}

class MyDashboard extends StatefulWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  late String username;
  late bool newuser;
  late var cameras;
  File? image;
  initwidgets() async {
    cameras = await availableCameras();
  }

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
    initwidgets();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username')!;
    });
  }

  pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      print("image is $image");
      if (image == null) {
        print("is null");
      }

      final imageTemp = File(image!.path);
      print("image path is $imageTemp");
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // show the snackbar with some text
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The System Back Button is Deactivated')));
        return false;
      },
      child: Scaffold(
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blue,
          ),
          child: MyDrawer(),
        ),
        appBar: AppBar(
          title: const Text("Camera App"),
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 350, 20, 0),
                    child: FloatingActionButton(
                      onPressed: () {
                        var firstCamera = cameras.first;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TakePictureScreen(camera: firstCamera)),
                        );
                      },
                      //tooltip: tkn != "" ? 'Take Picture' : 'take pics',
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(50, 350, 10, 0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final images = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        print("image is $images");
                      },
                      //tooltip: tkn != "" ? 'Take Picture' : 'take pics',
                      child: const Icon(Icons.folder),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                    child: const Text("Take snapshot"),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                    child: const Text("Choose picture"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(''),
          ),
          const Divider(
            color: Colors.white,
            height: 1.0,
          ),
          ListTile(
            dense: true,
            title: const Text(
              'Logout',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              logindata.setBool('login', true);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyLoginPage()));
            },
          ),
          const Divider(
            color: Colors.white,
            height: 1.0,
          ),
        ],
      ),
    );
  }
}
