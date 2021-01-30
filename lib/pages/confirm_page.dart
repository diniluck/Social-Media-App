

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:showon/widget/variables.dart';
import 'package:video_player/video_player.dart';


class ConfirmPage extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  final ImageSource imageSource;

  ConfirmPage(this.videoFile,this.videoPath,this.imageSource);
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  TextEditingController musicController = TextEditingController();
  TextEditingController captionsController = TextEditingController();
  VideoPlayerController controller;
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: isUploading == true ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Uploading.....',style: myStyle(20)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ):SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.5,
              child: VideoPlayer(controller),

            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    margin: EdgeInsets.only(left: 10,right: 10),
                    child: TextField(
                      controller: musicController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Video Name',
                        labelStyle: myStyle(15),
                        prefixIcon: Icon(Icons.music_note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    margin: EdgeInsets.only(right: 50),
                    child: TextField(
                      controller: captionsController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Captions',
                        labelStyle: myStyle(15),
                        prefixIcon: Icon(Icons.closed_caption),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  onPressed: (){
                    uploadVideo();
                  },
                  color: Colors.black,
                  child: Text('Upload Video',style: myStyle(15,Colors.white)),
                ),
                RaisedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  color: Colors.redAccent,
                  child: Text('Another Video',style: myStyle(15,Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  uploadVideo()async{
    setState(() {
      isUploading = true;
    });
    try{
      var firebaseUserId = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot userDoc = await userCollection.doc(firebaseUserId).get();
      var allDocs = await videosCollection.get();
      int length = allDocs.docs.length;
      String video = await uploadVideoToStorage('Video $length');
      String previewImage = await uploadImageToStorage('Video $length');

      videosCollection.doc('Video $length').set({
        'username': userDoc.data()['username'],
        'uId': firebaseUserId,
        'profilePic': userDoc.data()['profilePic'],
        'id': 'Video $length',
        'likes':[],
        'commentsCount':0,
        'shareCount':0,
        'songName':musicController.text,
        'caption': captionsController.text,
        'videoUrl': video,
        'previewImage': previewImage,

      });
      Navigator.pop(context);
    }catch(e){
      print(e);
    }
  }

  uploadVideoToStorage(String id)async{
    StorageUploadTask storageUploadTask = videosFolder.child(id).putFile(await compressVideo());
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  uploadImageToStorage(String id)async{
    StorageUploadTask storageUploadTask = imagesFolder.child(id).putFile(await getPreviewImage());
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  compressVideo()async{
    if(widget.imageSource == ImageSource.gallery){
      return widget.videoFile;
    }else{
      final compressVideo = await flutterVideoCompress.compressVideo(
          widget.videoPath, quality: VideoQuality.MediumQuality
      );
      return File(compressVideo.path);
    }
  }

  getPreviewImage()async{
    final previewImage = await flutterVideoCompress.getThumbnailWithFile(widget.videoPath);
    return previewImage;
  }
}
