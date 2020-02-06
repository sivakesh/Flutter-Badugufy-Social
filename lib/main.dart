import 'package:budugufy/pages/home.dart';
import 'package:flutter/material.dart';

void main() async {
      runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badugufy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.deepPurple,
        // accentColor: Colors.deepOrange,
        primarySwatch: Colors.teal,
        accentColor: Colors.deepPurple,
      ),
      // home: BoardApp(),
      home: Home(),
    );
  }
}


