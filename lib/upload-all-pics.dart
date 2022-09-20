import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pic_n_loca_app/camera-file.dart';
import 'package:pic_n_loca_app/homepage.dart';
import 'package:pic_n_loca_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

var responseDecode;
late SharedPreferences cntr;

Map<String, String> sendings = {};
List<String> latitudes = [];
List<String> longitudes = [];
List<String> imageBytes = [];
List<String> clickedtimes = [];
Map<String, String> mymaps = {};

initgetLocation() async {
  try {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    print("permission inside initgetLocation() is $permission");

    if ((permission == LocationPermission.denied) ||
        (permission == LocationPermission.deniedForever)) {
      print("\n ba nyngkong \n");
      // locationdata = {
      //   'latitude': "XX",
      //   'longitude': "XX",
      // };

      return '-1';
    } else if ((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse)) {
      // print("\n ba ar \n");
      positiony = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("positiony is $positiony");
      // locationdata = {
      //   'latitude': positiony.latitude.toString(),
      //   'longitude': positiony.latitude.toString(),
      // };
      return '1';
    } else {
      print("\n ba lai \n");
      return '0';
    }
  } catch (e) {
    print("\n Error inside initgetLocation function is $e");
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

UploadAllData(dynamic sendtype) async {
  var reqdatas = await SharedPreferences.getInstance();
  cntr = await SharedPreferences.getInstance();

  int? itemcount = cntr.getInt("cntrkey");
  if (itemcount != null) {
    itemcount = itemcount;

    sendings["itemcount"] = itemcount.toString();
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
    mymaps = {
      "emailid": glbusrname,
      "uploadtime": uploadtime,
      "clickedtime": jsonEncode(clickedtimes),
      "latitude": jsonEncode(latitudes),
      "longitude": jsonEncode(longitudes),
      "imageByte": jsonEncode(imageBytes),
    };
    if (mymaps.isEmpty) {
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
              body: jsonEncode(mymaps),
              headers: myheaders,
            );
            responseDecode = response.body;
            print("response.body IS ${response.body}");
            if (response.body == '1') {
              cntr.setInt("cntrkey", 0);
              var cnty = cntr.getInt("cntrkey");
              print("after response from api cntrkey is now $cnty");
              mymaps.clear();
              await reqdatas.clear();
              datalistmap = await SharedPreferences.getInstance();
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
              body: jsonEncode(mymaps),
              headers: myheaders,
            );
            responseDecode = response.body;
            print("response.body IS ${response.body}");
            if (response.body == '1') {
              cntr.setInt("cntrkey", 0);
              var cnty = cntr.getInt("cntrkey");
              print("after response from api cntrkey is now $cnty");
              mymaps.clear();

              await reqdatas.clear();
              datalistmap = await SharedPreferences.getInstance();
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
        print("error inside UploadAllData() is $e");
        responseDecode = 'e';
        return responseDecode;
      }
    }
  } else {
    print("\n No datas available \n");

    responseDecode = 'na';
    return responseDecode;
  }
}

serverPing2() async {
  var responseto;
  try {
    var chkInternet = await checkInternet().then((conn2) {
      return conn2;
    });
    if (chkInternet == true) {
      var url = Uri.parse("http://10.179.28.7:8080/api/check-connectivity");

      var response =
          await http.post(url, headers: {"Content-Type": "application/json"});

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
