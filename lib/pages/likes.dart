import 'package:budugufy/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budugufy/widgets/ui_widgets.dart';

class Like extends StatefulWidget {
  final Map likes;
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Like({
    this.likes,
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  _LikeState createState() => _LikeState(
    likes: this.likes,
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class _LikeState extends State<Like> {
  final Map likes;
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _LikeState({
    this.likes,
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildLikes() {
    var userList = List<Widget>();
    likes.forEach((key, val) {
      if(val) {
        userList.add(getUserListItem(key));
      }
    });
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Likes"),
      body: Column(
        children: <Widget>[
          profileUserTap(postId, postOwnerId, postMediaUrl),
          Divider(
            color: Theme.of(context).accentColor,
          ),
          Expanded(
            child: Column(
              children: buildLikes(),
            ),
          ),
          
        ],
      ),
    );
  }
}