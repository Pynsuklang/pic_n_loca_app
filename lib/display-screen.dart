import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_n_loca_app/main.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SendData(dynamic latit2, dynamic longit2, dynamic imgpth2,
        dynamic clicktime, dynamic uploaddatetime) async {
      late var response;
      late var responseDecode;
      reservedata = await SharedPreferences.getInstance();
      try {
        var chkInternet = await checkInternet().then((conn2) {
          return conn2;
        });
        if (chkInternet == true) {
          var url = Uri.parse("http://10.179.28.7:8080/api/store-data");
          Map<String, String> headers = {
            'Content-Type': 'multipart/form-data',
          };
          String uploadtime = DateTime.now().toString();
          Map<String, String> data = {
            'latitude': latit2,
            'longitude': longit2,
            'emailid': glbusrname,
            'uploadtime': uploaddatetime,
            'clickedtime': clicktime
          };
          var request = http.MultipartRequest('POST', url)
            ..fields.addAll(data)
            ..headers.addAll(headers)
            ..files.add(await http.MultipartFile.fromPath('image', imgpth2));
          var response = await request.send();
          final respStr = await response.stream.bytesToString();
          responseDecode = respStr;
          return responseDecode;
        } else {
          responseDecode = 'ni';
          return responseDecode;
        }
      } on SocketException catch (_) {
        responseDecode = 'scex';
        return responseDecode;
      } catch (e) {
        print("error is $e");
        responseDecode = 'e';
        return responseDecode;
      }
    }

    sendtoprotected(dynamic latit2, dynamic longit2, dynamic imgpth2,
        dynamic clickdatetimebk, dynamic uploaddatetimebk) async {
      try {
        Map<String, String> data = {
          'latitude': latit2,
          'longitude': longit2,
          'emailid': glbusrname,
          'uploadtime': uploaddatetimebk,
          'clickedtime': clickdatetimebk,
          'imgpth2': imgpth2,
        };
        // reservedata = await SharedPreferences.getInstance();
        // reservedata.setString("reservedatalist", data.toString());
        String encodedMap = json.encode(data);
        reservedata.setString('reservedatalist', encodedMap);
        print("DATA STORED IN SESSION");
      } catch (e) {
        print("Error is $e");
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

    sendafterinternetavail() async {
      late var response;
      late var responseDecode;
      try {
        var chkInternet = await checkInternet().then((conn2) {
          return conn2;
        });
        if (chkInternet == true) {
          Map<String, dynamic> decodedMap =
              json.decode(reservedata.getString('reservedatalist')!);
          print("decoded map is\n");
          print(decodedMap);
          //
          Map<String, String> stringQueryParameters =
              decodedMap.map((key, value) => MapEntry(key, value.toString()));
          var url = Uri.parse("http://10.179.28.7:8080/api/store-data");
          Map<String, String> headers = {
            'Content-Type': 'multipart/form-data',
          };
          String uploadtime = DateTime.now().toString();

          var request = http.MultipartRequest('POST', url)
            ..fields.addAll(stringQueryParameters)
            ..headers.addAll(headers)
            ..files.add(await http.MultipartFile.fromPath(
                'image', decodedMap['imgpth2']));
          var response = await request.send();
          final respStr = await response.stream.bytesToString();
          print("respStr from save-data is $respStr");

          return true;
        } else {}
      } catch (e) {
        print("error in sendafterinternetavail() is $e");
        responseDecode = 'e';
        return true;
      }
    }

    var body = Container(
      child: Column(children: [
        Image.file(File(imgpth)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () async {
                String uploaddatetime = DateTime.now().toString();
                var chkInternet = await checkInternet().then((conn2) {
                  print("conn2 is $conn2");
                  return conn2;
                });

                try {
                  final imgToSend = imgpth;
                  //"/data/user/0/com.example.pic_n_loca_app/cache/CAP422041405340159134.jpg";
                  var sig = await SendData(
                          lat, longt, imgToSend, clicktime, uploaddatetime)
                      .then((vals) {
                    return vals;
                  });

                  if (sig == '1') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Data is submitted and saved successfully')));
                  } else if (sig == '5') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'This file is already uploaded. Please upload another file')));
                  } else if (sig == '6') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please click again')));
                  } else if (sig == 'scex') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Server Unreacheable')));
                  } else if (sig == 'ni') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Internet Not Available. File will be uploaded on immidiate availability of internet!!!')));
                    //send to protected
                    sendtoprotected(
                        lat, longt, imgToSend, clicktime, uploaddatetime);

                    var counter = 20;
                    Timer.periodic(const Duration(seconds: 2), (timer) {
                      print("timer started");
                      serverPing().then((conn2) async {
                        print("response from serverPing() is $conn2");
                        if (conn2 == true) {
                          var responseavail =
                              await sendafterinternetavail().then((conn2) {
                            return conn2;
                          });
                          if (responseavail == true) {
                            timer.cancel();
                            print('Cancel timer');
                          }
                        }
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ERROR!!!')));
                  }
                } catch (e) {
                  print("Error is $e");
                }
              },
              child: const Icon(Icons.upload_file),
            ),
          ],
        ),
        Container(
          child: Text("Upload"),
        ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: body,
    );
  }
}
