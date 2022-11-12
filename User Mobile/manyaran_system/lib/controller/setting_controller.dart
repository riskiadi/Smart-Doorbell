import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingController extends GetxController {

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
  }

}