import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pic_n_loca_app/main.dart';

class ImagePreview extends StatefulWidget {
  var imagePath;
  var latitd;
  var longitd;
  ImagePreview({this.imagePath, this.latitd, this.longitd});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print("permission is $permission");
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      //nothing
      openAppSettings();
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        loctn1 = position.latitude.toString();
        loctn2 = position.longitude.toString();
      });
    }
    print("latitude is $loctn1 and longitude is $loctn2");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    var lat = widget.latitd;
    var longt = widget.longitd;
    var imgpth = widget.imagePath;
    print("latitude is $lat");
    print("longitude is $longt");
    print("image path is $imgpth");
    SendData(dynamic latit, dynamic longit, dynamic imgpth) async {
      late var response;
      late var responseDecode;
      try {
        print("image path inside senddata is $imgpth");
        var url = Uri.parse("http://10.179.28.7:8080/api/store-data");
        Map<String, String> headers = {
          'Content-Type': 'multipart/form-data',
        };
        Map<String, String> data = {
          'latitude': latit,
          'longitude': longit,
          'emailid': glbusrname
        };
        //final body = json.encode(data);
        var request = http.MultipartRequest('POST', url)
          ..fields.addAll(data)
          ..headers.addAll(headers)
          ..files.add(await http.MultipartFile.fromPath('image', imgpth));
        var response = await request.send();
        ////

        final respStr = await response.stream.bytesToString();
        print("response from api is $respStr");
        //encode Map to JSON
        responseDecode = respStr;
        return responseDecode;
      } catch (e) {
        print("error is $e");
        responseDecode = 'e';
        return responseDecode;
      }
    }

    var body = Container(
      child: Column(children: [
        Image.file(File(imgpth)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              // Provide an onPressed callback.
              onPressed: () async {
                try {
                  //SendData(lat, longt, imgpth);
                  var sig = await SendData(lat, longt, imgpth).then((vals) {
                    print("vals is $vals");
                    return vals;
                  });
                  print("sig is $sig");
                  print(sig.toString());
                  if (sig == '1') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Data is submitted and saved successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ERROR!!!')));
                  }
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
              child: const Icon(Icons.upload_file),
            ),
          ],
        ),
        Container(
          //padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
          child: Text("Upload"),
        ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: body,
    );
  }
}
