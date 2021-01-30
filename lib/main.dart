import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:showon/navigation.dart';

void main()async{
  // this is used for core package
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigationPage(),
    );
  }
}
