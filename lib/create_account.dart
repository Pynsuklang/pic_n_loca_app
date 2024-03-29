// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'main.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.

  late SharedPreferences logindata;
  late bool newuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_if_already_login();
  }

  @override
  void dispose() {
    //Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void check_if_already_login() async {
    logindata = await SharedPreferences.getInstance();
    newuser = (logindata.getBool('login') ?? true);
    print(newuser);
    if (newuser == false) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => MyDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const CreateAccountForm(),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyLoginPage()));
              },
              child: const Text(
                'Already have an account?',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
class CreateAccountForm extends StatefulWidget {
  const CreateAccountForm({Key? key}) : super(key: key);

  @override
  State<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final _pass = TextEditingController();
  final _confirmpass = TextEditingController();
  final name_controller = TextEditingController();
  final username_controller = TextEditingController();
  final password_controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  dynamic resp;

  // ignore: non_constant_identifier_names
  CreateAccountRequest(dynamic name, dynamic usnm, dynamic pwd) async {
    var response;
    var responseDecode;
    try {
      var url = Uri.parse("http://10.179.28.22:8081/api/create-account");
      print("password is $pwd");
      var data = {'name': name, 'usnm': usnm, 'pwd': pwd};
      //encode Map to JSON
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

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                  controller: name_controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'name',
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return 'This field cannot be empty';
                    return null;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                  controller: username_controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'username',
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return 'This field cannot be empty';
                    if (val.isEmpty || !val.contains("@"))
                      return 'This field must contain email id';
                    return null;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                  obscureText: true,
                  controller: _pass,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'password',
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
                  controller: _confirmpass,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'confirm password',
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      print("empty password");
                      return 'empty password';
                    }
                    if (val != _pass.text) {
                      print("no match password");
                      return 'no match password';
                    }
                    return null;
                  }),
            ),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: () async {
                String username = username_controller.text;
                String password = _pass.text;
                String name = name_controller.text;
                if (_formKey.currentState!.validate()) {
                  var chkInternet = await checkInternet().then((conn2) {
                    return conn2;
                  });
                  if (chkInternet == true) {
                    CreateAccountRequest(name, username, password).then((vals) {
                      setState(() {
                        resp = vals;
                        if (resp == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Account Already Existed')));
                        } else if (resp == 0) {
                          username_controller.clear();
                          _pass.clear();
                          name_controller.clear();
                          _confirmpass.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Account Created Successfully!!!')));
                        } else if (resp == 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Server Error!!!')));
                        } else if (resp == 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Server Unreachable!!!')));
                        }
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Internet Not Available!!!')));
                  }
                }
              },
              child: Text("Create Account"),
            )
          ],
        ));
  }
}
