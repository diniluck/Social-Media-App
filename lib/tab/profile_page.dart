//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:showon/pages/login.dart';
import 'package:showon/widget/variables.dart';

class ProfilePage extends StatefulWidget {
  final String uId;
  ProfilePage(this.uId);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username;
  String onlineUser;
  String profilePic;
  int likes=0;
  Future myVideos;
  bool dataIsThere=false;
  FirebaseAuth auth=FirebaseAuth.instance;
  int followers;
  int following;
  bool isFollow=false;
  TextEditingController userController=TextEditingController();

  signOut()async{
    await auth.signOut();
  }


  getAllData()async{
    myVideos=videosCollection.where('uId',isEqualTo: widget.uId).get();
    //get Current user
    onlineUser=FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot userDoc=await userCollection.doc(widget.uId).get();
    username=userDoc.data()['username'];
    profilePic=userDoc.data()['profilePic'];
    var documents=await videosCollection.where('uId',isEqualTo: widget.uId).get();
    for(var item in documents.docs){
      likes =item.data()['likes'].length+likes;
    }
    var followerDocument=await userCollection.doc(widget.uId).collection('followers').get();
    var followingDocument=await userCollection.doc(widget.uId).collection('following').get();

    followers=followingDocument.docs.length;
    followers=followingDocument.docs.length;
    //chck if already following
    userCollection.doc(widget.uId).collection('followers').doc(onlineUser).get().then((document){
      if(!document.exists){
        setState(() {
          isFollow=false;
        });
      }else{
        setState(() {
          isFollow=true;
        });
      }
    });
    setState(() {
      dataIsThere=true;
    });
  }
  @override
  void initState(){
    super.initState();
    getAllData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataIsThere==false ? Center(
        child: CircularProgressIndicator(),
      ): SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(top: 20),
          alignment: Alignment.center,
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.greenAccent,
                backgroundImage: NetworkImage(profilePic),
              ),
              SizedBox(height: 20),
              Text(username,style: myStyle(20,Colors.black,FontWeight.w500)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(following.toString(),style: myStyle(20,Colors.black,FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Following',style: myStyle(15,Colors.grey,FontWeight.w600)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(followers.toString(),style: myStyle(20,Colors.black,FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Fans',style: myStyle(15,Colors.grey,FontWeight.w600)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('100',style: myStyle(20,Colors.black,FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(likes.toString(),style: myStyle(15,Colors.grey,FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              onlineUser==widget.uId?
              InkWell(
                onTap: (){
                  editProfile();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 40,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Edit Profile',style: myStyle(20,Colors.white,FontWeight.w500),
                    ),
                  ),
                ),
              ):InkWell(
                onTap: (){
                  followUser();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 40,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      isFollow==false?'Unfollow':'Follow',style: myStyle(20,Colors.white,FontWeight.w500),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              onlineUser==widget.uId?InkWell(
                onTap: (){
                  signOut();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>LoginPage()
                  ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 40,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Logout',style: myStyle(20,Colors.white,FontWeight.w500),
                    ),
                  ),
                ),
              ):Text(''),
              SizedBox(height: 20),
              Text('My Videos',style: myStyle(20)),
              SizedBox(height: 10),
              FutureBuilder(
                future: myVideos,
                builder: (BuildContext context, snapshot){
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }
                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (BuildContext context, int index){
                      DocumentSnapshot video=snapshot.data.docs[index];
                      return Container(
                        child: Image(
                          image: NetworkImage(video.data()['previewImage']),
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  followUser()async{
    var document=await userCollection.doc(widget.uId).collection('followers').doc(onlineUser).get();
    if(!document.exists){
      userCollection.doc(widget.uId).collection('followers').doc(onlineUser).set({});
      userCollection.doc(onlineUser).collection('following').doc(widget.uId).set({});
      setState(() {
        isFollow=false;
        followers++;
      });
    }else{
      userCollection.doc(widget.uId).collection('followers').doc(onlineUser).delete();
      userCollection.doc(onlineUser).collection('following').doc(widget.uId).delete();
      setState(() {
        isFollow=true;
        followers--;
      });
    }
  }

  editProfile() {
    return showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Container(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Edit Profile',
                  style: myStyle(20),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 20,right: 20),
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      hintText: 'New User Name',
                      hintStyle: myStyle(18),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: (){
                    userCollection.doc(
                        FirebaseAuth.instance.currentUser.uid
                    ).update({'username':userController.text});
                    setState(() {
                      username=userController.text;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/2,
                    height: 40,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        'Update Now',
                        style: myStyle(16,Colors.white,FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }
}
