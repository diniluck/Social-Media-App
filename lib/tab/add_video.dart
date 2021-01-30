import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:showon/pages/confirm_page.dart';
import 'package:showon/widget/variables.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  showOptionsDialog(){
    return showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: (){
                  pickVideo(ImageSource.gallery);
                },
                child: Text('Gallery',style: myStyle(20)),
              ),
              SimpleDialogOption(
                onPressed: (){
                  pickVideo(ImageSource.camera);
                },
                child: Text('Camera',style: myStyle(20)),
              ),
              SimpleDialogOption(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',style: myStyle(20)),
              ),
            ],
          );
        }
    );
  }
  pickVideo(ImageSource src)async{
    Navigator.pop(context);
    final video = await ImagePicker().getVideo(source: src);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ConfirmPage(
        File(video.path),video.path,src
    )));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: InkWell(
        onTap: (){
          showOptionsDialog();
        },
        child: Center(
          child: Container(
            width: 180, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'Insert Video',
                style: myStyle(20,Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
