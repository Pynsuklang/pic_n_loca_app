import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class ForgotPwdPg extends StatefulWidget {
  const ForgotPwdPg({Key? key}) : super(key: key);

  @override
  State<ForgotPwdPg> createState() => _ForgotPwdPgState();
}

class _ForgotPwdPgState extends State<ForgotPwdPg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Preferences"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            ForgotPwd(),
          ],
        ),
      ),
    );
  }
}

class ForgotPwd extends StatefulWidget {
  const ForgotPwd({Key? key}) : super(key: key);

  @override
  State<ForgotPwd> createState() => _ForgotPwdState();
}

class _ForgotPwdState extends State<ForgotPwd> {
  final _usrname = TextEditingController();
  final ForgotformKey = GlobalKey<FormState>();
  late SharedPreferences logindata;
  late bool newuser;

  void check_if_already_login() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    if (newuser == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyDashboard()));
    }
  }

  @override
  void initState() {
    super.initState();
    check_if_already_login();
  }

  @override
  void dispose() {
    _usrname.dispose();
    super.dispose();
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

  Future<dynamic> forgotPwd(dynamic usnm) async {
    var response;
    var responseDecode;
    try {
      var url = Uri.parse("http://10.179.28.7:8080/api/forgot-pwd");
      Map data = {'email': usnm};
      var body = json.encode(data);
      response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      try {
        responseDecode = json.decode(response.body);
        print("responseDecode is $responseDecode");
        return responseDecode;
      } catch (e) {}
    } on SocketException catch (_) {
      responseDecode = 2;
      return responseDecode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ForgotformKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                controller: _usrname,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'username',
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'This field cannot be empty';
                  return null;
                }),
          ),
          RaisedButton(
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async {
              String username = _usrname.text;
              if (ForgotformKey.currentState!.validate()) {
                var chkInternet = await checkInternet().then((conn2) {
                  return conn2;
                });
                if (chkInternet == true) {
                  forgotPwd(username).then((vals) {
                    if (vals == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Password reset link sent to registered email!!!')));
                    } else if (vals == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('This account does not exist!!!')));
                    } else if (vals == 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Server Error!!!')));
                    } else if (vals == 2) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Server Unreachable!!!')));
                    } else {}
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Internet Not Available!!!')));
                }
              }
            },
            child: const Text("Get Reset Link"),
          )
        ],
      ),
    );
  }
}
