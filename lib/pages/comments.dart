import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showon/widget/variables.dart';
import 'package:timeago/timeago.dart' as ta;
class CommentsPage extends StatefulWidget {
  final String id;
  CommentsPage(this.id);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController commentsController = TextEditingController();
  String uId;
  @override
  void initState() {
    super.initState();
    uId = FirebaseAuth.instance.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: videosCollection.doc(widget.id).collection('comments').snapshots(),
                  builder: (BuildContext context, snapshot){
                    if(!snapshot.hasData){
                      return Text('Loading.....');
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context,int index){
                        DocumentSnapshot comment = snapshot.data.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(comment.data()['profilePic']),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${comment.data()['username']} :',
                                style: myStyle(20,Colors.black,FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${comment.data()['comment']}',
                                style: myStyle(16,Colors.black26),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                '${ta.format(comment.data()['time'].toDate())}',
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${comment.data()['likes'].length} likes',
                              ),
                            ],
                          ),
                          trailing: InkWell(
                            onTap: (){
                              likeComment(comment.data()['id']);
                            },
                            child: comment.data()['likes'].contains(uId)
                                ?Icon(Icons.favorite,size: 25,color: Colors.redAccent)
                                :Icon(Icons.favorite,size: 25,),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ListTile(
                title: TextFormField(
                  controller: commentsController,
                  decoration: InputDecoration(
                    labelText: 'Comments',
                    labelStyle: myStyle(20,Colors.greenAccent,FontWeight.bold),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                trailing: OutlineButton(
                  onPressed: (){
                    publishComments();
                  },
                  child: Text(
                    'Published',style: myStyle(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  publishComments()async{
    DocumentSnapshot userDoc = await userCollection.doc(uId).get();
    var allDocs = await videosCollection.doc(widget.id).collection('comments').get();
    int length = allDocs.docs.length;
    videosCollection.doc(widget.id).collection('comments').doc('Comment $length').set({
      'username': userDoc.data()['username'],
      'uId':uId,
      'profilePic':userDoc.data()['profilePic'],
      'likes': [],
      'time': DateTime.now(),
      'id': 'Comment $length',
      'comment':commentsController.text,
    });
    commentsController.clear();
    DocumentSnapshot doc = await videosCollection.doc(widget.id).get();
    videosCollection.doc(widget.id).update({
      'commentsCount': doc.data()['commentsCount']+1
    });
  }

  likeComment(String id)async{
    DocumentSnapshot doc =
    await videosCollection.doc(widget.id).collection('comments').doc(id).get();
    if(doc.data()['likes'].contains(uId)){
      videosCollection.doc(widget.id).collection('comments').doc(id).update({
        'likes':FieldValue.arrayRemove([uId]),
      });
    }else{
      videosCollection.doc(widget.id).collection('comments').doc(id).update({
        'likes':FieldValue.arrayUnion([uId]),
      });
    }
  }
}
