import 'dart:ui';

import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Column(
      children: <Widget>[
        RichText(
          text: isAppTitle ? 
            TextSpan(
              style: TextStyle(
                    color: Colors.white,
                    fontFamily: isAppTitle ? "Signatra" : "",
                    fontSize: isAppTitle ? 50.0 : 22.0,
                  ),
              children: [
                TextSpan(
                  text: 'Badugufy',
                  
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(
                    fontSize: 70.0,
                    color: Colors.red,
                  ),
                ),
              ]
            ) : TextSpan(
              text: titleText,
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),  
            
            
          //   "Badugufy" : titleText,
          // style: TextStyle(
          //   color: Colors.white,
          //   fontFamily: isAppTitle ? "Signatra" : "",
          //   fontSize: isAppTitle ? 50.0 : 22.0,
          // ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
