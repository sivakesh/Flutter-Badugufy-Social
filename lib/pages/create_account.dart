import 'dart:async';

import 'package:budugufy/pages/home.dart';
import 'package:budugufy/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;
  String mobile;
  String village;
  String bio;
  bool _enabled;
  String _myVillage;
  List<DropdownMenuItem> items = [];
  String selectedValue;
  
  @override
  void initState() { 
    super.initState();
    _enabled = true;
    _myVillage = "";
    getDropdownValues();
    // SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
    // );
  }
  
  submit() {
    final form = _formKey.currentState;
    if(_myVillage.trim().length == 0) {
      SnackBar snackbar = SnackBar(
        backgroundColor: Colors.red,
          content: Text(
        "Please select your Village",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(backgroundColor: Colors.red, color: Colors.white, fontSize: 16),
      ));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
    else if (form.validate()) {
      form.save();
      setState(() {
        _enabled = false;
      });
      var newUser = [
        {
          'username': username, 
          'mobile': mobile,
          'village': _myVillage,
          'bio': bio,
        }
      ];
      
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, newUser);
      });
    }
  }

  getDropdownValues() async {
    QuerySnapshot snapshot = await villagesRef
        .getDocuments();

    snapshot.documents.forEach((childSnapshot) {
      if(childSnapshot.exists)
      {
        items.add(new DropdownMenuItem(
            child: new Text(
                childSnapshot.data['name'].toString(),
              ),
              value: childSnapshot.data['name'].toString(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Setup your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Create profile",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            enabled: _enabled,
                            validator: (val) {
                              if (val.trim().length < 5 || val.isEmpty) {
                                return "Username too short";
                              } else if (val.trim().length > 12) {
                                return "Username too long";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => username = val,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Username",
                                labelStyle: TextStyle(
                                  fontSize: 15.0,
                                ),
                                hintText: "Username must have atleat 5 char"),
                          ),
                          Divider(),
                          TextFormField(
                            enabled: _enabled,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val.trim().length < 10 || val.isEmpty) {
                                return "Mobile number too short";
                              } else if (val.trim().length > 10) {
                                return "Mobile number too long";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => mobile = val,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Mobile",
                                labelStyle: TextStyle(
                                  fontSize: 15.0,
                                ),
                                hintText: "Mobile must have 10 char"),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            
                            child: Row(
                                
                              children: <Widget>[
                                SearchableDropdown(
                                  
                                  items: items,
                                  value: selectedValue,
                                  hint: new Text(
                                    'Select your Village'
                                  ),
                                  searchHint: new Text(
                                    'Select One',
                                    style: new TextStyle(
                                        fontSize: 20
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedValue = value;
                                      _myVillage = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          TextFormField(
                            enabled: _enabled,
                            validator: (val) {
                              if (val.trim().length < 5 || val.isEmpty) {
                                return "Bio too short";
                              } else if (val.trim().length > 150) {
                                return "Bio too long";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => bio = val,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Bio",
                                labelStyle: TextStyle(
                                  fontSize: 15.0,
                                ),
                                hintText: "Can have 5 to 150 char"),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _enabled ? submit : null,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
