import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:showon/tab/video_page.dart';
import 'package:showon/widget/variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

registerUser(){
  FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
  ).then((signedUser){
    userCollection.doc(signedUser.user.uid).set({
      'username':usernameController.text,
      'password':passwordController.text,
      'email':emailController.text,
      'uId':signedUser.user.uid,
      'profilePic':'https://st.depositphotos.com/1779253/5140/v/600/depositphotos_51405259-stock-illustration-male-avatar-profile-picture-use.jpg',
    });
  });
  Navigator.pop(context);
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.greenAccent,
    body: SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Social App',style: myStyle(30,Colors.orangeAccent,FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Registration',style: myStyle(25,Colors.black,FontWeight.w600),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  labelStyle: myStyle(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail),
                  labelStyle: myStyle(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  labelStyle: myStyle(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: (){
                registerUser();
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('Register',style: myStyle(20,Colors.white,FontWeight.w600)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Text(
              'Or',
              style: myStyle(18),
            ),
            InkWell(
              onTap: (){
                registerUser();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                child: OutlineButton.icon(
                  label: Text(
                    'Sign In with Google',
                    style: myStyle(18,Colors.white,FontWeight.w600),
                  ),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                  highlightedBorderColor: Colors.black,
                  borderSide: BorderSide(color: Colors.black),
                  textColor: Colors.black,
                  icon: FaIcon(FontAwesomeIcons.google,color: Colors.red,),
                  onPressed: (){
                    signIn();
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Have an Account?',style: myStyle(16)),
                SizedBox(width: 10),
                Text('Login',style: myStyle(16,Colors.orangeAccent)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Future signIn()async{
  final GoogleSignInAccount googleSignInAccount=await GoogleSignIn().signIn();
  final GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount.authentication;
  AuthCredential credential=GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken
  );
  UserCredential result=await FirebaseAuth.instance.signInWithCredential(credential);
  FirebaseUser user=result.user;
  if (user !=null){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPage()));
  }
  }
}
