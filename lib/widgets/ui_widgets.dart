import 'package:budugufy/models/user.dart';
import 'package:budugufy/pages/home.dart';
import 'package:budugufy/pages/post_screen.dart';
import 'package:budugufy/pages/profile.dart';
import 'package:budugufy/widgets/comment.dart';
import 'package:budugufy/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Column commentInput(context, commentController, addComment, user) {
  return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
              // leading: CircleAvatar(
              //   backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              //   backgroundColor: Colors.grey,
              //   radius: 10,
              // ),
              title: TextFormField(
              controller: commentController,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: "Add a comment...",
                border: InputBorder.none,
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text(
                "Post",
                style: TextStyle(color: Colors.grey),
              ),
              
            ),
          ),
          Divider(
            thickness: 1.0,
            color: Theme.of(context).backgroundColor,
          ),
        ],
      );
}

GestureDetector getUserAvathar (context, tapFunction, user, [radius = 20.0]) {
  return(
    GestureDetector(
      onTap: () => tapFunction,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          radius: radius,
        ),
        title: Text(
          user.displayName,
          style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
            text: new TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: new TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
            children: <TextSpan>[
              new TextSpan(text: user.username, style: TextStyle(color: Colors.grey)),
              new TextSpan(text: user.bio, style: new TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )
        
        // Text(
        //   user.username,
        //   style: TextStyle(color: Colors.black),
        // ),
      ),
    )
  );
}

buildCommentWidget(postId) {
    return Container(
      child: StreamBuilder(
          stream: commentsRef
              .document(postId)
              .collection('comments')
              .orderBy("timestamp", descending: false)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<Comment> comments = [];
            snapshot.data.documents.forEach((doc) {
              comments.add(Comment.fromDocument(doc));
            });
            return ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: comments,
            );
          }),
    );
  }

  profileUserTap(postId, postOwnerId, postMediaUrl) {
    return FutureBuilder(
      future: usersRef.document(postOwnerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Container(
          decoration: new BoxDecoration (
                color: Colors.grey.shade200,
            ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => {
                Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile(profileId: currentUser?.id)))},
              child: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(user.village),
                Text(user.bio),
              ],
            ),
            trailing: SizedBox(
              height: 100.0,
              width: 100.0,
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreen(
                      postId: postId,
                      userId: postOwnerId,
                    ),
                  ),
                ),
                },
                child: Container(
                decoration: BoxDecoration(
                  
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(postMediaUrl),
                    
                  ),
                ),
            ),
              ),
            ),
          ),
        );
      },
    );
  }

  getUserListItem(userId) {
    // print(userId);
    return FutureBuilder(
      future: usersRef.document(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Container(
          decoration: new BoxDecoration (
                color: Colors.white,
            ),
          child: GestureDetector(
            onTap: () => {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Profile(profileId: userId)))},
            child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(user.village),
                Text(user.bio),
              ],
            ),
            trailing: SizedBox(
              height: 100.0,
              width: 100.0,

            ),
            ),
          ) 
  
        );
      },
    );
  }

  //Profile

  