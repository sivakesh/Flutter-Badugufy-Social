import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budugufy/widgets/ui_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Following extends StatefulWidget {
  final String userId;

  Following({
    this.userId,
  });

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  var userIdList = [];
  @override
  void initState() { 
    super.initState();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.userId)
        .collection('userFollowing')
        .getDocuments();
    snapshot.documents.forEach((childSnapshot) {
      setState(() {
        userIdList.add(childSnapshot.documentID);
      });
    });
  }

  buildFollowing() {
    var userList = List<Widget>();
    userIdList.forEach((val) {
      userList.add(getUserListItem(val));
    });
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Following"),
      body: Column(
        children: <Widget>[
          Divider(
            color: Theme.of(context).accentColor,
          ),
          Expanded(
            child: Column(
              children: buildFollowing(),
            ),
          ),
        ],
      ),
    );
  }
}