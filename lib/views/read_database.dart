// import 'dart:async';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:s_homey_test/model/rooms.dart';
//
// class ReadDatabase extends StatefulWidget {
//   const ReadDatabase({Key? key}) : super(key: key);
//
//   @override
//   State<ReadDatabase> createState() => _ReadDatabaseState();
// }
//
// class _ReadDatabaseState extends State<ReadDatabase> {
//   String _displayText = 'Results go here';
//   final _database = FirebaseDatabase.instance.reference();
//   late StreamSubscription _Stream;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _activateListeners();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Read from database'),
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Center(
//           child: Column(
//             children: [
//               Text(_displayText,
//                 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 50,),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _activateListeners() {
//     _Stream = _database
//         .child('Rooms/MxUyfPK68emlpmo2gI5/HomeID')
//         .onValue
//         .listen((event) {
//       final data = Map<String, dynamic>.from(
//           event.snapshot.value as Map<dynamic, dynamic>);
//       final myRooms = Rooms.fromRTDB(data);
//       setState(() {
//         _displayText = myRooms.fancyDescription();
//       });
//     }); // onValue this will fire not only when this value changes
//     // but it will also fire the first time if any data exists , which means i will be able to read in this value right away
//   }
//   void deactivate() {
//     _Stream.cancel();
//     super.deactivate();
//   }
// }
//
