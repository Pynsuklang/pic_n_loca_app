import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_n_loca_app/homepage.dart';
import 'package:pic_n_loca_app/main.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera-file.dart';

class ImagePreview extends StatefulWidget {
  var imagePath;
  var latitd;
  var longitd;
  var clickedDateTime;
  ImagePreview(
      {this.imagePath, this.latitd, this.longitd, this.clickedDateTime});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  var uploadTime;
  late var cameras2;
  late SharedPreferences reservedata;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  Widget build(BuildContext context) {
    var imgpth = widget.imagePath;
    var responseDecode;
    dynamic storeresponseval;
    String base64string = "";
    Map<String, String> sending = {};
    List<String> latitudes = [];
    List<String> longitudes = [];
    List<String> imageBytes = [];
    List<String> clickedtimes = [];
    Map<String, String> mymap = {};
    Map<String, String> tempmap = {};
    //save data
    // ignore: non_constant_identifier_names
    StoreDataForFuture(
        dynamic lati, dynamic longi, dynamic pth, dynamic clktm) async {
      try {
        dynamic thepth = "";
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
        thepth = pth;
        print("path$cntrval is $pth");

        File imagefile = File("");
        imagefile = File(thepth); //convert Path to File
        Uint8List imagebytes = Uint8List(0); //convert to bytes
        imagebytes = await imagefile.readAsBytes();
        base64string =
            base64.encode(imagebytes); //convert bytes to base64 string
        print("base64string is $base64string \n");

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
        return 1;
      } catch (e) {
        print("Error inside StoreDataForFuture() is $e");
      }
    }

    //save data
    SendAllData(dynamic sendtype) async {
      var reqdatas = await SharedPreferences.getInstance();
      cntr = reqdatas = await SharedPreferences.getInstance();
      int? itemcount = cntr.getInt("cntrkey");
      if (itemcount != null) {
        itemcount = itemcount;
      } else {
        itemcount = 0;
        cntr.setInt("cntrkey", 0);
      }

      sending["itemcount"] = itemcount.toString();
      for (var i = 1; i <= itemcount; i++) {
        if (reqdatas.containsKey("reservedatalist$i")) {
          var rawdatas = reqdatas.getString("reservedatalist$i");
          var decoded = jsonDecode(rawdatas!);
          latitudes.add(decoded["latitude"]);
          longitudes.add(decoded["longitude"]);
          imageBytes.add(decoded["imageByte"]);
          clickedtimes.add(decoded["clickedDateTime"]);
        }
      }
      String uploadtime = DateTime.now().toString();
      mymap = {
        "emailid": glbusrname,
        "uploadtime": uploadtime,
        "clickedtime": jsonEncode(clickedtimes),
        "latitude": jsonEncode(latitudes),
        "longitude": jsonEncode(longitudes),
        "imageByte": jsonEncode(imageBytes),
      };

      print("\n tempmap so far is now \n$tempmap");
      if (mymap.isEmpty) {
        responseDecode = '-1';
        return responseDecode;
      } else {
        try {
          var chkInternet = await checkInternet().then((conn2) {
            return conn2;
          });
          if (chkInternet == true) {
            if (sendtype == 0) {
              var url = Uri.parse(
                  "http://10.179.28.22:8081/api/store-datas-afternet-avl");

              Map<String, String> myheaders = {
                'Content-Type': 'application/json',
              };

              final http.Response response = await http.post(
                url,
                body: jsonEncode(mymap),
                headers: myheaders,
              );
              responseDecode = response.body;
              print("response.body IS ${response.body}");
              if (response.body == '1') {
                cntr.setInt("cntrkey", 0);
                var cnty = cntr.getInt("cntrkey");
                print("after response from api cntrkey is now $cnty");
                mymap.clear();
                await reqdatas.clear();
                await datalistmap.clear();
                logindata.setBool('login', false);
                logindata.setString('username', glbusrname);
              }
            } else {
              var url = Uri.parse("http://10.179.28.22:8081/api/store-datas");

              Map<String, String> myheaders = {
                'Content-Type': 'application/json',
              };

              final http.Response response = await http.post(
                url,
                body: jsonEncode(mymap),
                headers: myheaders,
              );
              responseDecode = response.body;
              print("response.body IS ${response.body}");
              if (response.body == '1') {
                cntr.setInt("cntrkey", 0);
                var cnty = cntr.getInt("cntrkey");
                print("after response from api cntrkey is now $cnty");
                mymap.clear();
                await reqdatas.clear();
                await datalistmap.clear();
                logindata.setBool('login', false);
                logindata.setString('username', glbusrname);
              }
            }
          } else {
            responseDecode = 'ni';
          }

          return responseDecode;
        } on SocketException catch (_) {
          responseDecode = 'scex';
          return responseDecode;
        } catch (e) {
          print("error in SendAllData() is $e");
          responseDecode = 'e';
          return responseDecode;
        }
      }
    }

    serverPing() async {
      var responseto;
      try {
        var chkInternet = await checkInternet().then((conn2) {
          return conn2;
        });
        if (chkInternet == true) {
          var url =
              Uri.parse("http://10.179.28.22:8081/api/check-connectivity");

          var response = await http
              .post(url, headers: {"Content-Type": "application/json"});
          var responseDecode = json.decode(response.body);
          // ignore: unrelated_type_equality_checks
          if (responseDecode == 1) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } on SocketException catch (_) {
        return false;
      } catch (e) {
        print("Error is $e");
        return false;
        // everything else
      }
    }

    var body = Container(
      child: Column(children: [
        Image.file(File(imgpth)), //to display file
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: FloatingActionButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      try {
                        cameras2 = await availableCameras();
                        var secondCamera = cameras.first;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Data deleted successfully')));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  // TakePictureScreen(camera: secondCamera)
                                  const MyDashboard()),
                        );
                      } catch (e) {
                        print("Error in click another is $e");
                      }
                    },
                    child: const Icon(Icons.delete_forever))),
            Expanded(
              child: FloatingActionButton(
                  child: const Icon(Icons.save),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    print("Will save");
                    print(" widget.imagePath is ${widget.imagePath}");
                    storeresponseval = StoreDataForFuture(
                            widget.latitd,
                            widget.longitd,
                            // widget.imagePath,
                            imgpth,
                            widget.clickedDateTime)
                        .then((storeresponse) async {
                      print("storeresponse is $storeresponse");
                      return storeresponse;
                    });
                    print("storeresponseval is $storeresponseval");
                    // ignore: unrelated_type_equality_checks
                    if (storeresponseval == '1') {
                      print("ba nyngkong");
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Data saved successfully')));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()),
                      );
                      imgpth = "";
                    } else {
                      print("ba ar");
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Data saved successfully')));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()),
                      );
                    }
                  }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: const Text("Delete"),
            ),
            const SizedBox(
              width: 155.0,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: const Text("Save"),
            )
          ],
        )
      ]),
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
        appBar: AppBar(title: const Text('Display the Picture')),
        body: body,
      ),
    );
  }
}
