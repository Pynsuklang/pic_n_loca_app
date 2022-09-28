import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:location/location.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_n_loca_app/my_home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_n_loca_app/pics-repo.dart';
import 'package:pic_n_loca_app/upload-all-pics.dart';
import 'camera-file.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences logindata;
late var cameras;
Position? positiony;
dynamic openbtn = "x";
bool chkintr = true;

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeplayon Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MYHome(),
      debugShowCheckedModeBanner: false,
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
          context, MaterialPageRoute(builder: (context) => MyLoginPage()));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context).pop();
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyLoginPage()));
    return Future.value(true);
  }

  checklocpermission() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus == true) {
    } else {
      Geolocator.openLocationSettings();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_if_already_login();
    initial();
    initwidgets();
    checkinternet();
    // checklocpermission();
    // initlocs();
  }

  @override
  void dispose() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // TODO: implement dispose
    super.dispose();
  }

  checkinternet() async {
    chkintr = await serverPing2().then((conn2) {
      return conn2;
    });
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
          title: const Text("Home"),
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
                      onPressed: () async {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (await Permission
                            .locationWhenInUse.serviceStatus.isEnabled) {
                          LocationPermission permis;
                          permis = await Geolocator.checkPermission();
                          if ((permis == LocationPermission.denied) ||
                              (permis == LocationPermission.deniedForever) ||
                              (permis ==
                                  LocationPermission.unableToDetermine)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please set the location permission for this app to either while in use or always')));
                          } else if ((permis == LocationPermission.always) ||
                              (permis == LocationPermission.whileInUse)) {
                            var firstCamera = cameras.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreen(camera: firstCamera)),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Please switch on the location to go to next step')));
                        }
                      },
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(50, 350, 10, 0),
                    child: chkintr == true
                        ? FloatingActionButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              print("\n openbtn is $openbtn");
                              if (openbtn == "x") {
                                try {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: const Duration(seconds: 30),
                                          content: Row(
                                            children: const [
                                              CircularProgressIndicator(),
                                              Text('Please wait...')
                                            ],
                                          )));
                                  var sig = await UploadAllData().then((vals) {
                                    return vals;
                                  });
                                  print("sig from uploadall is $sig");
                                  if (sig == 'na') {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'No snapshot(s) available at the moment')));
                                  } else if (sig == '1') {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Data is submitted and saved successfully')));
                                  } else if (sig == '5') {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'This file is already uploaded. Please upload another file')));
                                  } else if (sig == '6') {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Please click again')));
                                  } else if (sig == 'scex') {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Server Unreacheable')));
                                  } else if (sig == 'ni') {
                                    //send to protected
                                    setState(() {
                                      openbtn = "y";
                                    });
                                    var sig2 =
                                        await UploadAllData().then((vals) {
                                      return vals;
                                    });
                                    if (sig2 == 'ni') {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Internet Not Available. File will be uploaded on immidiate availability of internet!!!')));
                                      Timer.periodic(const Duration(seconds: 5),
                                          (timer1) async {
                                        print("timer1 started");

                                        var responseavail =
                                            await serverPing2().then((conn2) {
                                          return conn2;
                                        });
                                        if (responseavail == true) {
                                          var sig = await UploadAllData()
                                              .then((vals) {
                                            print("vals is $vals");
                                            return vals;
                                          });
                                          print("sig is $sig");
                                          if (sig == '1') {
                                            timer1.cancel();
                                            setState(() {
                                              openbtn = "x";
                                            });
                                            print('Canceled timer1');
                                          }
                                        }
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Data(s) not available at the moment')));
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Internet Not Available. File will be uploaded on immidiate availability of internet!!!')));
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  print("Error on UploadAllData() is $e");
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Internet Not Available')));
                              }
                            },
                            //tooltip: tkn != "" ? 'Take Picture' : 'take pics',
                            child: const Icon(Icons.upload_file),
                          )
                        : const Icon(
                            Icons.signal_cellular_connected_no_internet_4_bar),
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
                    child: chkintr == true
                        ? const Text("Upload All")
                        : const Text("No Internet"),
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
              Location location = new Location();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              logindata.setBool('login', true);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MyLoginPage()));
            },
          ),
          // const Divider(
          //   color: Colors.white,
          //   height: 1.0,
          // ),
          // ListTile(
          //   dense: true,
          //   title: const Text(
          //     'Clicked Pics',
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16.0,
          //         fontWeight: FontWeight.bold),
          //   ),
          //   onTap: () async {
          //     SharedPreferences cntrx = await SharedPreferences.getInstance();
          //     var itemcount = cntrx.getInt("cntrkey");
          //     if (itemcount == null || itemcount < 1) {
          //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //           content: Text('Snapshot(s) not available at the moment')));
          //     } else {
          //       Navigator.pushReplacement(context,
          //           MaterialPageRoute(builder: (context) => RouteOne()));
          //     }
          //   },
          // ),
          const Divider(
            color: Colors.white,
            height: 1.0,
          ),
          ListTile(
            dense: true,
            title: const Text(
              'Home',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MyDashboard()));
            },
          ),
        ],
      ),
    );
  }
}
