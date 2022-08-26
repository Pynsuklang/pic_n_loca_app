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
      try {
        var chkInternet = await checkInternet().then((conn2) {
          return conn2;
        });
        if (chkInternet == true) {
          print("image path inside senddata is $imgpth");
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
          print("response from api is $respStr");
          responseDecode = respStr;
          return responseDecode;
        } else {
          responseDecode = 'ni';
          return responseDecode;
        }
      } catch (e) {
        print("error is $e");
        responseDecode = 'e';
        return responseDecode;
      }
    }

    sendtoprotected(dynamic latit2, dynamic longit2, dynamic imgpth2,
        dynamic clickdatetimebk, dynamic uploaddatetimebk) async {
      try {
        Map<String, String> datatosend = {
          'latitude': latit2,
          'longitude': longit2,
          'emailid': glbusrname,
          'uploadtime': uploaddatetimebk,
          'clickedtime': clickdatetimebk
        };
        var datas = jsonEncode(datatosend);
        dynamic reservedata = await SharedPreferences.getInstance();
        reservedata.setString("resvdata", datas);

        String encodedMap = reservedata.getString('resvdata');
        Map<String, dynamic> decodedMap = json.decode(encodedMap);
        print(decodedMap);
      } catch (e) {
        print("Error is $e");
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
                  } else if (sig == 'ni') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Internet Not Available. File will be uploaded on immidiate availability of internet!!!')));
                    //send to protected
                    sendtoprotected(
                        lat, longt, imgToSend, clicktime, uploaddatetime);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ERROR!!!')));
                  }
                } catch (e) {
                  print(e);
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
