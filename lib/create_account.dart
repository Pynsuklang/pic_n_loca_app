// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeplayon Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateAccountPage(),
    );
  }
}

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
        title: const Text("Shared Preferences"),
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

  Future<http.Response> CreateAccountRequest(
      dynamic name, dynamic usnm, dynamic pwd) async {
    var response = null;
    var url = Uri.parse("http://10.179.28.7:8080/api/create-account");
    print("password is $pwd");
    var data = {'name': name, 'usnm': usnm, 'pwd': pwd};
    //encode Map to JSON
    var body = json.encode(data);

    response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.statusCode}");
    print("${response.body}");
    return response;
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
              onPressed: () {
                print('Successfull');
                String username = username_controller.text;
                String password = _pass.text;
                String name = name_controller.text;
                if (_formKey.currentState!.validate()) {
                  print('Successfull');

                  CreateAccountRequest(name, username, password).then((vals) {
                    setState(() {
                      print("vals is ${vals.body}");
                      resp = vals.body;

                      if (resp == '1') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Account Already Existed')));
                      } else if (resp == '0') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Account Created Successfully!!!')));
                      } else if (resp != '0' || resp != '1') {
                        print("resp now is $resp");
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Server Error!!!')));
                      }
                    });
                  });
                }
              },
              child: Text("Create Account"),
            )
          ],
        ));
  }
}
