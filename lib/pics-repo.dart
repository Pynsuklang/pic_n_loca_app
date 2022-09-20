import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pic_n_loca_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

late dynamic indx;

class RouteOne extends StatefulWidget {
  @override
  State<RouteOne> createState() => _RouteOneState();
}

class _RouteOneState extends State<RouteOne> {
  List<dynamic> i_items = [];
  var i_items2a;
  @override
  void initState() {
    super.initState();
    getimages();
  }

  @override
  getimages() async {
    try {
      SharedPreferences datalistmap = await SharedPreferences.getInstance();
      int? cntrval = datalistmap.getInt("cntrkey"); //
      for (var i = 1; i <= cntrval!; i++) {
        var rawdata = datalistmap.getString("reservedatalist$i");
        var decodeddata = json.decode(rawdata!);
        print("\n decodeddata $i is ${decodeddata["imageByte"]}");

        setState(() {
          // Uint8List i_items2 = decodeddata["imageByte"];
          i_items2a = decodeddata["imageByte"];
          i_items.add(decodeddata["imageByte"]);
        });
        //Image.memory(base64Decode(base64String));
        //image = Image.memory(_image)

      }
      print("i_items2a is $i_items2a");
    } catch (e) {
      print("Error is $e");
    }
  }

//You can convert the Image to Unit8List then convert UnitList8 to base64 and save it
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.blue,
        ),
        child: MyDrawer(),
      ),
      appBar: AppBar(
        title: Text('Screen one ☝️'),
      ),
      body: Center(
        child: Container(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              crossAxisCount: 3,
            ),
            itemCount: i_items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    indx = index;
                    print('indx is $indx');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteTwo(
                            //hangne mo
                            image: i_items[index].image,
                            name: i_items[index].name),
                      ),
                    );
                  },
                  child: Image.memory(
                      base64Decode(i_items[index])) //Image.file(i_items[index])
                  );
            },
          ),
        ),
      ),
    );
  }
}

class RouteTwo extends StatefulWidget {
  final String image;
  final String name;

  RouteTwo({Key? key, required this.image, required this.name})
      : super(key: key);

  @override
  State<RouteTwo> createState() => _RouteTwoState();
}

class _RouteTwoState extends State<RouteTwo> {
  List<dynamic> i_itemsx = [];
  // ignore: non_constant_identifier_names
  dynamic i_items2b;
  @override
  void initState() {
    super.initState();
    displaypic();
  }

  displaypic() async {
    try {
      print("reached displaypic()");
      SharedPreferences datalistmap = await SharedPreferences.getInstance();
      //int? cntrval = indx; //
      var rawdata = datalistmap.getString("reservedatalist$indx");
      var decodeddata = json.decode(rawdata!);
      print("\n decodeddata $indx is ${decodeddata["imageByte"]}");

      setState(() {
        i_items2b = decodeddata["imageByte"];
        i_itemsx.add(decodeddata["imageByte"]);
      });

      print("i_items2b is $i_items2b");
    } catch (e) {
      print("Error in displaypic() is $e");
    }
  }

  // @override
  // displaypic() async {

  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen two ✌️'),
      ),
      body: Column(
        children: [
          Image.memory(base64Decode(i_items2b)),
        ],
      ),
    );
  }
}
