import 'dart:async';

import 'package:budugufy/models/user.dart';
import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/progress.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _mobileValid = true;
  bool _villageValid = true;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    getUser();
    _enabled = true;
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    villageController.text = user.village;
    mobileController.text = user.mobile;
    setState(() {
      isLoading = false;
    });
  }

  buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey,),
          ),
        ),
        TextField(
          enabled: _enabled,
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        ),
      ],
    );
  }
  buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey,),
          ),
        ),
        TextField(
          enabled: _enabled,
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio is too long",
          ),
        ),
      ],
    );
  }
  buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Mobile",
            style: TextStyle(color: Colors.grey,),
          ),
        ),
        TextField(
          enabled: _enabled,
          controller: mobileController,
          decoration: InputDecoration(
            hintText: "Update mobile",
            errorText: _mobileValid ? null : "Mobile is too long",
          ),
        ),
      ],
    );
  }
  buildVillageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Hatti/Village",
            style: TextStyle(color: Colors.grey,),
          ),
        ),
        TextField(
          enabled: _enabled,
          controller: villageController,
          decoration: InputDecoration(
            hintText: "Update mobile",
            errorText: _villageValid ? null : "Village is too long",
          ),
        ),
      ],
    );
  }

  setSearchParam(String field) {
    List<String> fieldSearchList = List();
    String temp = "";
    for (int i = 0; i < field.length; i++) {
      temp = temp + field[i];
      fieldSearchList.add(temp);
    }
    return fieldSearchList;
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
      displayNameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true;
      bioController.text.trim().length > 150 ? _bioValid = false : _bioValid = true;
      mobileController.text.trim().length != 10 ||
      mobileController.text.isEmpty ? _mobileValid = false : _mobileValid = true;
      villageController.text.trim().length < 5 || villageController.text.trim().length > 50 ?
      _villageValid = false : _villageValid = true;

    });

    if(_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
         "displayName": displayNameController.text,
         "bio": bioController.text,
         "village": villageController.text,
         "mobile": mobileController.text,
         "searchDisplayName": setSearchParam(displayNameController.text),
         "searchVillage": setSearchParam(villageController.text),
      });
      SnackBar snackbar = SnackBar(content: Text("Profile Updated"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context);
      });
    }
  }

  logout() async { 
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading ? circularProgress() :
          ListView(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          buildDisplayNameField(),
                          buildMobileField(),
                          buildVillageField(),
                          buildBioField(),
                        ],
                      ),
                    ),
                    RaisedButton(
                      color: Theme.of(context).accentColor,
                      onPressed: updateProfileData,
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: FlatButton.icon(
                        onPressed: logout,
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
