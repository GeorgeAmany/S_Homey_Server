import 'package:firebase_database/firebase_database.dart';



class Devices {

  final String Name;
  final String RoomID;
  final String type;
  int value;
  final String id;

  Devices({required this.type, required this.RoomID, required this.Name,required this.value,required this.id,});




  //  String name ;
  //  String roomsId ;
  //  int value ;
  //  String socketId ;
  //  bool isSwitched ;
  //
  // Devices({required this.name,  required this.roomsId ,required this.value , required this.socketId, required this.isSwitched });
  //
  // void getStatus() async {
  //   print("socket from inside is: " + socketId.toString());
  //
  //   var newValue = (await FirebaseDatabase.instance
  //       .reference()
  //       .child('Devices/'+ socketId +'/value').onValue.listen((event) {
  //
  //       event.snapshot.value.toString() == "1"? isSwitched = true : isSwitched = false;
  //       print("is switched from inside is: " + isSwitched.toString());
  //
  //   }));
  //   //print(isSwitched);
  //   //  print("newValue: "+ newValue.toString());
  //
  // }


}