import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:s_homey_test/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class drawer extends StatefulWidget {
  const drawer({Key? key}) : super(key: key);

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {

  @override
  void initState() {
    checkType();

    super.initState();
  }

  bool doctor = false;
  bool agent = false;


  void checkType() async{

    final prefs = await SharedPreferences.getInstance();

    final extractedUserData =
    json.decode(prefs.getString('userData').toString())
    as Map<String, dynamic>;
    //print(prefs.getString('userData').toString());
    String loggedType = "";
    loggedType = extractedUserData['type'].toString();

    if(loggedType == "2"){
      //doctor
      setState(() {
        doctor = true;
        agent = false;
      });

    }else if(loggedType == "3"){
      //agent
      setState(() {
        doctor = false;
        agent = true;
      });

    }else {
      setState(() {
        //admin
        doctor = false;
        agent = false;
      });
    }


  }

  Widget cardB(text, fun){
    return Card(
      color: Color(0x71006FFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FlatButton(
          padding: EdgeInsets.all(10),
          minWidth: double.infinity,
          textColor: Color(0xFFFFFFFF),
          onPressed: fun,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            // verticalDirection: VerticalDirection.down,

            children: [
              Container(height: 700.0,)
            ],
          ),
          ElevatedButton(
              child: SizedBox(
                  child: Text('Logout',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  side: BorderSide(width:3, color:Colors.blue),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.all(10)
              ),
              onPressed: () async{
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  await preferences.clear().then((value) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginPage()));
                  });
                }

          )
        ],
      ),
    );
  }
}
