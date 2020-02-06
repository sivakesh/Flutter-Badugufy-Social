import 'dart:async';
import 'dart:ui';

import 'package:budugufy/models/user.dart';
import 'package:budugufy/pages/activity_feed.dart';
import 'package:budugufy/pages/comments.dart';
import 'package:budugufy/pages/likes.dart';
import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/ui_widgets.dart';
import 'package:budugufy/widgets/custom_image.dart';
import 'package:budugufy/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animator/animator.dart';
import 'package:timeago/timeago.dart' as timeago;

// final DateTime timestamp = DateTime.now();

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Map likes;
  final int comments;
  final Timestamp postTimeStamp;
  // final Map imageLabels;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.comments,
    this.postTimeStamp,
    // this.imageLabels,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      postTimeStamp: doc['timestamp'],
      // imageLabels: doc['imageLabels'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;

    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  Future<int> getCommentCount(postId) async {
    // if no comments, return 0
    QuerySnapshot snapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();

    return snapshot.documents.length;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        postTimeStamp: this.postTimeStamp,
        commentCount: 0,
        
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Timestamp postTimeStamp;
  bool showHeart = false;
  bool isLiked;
  int likeCount;
  int commentCount;
  Map likes;
  String firstLikeUser;
  String secondLikeUser;
  List<User> likeUsers;
  //List<dynamic> imageLabels;

  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCommentCount(postId);
  }

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
    this.commentCount,
    this.postTimeStamp,
    // this.imageLabels,
  });

  getCommentCount(postId) async {
    // if no comments, return 0
    QuerySnapshot snapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    setState(() {
      commentCount = snapshot.documents.length;
    });
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: user.id),
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // subtitle: Text(location),
            subtitle: Text(user.village),
            trailing: isPostOwner
                ? IconButton(
                    onPressed: () => handleDeletePost(context),
                    icon: Icon(Icons.more_vert, color: Colors.teal),
                  )
                : IconButton(
                    onPressed: () => handleReportPost(context),
                    icon: Icon(Icons.more_vert, color: Colors.teal),
                  ),
          ),
        );
      },
    );
  }

  handleReportPost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Report this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    reportPost();
                  },
                  child: Text(
                    'Report',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  reportPost() async {
    reportsRef.document(postId).setData({
      "reportedBy": currentUserId,
      "timestamp": timestamp,
      "postOwnerId": ownerId,
      "postId": postId,
    });
    postsRef
        .document(ownerId)
        .collection("userPosts")
        .document(postId)
        .updateData({
      "reported": true,
    });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    // delete post itself
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // delete uploaded image for thep ost
    storageRef.child("post_$postId.jpg").delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "ownerId": ownerId,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              cachedNetworkImage(mediaUrl),
              
            ],
          ),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
      "ownerId": ownerId,
    });
    bool isNotPostOwner = ownerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef.document(ownerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "ownerId": ownerId,
        //"ownerId":
        "userId": currentUser.id,
        "username": currentUser.username,
        "userProfileImg": currentUser.photoUrl,
        "mediaUrl": mediaUrl,
      });
    }
    getCommentCount(postId);
    commentController.clear();
  }

  buildLikeUser(String userId, double size) {
    return FutureBuilder(
      future: usersRef.document(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            child: circularProgress(),
            height: size,
            width: size,
          );
        }
        User user = User.fromDocument(snapshot.data);
        return CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          backgroundColor: Colors.grey,
          radius: 10.0,
        );
      },
    );
  }

  buildDescription() {
    return ListTile(
        title: description.length > 0
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              timeago.format(postTimeStamp.toDate()),
              // postTimeStamp.toString() + " : " + description,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                description,
                // postTimeStamp.toString() + " : " + description,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ) : 
        Text(
          timeago.format(postTimeStamp.toDate()),
          // postTimeStamp.toString() + " : " + description,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.0,
            fontStyle: FontStyle.italic,
          ),
        )
        ,
        subtitle: ListTile(
          // child: ListTile(
            title: Center(
              child: location.trim().length > 0 ? Text(location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ))
                  : Text("location not avaliable",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  )),
            ),
            trailing: location.trim().length > 0 ? 
              Icon(Icons.location_on, color: Colors.lightGreen,) :
              Icon(Icons.location_on, color: Colors.grey,),
          ),
        // ),
      // ),
    );
  }

  buildPostFooter() {
    String firstLikeUser = "";
    String secondLikeUser = "";
    String thirdLikeUser = "";
    setState(() {
      firstLikeUser = "";
      secondLikeUser = "";
      thirdLikeUser = "";
    });
    int count = 0;
    if (likes.length > 0) {
      likes.forEach((key, val) {
        if (count == 0) {
          firstLikeUser = key;
          setState(() {
            firstLikeUser = key;
          });
        }
        if (count == 1) {
          secondLikeUser = key;
          setState(() {
            secondLikeUser = key;
          });
        }
        if (count == 2) {
          thirdLikeUser = key;
          setState(() {
            thirdLikeUser = key;
          });
        }
        count += 1;
      });
    }

    GestureDetector getLikesWidget() {
      return GestureDetector(
        onTap: () => showLikes(
          context,
          likes: likes,
          postId: postId,
          ownerId: ownerId,
          mediaUrl: mediaUrl,
        ),
        child: Row(
          children: <Widget>[
            firstLikeUser.length > 0
                ? buildLikeUser(firstLikeUser, 10)
                : Text(""),
            secondLikeUser.length > 0
                ? buildLikeUser(secondLikeUser, 10)
                : Text(""),
            thirdLikeUser.length > 0
                ? buildLikeUser(thirdLikeUser, 10)
                : Text(""),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: RichText(
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'Liked by '),
                    new TextSpan(
                        text: '$likeCount',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: ' members'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
              GestureDetector(
                onTap: handleLikePost,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  // color: isLiked ? Colors.red : Theme.of(context).backgroundColor,
                  color: Colors.red,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 20.0)),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 28.0,
                  color: Theme.of(context).backgroundColor,
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(
            top: 4.0,
            bottom: 4.0,
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: likeCount != 0
                    ? Row(
                        children: <Widget>[
                          getLikesWidget(),
                          // buildDescription(),
                          
                        ],
                      )
                    : Text(
                        "Yet to be liked.",
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        commentCount != 0
            ? GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: RichText(
                              text: new TextSpan(
                                // Note: Styles for TextSpans must be explicitly defined.
                                // Child text spans will inherit styles from parent
                                style: new TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: 'View all ',
                                      style: TextStyle(color: Colors.grey)),
                                  new TextSpan(
                                      text: '$commentCount',
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  new TextSpan(text: ' comments'),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              )
            : Text(
                "Be the first to comment...",
                style: TextStyle(color: Colors.grey),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        Divider(),
        buildDescription(),
        buildPostImage(),
        buildPostFooter(),
        Divider(),
        commentInput(context, commentController, addComment, currentUser),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}

showLikes(BuildContext context,
    {Map likes, String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Like(
      likes: likes,
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
