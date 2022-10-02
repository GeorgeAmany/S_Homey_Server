import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:s_homey_test/model/rooms.dart';
import 'package:s_homey_test/views/read_database.dart';
import 'package:s_homey_test/views/socket_page.dart';
import 'package:s_homey_test/views/write_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> database = Firebase.initializeApp();


  List <Rooms> roomList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(' Home Page'),
        ),

        body:  ListView.builder(
          itemCount: roomList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                  color: Colors.grey.withOpacity(0.5),
                  child: Text(roomList[index].name),
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> SocketId(),
                      ));
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('clickRoom', roomList[index].roomId);


                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context)=> WriteDatabase(),
                  //     ));
                }),
            );
          },
        )
    );
  }

  void getRooms() async {

    String testHomeID= "-MxVX8geYIiXKG2-Xs2r";

    final url = Uri.parse(
        'https://shomey-test-default-rtdb.firebaseio.com/Rooms.json?orderBy="HomeID"&equalTo="' + testHomeID +'"');

    await http.get(url).then((value) {

      List <Rooms> roomListtt = [];

      final extractedData = json.decode(value.body);
      //loop
      extractedData.forEach((key , value){
        roomListtt.add(Rooms(
          name: value['Name'],
          homeId:value['HomeID'],
          roomId: key ,

        ));

      });

      setState(() {
        roomList = roomListtt ;
      });

    });


  }
}
