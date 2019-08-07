import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoading = false;

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("HomePage"),
          centerTitle: true,
        ),
        body: Center(
          child: FlatButton(
              onPressed: handleSignOut,
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16.0),
              ),
              color: Color(0xffdd4b39),
              textColor: Colors.white,
              padding: const EdgeInsets.all(20.0),
        ),
      ),
      )
    );
  }
}
