import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:s_homey_test/home_page.dart';
import 'package:s_homey_test/views/home_page.dart';


void main() async{

  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  runApp( new MaterialApp(home: HomePage(),));
}