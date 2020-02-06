import 'package:budugufy/models/user.dart';
import 'package:budugufy/pages/search.dart';
import 'package:budugufy/pages/upload.dart';
import 'package:budugufy/pages/user_results.dart';
import 'package:budugufy/widgets/header.dart';
import 'package:budugufy/widgets/post.dart';
import 'package:budugufy/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budugufy/pages/home.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        // .where('reported', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Colors.white,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Image(
                  image: AssetImage('assets/images/pablo-face-recognition.png'),
                )),
                Text(
                  "Welcome to Badugufy",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "When you follow members, you get to see their posts here.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Search()));
                  },
                  child: Container(
                    // width: 250.0,
                    height: 50.0,
                    child: Text(
                      "Tap here to search for members",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      border: Border.all(
                        color: Theme.of(context).accentColor,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Upload(currentUser: widget.currentUser)));
                  },
                  child: Container(
                    // width: 250.0,
                    height: 50.0,
                    child: Text(
                      "Tap here to create a post",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      border: Border.all(
                        color: Theme.of(context).accentColor,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
              ]),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
          onRefresh: () => getTimeline(), child: buildTimeline()));
  }
}
