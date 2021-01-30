import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showon/pages/comments.dart';
import 'package:showon/tab/add_video.dart';
import 'package:showon/tab/messages_page.dart';
import 'package:showon/tab/profile_page.dart';
import 'package:showon/tab/search_page.dart';
import 'package:showon/tab/video_page.dart';
import 'package:showon/widget/variables.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
List pageOptions =[
  VideoPage(),
  SearchPage(),
  AddVideoPage(),
  MessagesPage(),
  ProfilePage(FirebaseAuth.instance.currentUser.uid),
];
customIcon(){
  return Container(
    width: 45,
    height: 25,
    child: Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10),
          width: 40,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 250, 45, 100),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 10),
          width: 40,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 32, 210, 234),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Center(
          child: Container(
            height: double.infinity,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.add,size: 20),
          ),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: pageOptions[page],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: page,
      onTap: (index){
        setState(() {
          page = index;
        });
      },
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,size: 25),
          title: Text('Home',style: (myStyle(12))),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search,size: 25),
          title: Text('Search',style: (myStyle(12))),
        ),
        BottomNavigationBarItem(
          icon: customIcon(),
          title: Text('',style: (myStyle(12))),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message,size: 25),
          title: Text('Messages',style: (myStyle(12))),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person,size: 25),
          title: Text('Profile',style: (myStyle(12))),
        ),
      ],
    ),
  );
}
}
