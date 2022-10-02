import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:s_homey_test/model/devices.dart';

class SocketId extends StatefulWidget {
  const SocketId({Key? key}) : super(key: key);

  @override
  State<SocketId> createState() => _SocketIdState();
}

class _SocketIdState extends State<SocketId> {
  bool isSwitched = false;
  List <Devices> DevicesList = [];
  final _database = FirebaseDatabase.instance.reference();
  String testRoomID= "";
  String _displayText = 'Results go here';

  @override
  initState(){
    // TODO: implement initState
    super.initState();
    getSocket();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Socket Page'),
      ),

      body: Center(
        child:(
            ListView.builder(
              itemCount: DevicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(DevicesList[index].Name),
                  trailing: Switch(
                    value: DevicesList[index].value== 1?  true : false,
                      onChanged: (value) {

                        setState(() {

                         isSwitched = value;
                         print(isSwitched);
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                  ),
                );
              },

            )
        ),

      ),
    );
  }

  void getSocket() async {

try{


  final prefs = await SharedPreferences.getInstance();

  testRoomID = prefs.getString('clickRoom')!;

  final url = Uri.parse(
      'https://shomey-test-default-rtdb.firebaseio.com/Devices.json?orderBy="RoomID"&equalTo="' + testRoomID +'"');
  print(testRoomID);
  await http.get(url).then((value) {

    List <Devices> DevicesListtt = [];

    final extractedData = json.decode(value.body);
    print(extractedData);
    //loop
    extractedData.forEach((key , value){
      DevicesListtt.add(Devices(
        Name: value['Name'],
        RoomID:value['RoomID'],
        value: value['value'],
        type: value['type'],
        id: key ,
        // isSwitched: value['value'] == "1"?  true : false,

        // FirebaseDatabase.instance.reference().child('Devices/'+key+'/value').onChildChanged.listen((event) {
        //   final Object? RoomId = event.snapshot.value ;
        // });

      ));



    });

    setState(() {
      DevicesList = DevicesListtt ;
    });

    //
    // for(int i = 0; i<DevicesList.length; i++){
    //
    //   DevicesList[i].getStatus();
    //
    // }

  });

}catch(err){
  print(err);
};

  }

}



