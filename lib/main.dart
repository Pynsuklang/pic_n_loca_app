// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/create_account.dart';
import 'package:pic_n_loca_app/forgot-pwd.dart';
import 'package:pic_n_loca_app/upload-all-pics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

import 'package:http/http.dart' as http;

void main() => runApp(MyApp());
var glbusrname;
late SharedPreferences cntr;
var timeactive = 1;
String username = "";
List<dynamic> tosend = [];
late SharedPreferences tableAvl;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeplayon Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLoginPage(),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //Clean up the controller when the widget is disposed.
    super.dispose();
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
        appBar: AppBar(
          title: const Text("Login"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const LoginForm(),
              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const ForgotPwdPg()));
              //   },
              //   child: const Text(
              //     'Forgot Password',
              //   ),
              // ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateAccountPage()));
                },
                child: const Text(
                  'Create Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late SharedPreferences logindata;
  late bool newuser;
  dynamic resp;

  postRequest(dynamic usnm, dynamic pwd) async {
    var response;
    var responseDecode;
    try {
      var url = Uri.parse("http://10.179.28.22:8081/api/user-login");
      Map data = {'email': usnm, 'password': pwd};
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

  // ignore: non_constant_identifier_names
  void check_if_already_login() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    print(newuser);
    if (newuser == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyDashboard()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_if_already_login();
  }

  @override
  void dispose() {
    //Clean up the controller when the widget is disposed.
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                controller: usernameCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'username',
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'This field cannot be empty';
                  return null;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                obscureText: true,
                controller: passwordCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
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
              username = usernameCtrl.text;
              String password = passwordCtrl.text;
              if (formKey.currentState!.validate()) {
                var chkInternet = await checkInternet().then((conn2) {
                  return conn2;
                });
                if (chkInternet == true) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(minutes: 10),
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          Text('Please wait...')
                        ],
                      )));
                  var permisn = await initgetLocation().then((permis) {
                    return permis;
                  });
                  print("permisn is $permisn");
                  if (permisn == '1') {
                    postRequest(username, password).then((vals) {
                      setState(() async {
                        print("vals is $vals");
                        resp = vals;
                        print("resp is $resp");
                        if (resp == 0) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          glbusrname = username;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Login Successfull!. Please donot disable the location of this device while using this app')));
                          logindata.setBool('login', false);
                          logindata.setString('username', username);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyDashboard()));
                        } else if (resp == 1) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Unauthorised Credentials!!!')));
                        } else if (resp == 2) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Server Unreachable!!!')));
                        } else if (resp == 3 || resp == null) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Server Error!!!')));
                        } else if (resp == 4) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Permission not yet granted by admin')));
                        } else {
                          print("don problem 2");
                        }
                      });
                    });
                  } else if (permisn == '-1') {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please set location permission for this app to "Always" or "WhileInUse"')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Internet Not Available!!!')));
                }
              }
            },
            child: const Text("Log-In"),
          )
        ],
      ),
    );
  }
}
