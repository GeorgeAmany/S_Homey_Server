import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class WriteDatabase extends StatefulWidget {
  const WriteDatabase({Key? key}) : super(key: key);

  @override
  State<WriteDatabase> createState() => _WriteDatabaseState();
}

class _WriteDatabaseState extends State<WriteDatabase> {
  final database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    final homes = database.child('Home/');
    final devices = database.child('Device/');
    final rooms = database.child('Rooms/');
    return Scaffold(
      appBar: AppBar(
        title: Text('Write To Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    final home = <String, dynamic>{
                      'Name': getHomeName(),
                      'Owner': getHomeOwner(),
                    };
                    final rooms = <String, dynamic>{
                      'Name': getRoomsName(),
                      'HomeID': getRoomHomeId(),
                    };
                    final devices = <String, dynamic>{
                      'Name': getDevicesName(),
                      'RoomID': getDeviceRoomId(),
                    };
                    // this baseiclly says go ahead and crete a shorter random ID and use that as our new refrance for this child node and then i can go ahead and call set() here with that map i create earlier
                    database
                        .child('Home')
                        .push()
                        .set(home)
                        .then((_) => print('homee has been written'))
                        .catchError(
                            (error) => print('you got an error $error'));
                    database
                        .child('Rooms')
                        .push()
                        .set(rooms)
                        .then((_) => print('Rooms has been written'))
                        .catchError(
                            (error) => print('you got an error $error'));
                    database
                        .child('Devices')
                        .push()
                        .set(devices)
                        .then((_) => print('Devices has been written'))
                        .catchError(
                            (error) => print('you got an error $error'));
                  },
                  child: Text('Append a house')),
            ],
          ),
        ),
      ),
    );
  }

  ///-----------Home-----------------------------------------------------------------
  String getHomeName() {
    final homesNameList = ['fff'];
    return homesNameList[Random().nextInt(homesNameList.length)];
  }

  String getHomeOwner() {
    final homesOwnerList = ['ffddd'];
    return homesOwnerList[Random().nextInt(homesOwnerList.length)];
  }

  ///-------------Rooms-------------------------------------------------------------------

  String getRoomsName() {
    final roomsNameList = ['hhhh'];
    return roomsNameList[Random().nextInt(roomsNameList.length)];
  }

   getRoomHomeId() {
    final roomsHomeIdList = ['dfg'];
    return roomsHomeIdList[Random().nextInt(roomsHomeIdList.length)];
  }

  ///---------------Devices-----------------------------------------------------------------

  String getDevicesName() {
    final devicesNameList = ['dfg'];
    return devicesNameList[Random().nextInt(devicesNameList.length)];
  }


  getDeviceRoomId() {
    final devicesRoomsIdList = ['werwe'];
    return devicesRoomsIdList[Random().nextInt(devicesRoomsIdList.length)];
  }

  ///-------------------------------------------------------------------------
}

//// ElevatedButton(
//     onPressed: () async {
//       try {
//         await homes.set(
//             {'Name': '', 'Owner': ''});
//         print('done 1');
//       } catch (error) {
//         'you got an error $error';
//       }
//
//     },
//     child: Text('Add Home')
// ),
//
// ElevatedButton(
//     onPressed: () async {
//       try {
//         await devices.set(
//             {'Name': '', 'SocketNumber': 0,'Room ID': 0});
//         print('done 2');
//       } catch (error) {
//         'you got an error $error';
//       }
//
//     },
//     child: Text('Add Devices')
// ),
//
// ElevatedButton(
//     onPressed: () async {
//       try {
//         await rooms.set(
//             {'Name': '', 'Home ID': 0});
//         print('done 3');
//       } catch (error) {
//         'you got an error $error';
//       }
//
//     },
//     child: Text('Add Rooms')
// )
//
