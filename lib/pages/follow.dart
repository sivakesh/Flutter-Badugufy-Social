import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budugufy/widgets/ui_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Follow extends StatefulWidget {
  final String userId;

  Follow({
    this.userId,
  });

  @override
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  var userIdList = [];
  @override
  void initState() { 
    super.initState();
    getFollowers();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.userId)
        .collection('userFollowers')
        .getDocuments();
    snapshot.documents.forEach((childSnapshot) {
      setState(() {
        userIdList.add(childSnapshot.documentID);
      });
    });
  }

  buildFollow() {
    var userList = List<Widget>();
    userIdList.forEach((val) {
      userList.add(getUserListItem(val));
    });
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Follows"),
      body: Column(
        children: <Widget>[
          Divider(
            color: Theme.of(context).accentColor,
          ),
          Expanded(
            child: Column(
              children: buildFollow(),
            ),
          ),
        ],
      ),
    );
  }
}