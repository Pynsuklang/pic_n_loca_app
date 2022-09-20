import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_n_loca_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:location/location.dart' as locationPackage;
import 'display-screen.dart';
import 'main.dart';
import 'upload-all-pics.dart';

bool isVisible = true;
bool isVisible2 = true;
late SharedPreferences datalistmap;

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
    try {
      Map<String, String> locationdata = {};
      LocationPermission permission;

      permission = await Geolocator.checkPermission();
      print("permission is $permission");

      if ((permission == LocationPermission.denied) ||
          (permission == LocationPermission.deniedForever)) {
        print("\n ba nyngkong \n");
        locationdata = {
          'latitude': "XX",
          'longitude': "XX",
        };
        print("latitude is $loctn1 and longitude is $loctn2");
        return locationdata;
      } else if ((permission == LocationPermission.always) ||
          (permission == LocationPermission.whileInUse)) {
        // print("\n ba ar \n");
        positiony = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          loctn1 = positiony.latitude.toString();
          loctn2 = positiony.longitude.toString();
          locationdata = {
            'latitude': loctn1,
            'longitude': loctn2,
          };
        });

        print("latitude is $loctn1 and longitude is $loctn2");

        return locationdata;
      } else {
        print("\n ba lai \n");
      }
    } catch (e) {
      print("\n Error inside getlocation function is $e");
    }
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

  // ignore: non_constant_identifier_names
  StoreDataForFuture(
      dynamic lati, dynamic longi, dynamic pth, dynamic clktm) async {
    try {
      SharedPreferences cntry;
      cntry = await SharedPreferences.getInstance();
      dynamic cntrval = cntry.getInt("cntrkey");
      print("cntrval in StoreDataForFuture() was $cntrval");

      if (cntrval != null) {
        cntrval = cntrval + 1;
        cntry.setInt("cntrkey", cntrval);
      } else {
        cntrval = 1;
      }
      print("cntrval in StoreDataForFuture() after is now $cntrval");
      cntry.setInt("cntrkey", cntrval);

      File imagefile = File(pth); //convert Path to File
      Uint8List imagebytes = await imagefile.readAsBytes(); //convert to bytes
      String base64string =
          base64.encode(imagebytes); //convert bytes to base64 string
      // print(base64string);

      cntry.setInt("cntrkey", cntrval);
      String cntrstr = cntrval.toString();
      datalistmap = await SharedPreferences.getInstance();
      Map<String, String> storemap = {
        'emailid': glbusrname,
        'latitude': lati.toString(),
        'longitude': longi.toString(),
        'clickedDateTime': clktm.toString(),
        'imageByte': base64string,
      };

      String encodedMap = json.encode(storemap);
      datalistmap.setString('reservedatalist$cntrstr', json.encode(storemap));
      return '1';
    } catch (e) {
      print("Error inside StoreDataForFuture() is $e");
    }
  }

  printfuturedata() async {
    //fix kane mo
    try {
      SharedPreferences cntrx = await SharedPreferences.getInstance();
      print(cntrx.getInt("cntrkey"));
      var reqddataDecode1 = cntrx.getString("reservedatalist4");
    } catch (e) {
      print("Error in printfuturedata() is $e");
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
          Visibility(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  // Provide an onPressed callback.
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      dynamic resn;
                      ScaffoldMessenger.of(context)
                          // ignore: deprecated_member_use
                          .showSnackBar(SnackBar(
                              duration: const Duration(seconds: 30),
                              content: Row(
                                children: const [
                                  CircularProgressIndicator(),
                                  Text('Please wait...')
                                ],
                              )))
                          .closed
                          .then((reason) async {
                        resn = reason;
                        // ignore: unrelated_type_equality_checks
                        if (reason == SnackBarClosedReason.timeout) {
                          print("resn is $resn");
                          positiony = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high);
                          print("positiony inside is $positiony \n");
                        }

                        // ignore: unrelated_type_equality_checks
                      });
                      print("resn outside is $resn");
                      if (resn == "SnackBarClosedReason.timeout") {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please click again')));
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyDashboard(),
                          ),
                        );
                      } else {
                        print("TRY AGAIN");
                      }
                      isVisible = false;
                      var chkInternet = await checkInternet().then((conn2) {
                        return conn2;
                      });
                      if (await Permission
                          .locationWhenInUse.serviceStatus.isEnabled) {
                        LocationPermission permis;
                        permis = await Geolocator.checkPermission();
                        if ((permis == LocationPermission.denied) ||
                            (permis == LocationPermission.deniedForever) ||
                            (permis == LocationPermission.unableToDetermine)) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Please set the location for this app to either while in use or always')));
                        } else if ((permis == LocationPermission.always) ||
                            (permis == LocationPermission.whileInUse) ||
                            (permis == LocationPermission.unableToDetermine)) {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();
                          var imagepath = image.path;

                          Map<String, String> locationdata =
                              await getLocation().then((locdata) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            return locdata;
                          });
                          String clickdatetime = DateTime.now().toString();
                          print("\n latitude is ${locationdata["latitude"]}");
                          print("\n longitude is ${locationdata["longitude"]}");
                          print("\n imagepath is $imagepath");
                          print("\n clickdatetime is $clickdatetime");

                          if (locationdata["latitude"]!.isNotEmpty &&
                              locationdata["longitude"]!.isNotEmpty &&
                              imagepath.isNotEmpty &&
                              clickdatetime.isNotEmpty) {
                            if (locationdata["latitude"] == "XX" &&
                                locationdata["longitude"] == "XX") {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Your location is denied. Please enable particularly for this app')));
                            } else {
                              var reporesponse = await StoreDataForFuture(
                                      locationdata["latitude"],
                                      locationdata["longitude"],
                                      imagepath,
                                      clickdatetime)
                                  .then((conn2) {
                                return conn2;
                              });
                              if (reporesponse == '1') {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('OK go ahead')));
                                // ignore: deprecated_member_use

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
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Cannot get location')));
                                print("don problem 1");
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Cannot get location')));
                          }
                        }
                      } else if ((await Permission
                          .locationWhenInUse.serviceStatus.isDisabled)) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Please switch on your location of your device to be able to take snapshot(s)')));
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Please switch on your location of your device"s to be able to take snapshot(s)')));
                      }
                    } catch (e) {
                      print("Error here is $e");
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Error within the app')));
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            visible: true,
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: const Text('Take a snapshot')),
        body: body,
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
// await GallerySaver.saveImage(image.path, toDcim: true);
