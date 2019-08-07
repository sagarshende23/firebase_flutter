import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_firebase_login/homepage.dart';
//Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//Shared prefrences & Flutter Toast
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Button
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignDemo(),
    );
  }
}

class SignDemo extends StatefulWidget {
  @override
  _SignDemoState createState() => _SignDemoState();
}

class _SignDemoState extends State<SignDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await _googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;
    print("signed in " + firebaseUser.displayName);

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'id': firebaseUser.uid,
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
    return firebaseUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Center(
          child: GoogleSignInButton(
            onPressed: _handleSignIn,
          ),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    ));
  }
}
