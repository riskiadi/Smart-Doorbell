import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:manyaran_system/ui/home/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseDatabaseRepository _firebaseDatabaseRepository =
      FirebaseDatabaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Stack(
            children: [
              Positioned(
                top: 80,
                left: 0.5,
                right: 0.5,
                child: buildLogo(),
              ),
              Positioned(
                bottom: 150,
                left: 0.5,
                right: 0.5,
                child: buildLoginButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return Column(
      children: [
        OutlinedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/google.png',
                width: 20,
                height: 20,
              ),
              SizedBox(width: 10),
              Text(
                "Sign in with Google",
                style: TextStyle(color: Colors.black.withAlpha(150)),
              ),
            ],
          ),
          onPressed: () {
            _signInWithGoogle(context);
          },
        ),
      ],
    );
  }

  Widget buildLogo() {
    return Column(
      children: [
        Image.asset(
          "assets/images/icon.png",
          width: 100,
          height: 100,
        ),
        SizedBox(height: 10,),
        Text(
          "Manyaran System",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "Home automation and security\nBy Alkalynx",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  _signInWithGoogle(BuildContext context) async {
    await Firebase.initializeApp();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignInAccount? googleAccount =
        await GoogleSignIn(scopes: ["email"]).signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleAccount?.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    BotToast.showLoading();
    await firebaseAuth.signInWithCredential(googleAuthCredential);
    if (await _firebaseDatabaseRepository
            .isUserRegistered(firebaseAuth.currentUser?.uid ?? "") ==
        false) {
      await _firebaseDatabaseRepository.registerUser(firebaseAuth.currentUser);
      await _checkIsAllowed(firebaseAuth, context);
    } else {
      await _checkIsAllowed(firebaseAuth, context);
    }
    BotToast.closeAllLoading();
  }

  Future _checkIsAllowed(
      FirebaseAuth firebaseAuth, BuildContext context) async {
    if (await _firebaseDatabaseRepository
        .isUserAllowed(firebaseAuth.currentUser?.uid ?? "")) {
      if (firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                user: firebaseAuth.currentUser,
              ),
            ));
      }
    } else {
      showAlertDialog<OkCancelResult>(
          context: context,
          title: "Login Failed",
          message: "Account not allowed",
          style: AdaptiveStyle.cupertino,
          actions: [
            AlertDialogAction(label: "OK", key: OkCancelResult.cancel)
          ]);
      firebaseAuth.signOut();
      GoogleSignIn().disconnect();
    }
  }
}
