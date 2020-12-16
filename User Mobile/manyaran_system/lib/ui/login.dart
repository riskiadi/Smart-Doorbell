import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:manyaran_system/ui/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0XFFFFFFFF),
              Color(0XFFdedede),
              Color(0XFFdedede),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          )
        ),
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
        OutlineButton(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/google.png',
                width: 20,
                height: 20,
              ),
              SizedBox(width: 10),
              Text("Sign in with Google"),
            ],
          ),
          onPressed: (){
            _signInWithGoogle(context);
          },
        ),
      ],
    );
  }
  Widget buildLogo(){
    return Column(
      children: [
        Image.asset("assets/images/icon.png", width: 100, height: 100,),
        SizedBox(height: 5),
        RichText(
          text: TextSpan(
              text: "Manyaran",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w300
              ),
              children: [
                TextSpan(
                  text: " System",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ]),
        ),
        SizedBox(height: 10,),
        Text("Home automation & security", style: TextStyle(fontSize: 11,color: Colors.black.withOpacity(0.4),),),
        Text("by Alkalynx", style: TextStyle(fontSize: 11,color: Colors.black.withOpacity(0.4),),),
      ],
    );
  }

  _signInWithGoogle(BuildContext context) async{
    await Firebase.initializeApp();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignInAccount googleAccount = await GoogleSignIn(scopes: ["email"]).signIn();
    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    final GoogleAuthCredential googleAuthCredential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    await firebaseAuth.signInWithCredential(googleAuthCredential);
    EasyLoading.show(status: 'loading...', dismissOnTap: true);
    if(await _firebaseDatabaseRepository.isUserRegistered(firebaseAuth.currentUser.uid) == false){
      await _firebaseDatabaseRepository.registerUser(firebaseAuth.currentUser);
      await _checkIsAllowed(firebaseAuth, context);
      EasyLoading.dismiss();
    }else{
      await _checkIsAllowed(firebaseAuth, context);
      EasyLoading.dismiss();
    }
  }

  Future _checkIsAllowed(FirebaseAuth firebaseAuth, BuildContext context) async {
    if(await _firebaseDatabaseRepository.isUserAllowed(firebaseAuth.currentUser.uid)){
      if(firebaseAuth.currentUser != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: firebaseAuth.currentUser,),));
      }
    }else{
      showAlertDialog<OkCancelResult>(
        context: context,
        title: "Login Failed",
        message: "Account not allowed",
        style: AdaptiveStyle.cupertino,
        actions: [
          AlertDialogAction(label: "OK")
        ]
      );
      firebaseAuth.signOut();
      GoogleSignIn().disconnect();
    }
  }

}
