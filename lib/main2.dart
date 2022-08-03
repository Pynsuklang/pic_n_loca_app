import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/camera-file.dart';
import 'package:pic_n_loca_app/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  dynamic tkn;
  saveValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('key', "1"); //1 for logged in and 0 for logged out
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? strx = prefs.getString('key');
    return strx;
  }

  @override
  void initState() {
    super.initState();
    saveValue();
    getValue().then((vals) {
      setState(() {
        tkn = vals;
        print("tkn is $tkn");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: tkn == "1" ? MYHome() : const LoginScreen(),
    );
  }
}
