import 'package:budugufy/models/user.dart';
import 'package:budugufy/pages/home.dart';
import 'package:budugufy/pages/user_results.dart';
import 'package:budugufy/widgets/post.dart';
import 'package:budugufy/widgets/post_tile.dart';
import 'package:budugufy/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() { 
    super.initState();
    getProfilePosts();
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("searchDisplayName", arrayContains: query.toLowerCase())
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      searchResultsFuture = null;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await mediaRef
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildMediaPosts() {
      if (isLoading) {
        return circularProgress();
      } 
      else {
        List<GridTile> gridTiles = [];
        posts.forEach((post) {
          gridTiles.add(GridTile(
            child: PostTile(post)));
        });
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridTiles,
        );
      }
    }            


  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        onChanged: handleSearch,
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    if (isLoading) {
      return circularProgress();
    }
    else {
      return Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              buildMediaPosts(),
            ],
          ),
      );
    }
    
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}


