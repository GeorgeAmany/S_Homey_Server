import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:s_homey_test/home_page.dart';
import 'package:s_homey_test/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  List<User> user = [];
  String email= '';
  String pass= '';


  String id = '';
  String name = '';
  String number = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Login',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)
            ),
            backgroundColor: Colors.blue.shade400
        ),


        body: Padding(

            padding: const EdgeInsets.all(20),
            child: ListView(scrollDirection:Axis.vertical ,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(

                        child: const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text('S.Homey',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30) //Textstyle
                            ) //Text
                        ),

                      ),
                    ],

                  ),

                  Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: TextField(
                        decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                            icon: Icon(Icons.email)),
                        onChanged: (v){
                          email= v;
                        },
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: TextField(
                        decoration: InputDecoration(
                            labelText: 'Enter your Password',
                            labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                            icon: Icon(Icons.lock)),
                        onChanged: (p){
                          pass= p ;
                        },
                      )
                  ),
                  Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                          child: const Padding(
                              padding: EdgeInsets.all(15), child: Text('Login',
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),

                          onPressed: () async {
                            _CheckNamePassword();

                          }


                      )
                  ),

                ]
            )
        )
    );

  }


  String passData = "";
  String emailData = "";

  Future<void> _CheckNamePassword() async {


      //String email= prefs.getString('email')!;

      final url = Uri.parse(
          'https://shomey-test-default-rtdb.firebaseio.com/users.json?orderBy="email"&equalTo="' + email +'"');

      await http.get(url).then((value) async{

        if(value.body == "{}"){
          // set up the button
          Widget okButton = TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );

          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: Text("Wrong Email"),
            content: Text("Wrong data "),
            actions: [
              okButton,
            ],
          );

          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );


        }else{

          final extractedData = json.decode(value.body);
          //loop
          extractedData.forEach((key , value){
            /*userListtt.add(User(
            name: value['name'],
            id: key,
            email: value['email'],
            number: value['number'],
            password: value['password'],

          ));*/

            id = key;
            passData = value['password'];
            emailData = value['email'];
            name = value['name'];
            number = value['number'];

            print("id from login: " + key);
          });

          if(passData == pass){

            //shared pref low el user 3ando data wala la
            final prefs = await SharedPreferences.getInstance();
            final userData = json.encode({
              'id': id,
              'password': pass,
              'email': email,
              'name': name,
              'number': number,

            },);

            prefs.setString('userData', userData);
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));

          }
          else{
            // set up the button
            Widget okButton = TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );

            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
              title: Text("Wrong Password"),
              content: Text("Wrong data "),
              actions: [
                okButton,
              ],
            );

            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          }

        }





      });
    }

  }
















