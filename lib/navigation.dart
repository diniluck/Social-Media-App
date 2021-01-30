import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showon/pages/home_page.dart';
import 'package:showon/pages/login.dart';
class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool isSigned = false;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if(user !=null){
        setState(() {
          isSigned = true;
        });
      }else{
        setState(() {
          isSigned = false;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSigned==false? LoginPage():HomePage(),
    );
  }
}
