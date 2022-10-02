///page 1
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_homey_test/drawar.dart';
import 'package:s_homey_test/login_page.dart';
import 'package:s_homey_test/model/access.dart';
import 'package:s_homey_test/model/homes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


import 'dart:io' as io;


late List<CameraDescription> cameras;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

 // cameras = cameras;


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  String dropdownHomeValue = "select a home";
  List<Homes> Home = [];


  bool connected = false;




  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;


  int _deviceState = 0;

  final Future<FirebaseApp> database = Firebase.initializeApp();


  CameraController? controller;
  bool _isCameraInitialized = false;



  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _CheckLogin();

    onNewCameraSelected(cameras[0]);

  }


/*
  void initCamera() async{

    _cameras = await availableCameras();

    controller = CameraController(_cameras[0], ResolutionPreset.max);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });

  }
*/

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }


  Future<void> connectTo() async {

      // Trying to connect to the device using
      // its address
      await BluetoothConnection.toAddress(_devicesList[_devicesList.indexWhere((f) => f.name == "HC-05")].address)
          .then((_connection) {
        print('Connected to the device');
        getStatusDoors(_connection);
        //connection = _connection;

        // Updating the device connectivity
        // status to [true]
        setState(() {
          connected = true;
        });

        // This is for tracking when the disconnecting process
        // is in progress which uses the [isDisconnecting] variable
        // defined before.
        // Whenever we make a disconnection call, this [onDone]
        // method is fired.

      }).catchError((error) {
        print('Cannot connect, exception occurred');
        print(error);

        setState(() {
          connected = false;
        });

      });



  }




  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }



  // for storing the devices list
  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
      print(_devicesList[_devicesList.indexWhere((f) => f.name == "HC-05")].address);
      connectTo();
    });
  }


  var image;


  io.File? _pickedImage;


  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text("device.name"),
          value: device,
        ));
      });
    }
    return items;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('SHomey' ,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.black54
      ),

      ///init drawar
      drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors
                .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
          ),
          child: drawer()),

      body: RefreshIndicator(child: ListView(
        scrollDirection:Axis.vertical ,
        children: [

          Center(
              child: Text(' Server is online',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600 ,
                    color: Colors.blue,),
                  ),
          ),

          Row(
            children: [
              Text(connected? "Connected" : "Not Connected"),
              Padding(
                padding: EdgeInsets.all(25),
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: connected? Colors.green : Colors.grey),
                  ),
                ),

              ),
            ],
          ),

         /* IconButton(
              onPressed: () async{

     *//* final ImagePicker _picker = ImagePicker();
      await _picker.pickImage(source: ImageSource.gallery).then((value) async {



        if (value != null) {
          var selected = io.File(value.path);
          print("path: " + selected.toString());

          final bytes = await io.File(value.path).readAsBytes();


          final urll = Uri.parse(
              'http://130.61.16.206:5000/UploadImage');

          //print("22");

          await http.post(
            urll,
            body: json.encode({
              'id': "clickedCard",


            }),
          ).then((value) {

            print("value" + value.toString());

          });


          String rr = base64.encode(bytes);


          print("bytes: " + rr);

*//**//*          setState(() {
            _file = selected;
          });*//**//*


      }

      });
*//*


                  final CameraController? cameraController = controller;
                  if (cameraController!.value.isTakingPicture) {
                    // A capture is already pending, do nothing.
                    return null;
                  }
                  try {
                    await cameraController.takePicture().then((value) {

                      print("value" + value.toString());



                    });




                  } on CameraException catch (e) {
                    print('Error occured while taking picture: $e');
                    return null;
                  }




              },
              icon: const Icon(
                Icons.camera,
                color: Colors.black,
                size: 50,
              )),*/


          _isCameraInitialized
              ? AspectRatio(
            aspectRatio: 1 / controller!.value.aspectRatio,
            child: controller!.buildPreview(),
          )
              : Container()






        ],
      )
          , onRefresh:  () => _CheckLogin())


    );
  }




  Future<void> _CheckLogin() async {






    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')){

    getHomes();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });


    _deviceState = 0; // neutral


    enableBluetooth();


    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // For retrieving the paired devices list
        getPairedDevices();
      });
    });




    }
    else{
     Navigator.of(context).pop();
     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginPage()));
    }
  }


/*  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
     // showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}*/


  void getStatusDoors(BluetoothConnection connection) async {
    //print("socket from inside is: " + doorID.toString());


    connection.input!.listen(_onDataReceived).onDone(() {



    });

//Long Home
    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5Wh2sUZZBWvb8RPdwv/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "A")
          : turnOff(connection, "a");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5Wh2vMKeblcYIuB8jb/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "B")
          : turnOff(connection, "b");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WhAxk0QXvJAkrLBgd/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "C")
          : turnOff(connection, "c");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WhboascFYVpPX8e_c/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "D")
          : turnOff(connection, "d");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WhbgGcj87etILnMwS/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "E")
          : turnOff(connection, "e");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5Whqa6bynlyp9RIOaS/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "F")
          : turnOff(connection, "f");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WiCXu5bOXI5KWP8uT/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "G")
          : turnOff(connection, "g");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WiCXu5bOXI5KWP8uT/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "H")
          : turnOff(connection, "h");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WiCsyTchgaj0bMlIc/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "I")
          : turnOff(connection, "i");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });



    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5aEZG2RtYkoZO5JmQu/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "J")
          : turnOff(connection, "j");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WgIWO39CkYxkb8fAe/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "N")
          : turnOff(connection, "n");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5fW_mRvMF1GPXXBqgQ/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "L")
          : turnOff(connection, "l");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('garage/-N5wRpyOt2REV7xvImHo/value')
        .onValue
        .listen((event) async {
      event.snapshot.value == 1
          ? turnOn(connection, "J")
          : turnOff(connection, "j");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {

      });


      final url = Uri.parse(
          'https://shomey-test-default-rtdb.firebaseio.com/garage/-N5wRpyOt2REV7xvImHo.json');


      await http
          .patch(
        url,
        body: json.encode({
          'value': 0,
        }),
      );

    });


//short home
 /*   await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHFl6ERH4weZvZcsj/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "A")
          : turnOff(connection, "a");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHFhS4JO0QAsvQTQU/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "B")
          : turnOff(connection, "b");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHM5S64lgmvvmpRrP/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "C")
          : turnOff(connection, "c");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHn1KTPmfNajIB-W_/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "D")
          : turnOff(connection, "d");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHn4UcWHXys_SOl0b/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "E")
          : turnOff(connection, "e");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WI0kuX1EnXJU_4bR4/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "F")
          : turnOff(connection, "f");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });


    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WIgmUIvnNlw9Uly8h/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "G")
          : turnOff(connection, "g");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WIgsOQZTXMKJG0KHP/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "H")
          : turnOff(connection, "h");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WHFeBQx8jqZGuWs_G/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "I")
          : turnOff(connection, "i");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });

    await FirebaseDatabase.instance
        .reference()
        .child('Devices/-N5WIgpIOkrIX_9H7Wpx/value')
        .onValue
        .listen((event) {
      event.snapshot.value == 1
          ? turnOn(connection, "K")
          : turnOff(connection, "k");
      print("is switched from inside is: " + event.snapshot.value.toString());

      setState(() {});
    });*/

    //print(isSwitched);
    //  print("newValue: "+ newValue.toString());
  }


  Future<void> _onDataReceived(Uint8List data) async {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    //print(data);
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    print(dataString);

    if(dataString == "1"){

      //get

      final url = Uri.parse(
          'https://shomey-test-default-rtdb.firebaseio.com/alert.json');


      await http
          .patch(
        url,
        body: json.encode({
          'value': 1,
        }),
      );


    }
    else if(dataString == "Z"){


      final CameraController? cameraController = controller;
      if (cameraController!.value.isTakingPicture) {
        // A capture is already pending, do nothing.
        return null;
      }
      try {
        await cameraController.takePicture().then((value) async{

          try{

            print("value" + value.toString());

            final bytes = await io.File(value.path).readAsBytes();

            print("33333333aaaaaaaaa");

            final url = Uri.parse(
                'https://shomey-test-default-rtdb.firebaseio.com/garage/-N5wRpyOt2REV7xvImHo.json');


            await http
                .patch(
              url,
              body: json.encode({
                'image': base64.encode(bytes),
              }),
            );

          }catch(e){
            print("e: " + e.toString());
          }



        });




      } on CameraException catch (e) {
        print('Error occured while taking picture: $e');
        return null;
      }



    }
    /*else if(dataString == "x"){


      try{



        print("xxxxxxxxxxxxxxxxxxx");

        final url = Uri.parse(
            'https://shomey-test-default-rtdb.firebaseio.com/garage/-N5wRpyOt2REV7xvImHo.json');


        await http
            .patch(
          url,
          body: json.encode({
            'value': 0,
            'image': "",
          }),
        );

      }catch(e){
        print("e: " + e.toString());
      }


    }*/


  }



  void getHomes() async{

    Home = [];

    Home.add(Homes(
      ID : "",
      homeName : "select a home",
      Dimensions : "",
      Address : "",
      userId : "",
      RoomsNumber : "",
      garden : "",
      garage : "",
      security : "",
    ));
    final prefs = await SharedPreferences.getInstance();

    final extractedUserData = json.decode(prefs.getString('userData').toString()) as Map<String, dynamic>;
    String userId = extractedUserData['id'].toString();

    final url = Uri.parse(
        'https://shomey-test-default-rtdb.firebaseio.com/access.json?orderBy="userID"&equalTo="$userId"');

    print("userId: " + userId);
    try {
      await http.get(url).then((value) async {

        print("response of session: " + value.body);

        //response.body?? "";

        final extractedData = json.decode(value.body);

        final List<Access> loadData = [];


        extractedData?.forEach((Key, value) {
          loadData.add(Access(
            id: Key,
            objectID: value['objectID'],
            type: value['type'],
            userID: value['userID'],
          ));

        });

        final List<Homes> loadDataa = [];


        for(int i = 0; i< loadData.length; i++){

          if(loadData[i].type == "1"){

            String homeID = loadData[i].objectID;

            final url = Uri.parse(
                'https://shomey-test-default-rtdb.firebaseio.com/Home/$homeID.json');

            await http.get(url).then((value) {

              final extractedData = json.decode(value.body);

              loadDataa.add(Homes(
                ID : homeID,
                homeName : extractedData['homeName'],
                Dimensions : extractedData['Dimensions'],
                Address : extractedData['Address'],
                userId : extractedData['userId'],
                RoomsNumber : extractedData['RoomsNumber'],
                garden : extractedData['garden'],
                garage : extractedData['garage'],
                security : extractedData['security'],
              ));

            });

          }

        }

        setState(() {
          Home += loadDataa;
          dropdownHomeValue= Home[0].homeName;
        });

      });



    } catch (error) {
      throw (error);
    }


  }

  void turnOn(BluetoothConnection connection, String num) async {
    connection.output.add(Uint8List.fromList(utf8.encode(num + "\r\n")));
    await connection.output.allSent;
    print('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }


  void turnOff(BluetoothConnection connection, String num) async {
    connection.output.add(Uint8List.fromList(utf8.encode(num + "\r\n")));
    await connection.output.allSent;
    print('Device Turned Off');
    setState(() {
      _deviceState = 1; // device on
    });
  }

}



//pushNamed(routeName)
