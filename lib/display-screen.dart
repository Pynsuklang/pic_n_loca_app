import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  late Timer timer;
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
    var lat = widget.latitd;
    var longt = widget.longitd;
    var imgpth = widget.imagePath;
    var clicktime = widget.clickedDateTime;
    var responseDecode;
    Map<String, String> sending = {};
    List<String> latitudes = [];
    List<String> longitudes = [];
    List<String> imageBytes = [];
    List<String> clickedtimes = [];
    Map<String, String> mymap = {};
    SendAllData(dynamic sendtype) async {
      var reqdatas = await SharedPreferences.getInstance();
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
                  "http://10.179.28.7:8080/api/store-datas-afternet-avl");

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
              var url = Uri.parse("http://10.179.28.7:8080/api/store-datas");

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
          var url = Uri.parse("http://10.179.28.7:8080/api/check-connectivity");

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
            FloatingActionButton(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(minutes: 10),
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          Text('Please wait...')
                        ],
                      )));
                  var sig = await SendAllData(1).then((vals) {
                    return vals;
                  });

                  if (sig == '1') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Data is submitted and saved successfully')));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()));
                  } else if (sig == '5') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'This file is already uploaded. Please upload another file')));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()));
                  } else if (sig == '6') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please click again')));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()));
                  } else if (sig == 'scex') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Server Unreacheable at the moment. Please try again later')));
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()));
                  } else if (sig == 'ni') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Internet Not Available. File will be uploaded on immidiate availability of internet!!!')));
                    //send to protected
                    Timer.periodic(const Duration(seconds: 5), (timer) async {
                      print("timer started");

                      var responseavail = await serverPing().then((conn2) {
                        return conn2;
                      });
                      if (responseavail == true) {
                        timer.cancel();
                        var sig = await SendAllData(0).then((vals) {
                          print("vals is $vals");
                          return vals;
                        });
                        print("sig is $sig");
                        if (sig == '1') {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          print('Canceled timer');
                        }
                      }
                    });
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDashboard()));
                  } else {}
                } catch (e) {
                  print("Error is $e");
                }
              },
              child: const Icon(Icons.upload_file),
            ),
          ],
        ),
        Container(
          child: Text("Upload All"),
        ),
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
