import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:showon/pages/comments.dart';
import 'package:showon/widget/circle_animation_page.dart';
import 'package:showon/widget/variables.dart';
import 'package:showon/widget/videoplayeritem.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String uId;
  Stream myStream;
  buildProfile(String url){
    return Container(
      width: 60,height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              height: 50,width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,left: 20,
            child: Container(
              width: 20,height: 20,
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(Icons.add,color: Colors.white,size: 15),
            ),
          ),
        ],
      ),
    );
  }
  buildAlbum(String url){
    return Container(
      width: 60,height: 60,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 40,width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[800],Colors.grey[700]
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  likeVideo(String id)async{
    String uId = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot doc = await videosCollection.doc(id).get();
    if(doc.data()['likes'].contains(uId)){
      videosCollection.doc(id).update({
        'likes': FieldValue.arrayRemove([uId]),
      });
    }else{
      videosCollection.doc(id).update({
        'likes': FieldValue.arrayUnion([uId]),
      });
    }
  }
  shareVideo(String video, String id)async{
    var request = await HttpClient().getUrl(Uri.parse(video));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('SocialApp', 'Video.mp4', bytes, 'video/mp4');
    DocumentSnapshot doc = await videosCollection.doc(id).get();
    videosCollection.doc(id).update({
      'shareCount':doc.data()['shareCount']+1
    });
  }
  @override
  void initState() {
    super.initState();
    uId = FirebaseAuth.instance.currentUser.uid;
    myStream = videosCollection.snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: myStream,
          builder: (context, snapshot) {
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return PageView.builder(
                itemCount: snapshot.data.docs.length,
                controller: PageController(initialPage: 0,viewportFraction: 1),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot videos = snapshot.data.docs[index];
                  return Stack(
                    children: [
                      VideoPlayerItem(videos.data()['videoUrl']),
                      Column(
                        children: [
                          // top Section
                          Container(
                            height: 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Following',style:myStyle(17,Colors.white,FontWeight.bold)),
                                SizedBox(width: 15),
                                Text('For You',style:myStyle(17,Colors.white,FontWeight.bold)),
                              ],
                            ),
                          ),
                          //Middle Section
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 70,
                                    padding: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(videos.data()['username'],style:myStyle(15,Colors.white,FontWeight.bold)),
                                        Text(videos.data()['caption'],style:myStyle(15,Colors.white,FontWeight.bold)),

                                        Row(
                                          children: [
                                            Icon(Icons.music_note,size: 15,color: Colors.white),
                                            Text(videos.data()['songName'],style:myStyle(15,Colors.white,FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Right Section
                                Container(
                                  width: 100,
                                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildProfile(videos.data()['profilePic']),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              likeVideo(videos.data()['id']);
                                            },
                                            child: Icon(
                                              Icons.favorite,size: 40,
                                              color:videos.data()['likes']
                                                  .contains(uId) ?Colors.redAccent:Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(videos.data()['likes'].length.toString(),style: myStyle(20,Colors.white)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (context)=>CommentsPage(videos.data()['id'])
                                              ));
                                            },
                                            child: Icon(
                                                Icons.comment,size: 40,color: Colors.white
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(videos.data()['commentsCount'].toString(),style: myStyle(20,Colors.white)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              shareVideo(videos.data()['videoUrl'],videos.data()['id']);
                                            },
                                            child: Icon(
                                                Icons.replay,size: 40,color: Colors.white
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(videos.data()['shareCount'].toString(),style: myStyle(20,Colors.white)),
                                        ],
                                      ),
                                      CircleAnimationPage(
                                        buildAlbum(videos.data()['profilePic']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
            );
          }
      ),
    );
  }
}
