import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manyaran_system/data/repository/firebase_database.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/utils/helper.dart';

class LoginController extends GetxController {

  final _firebaseDatabaseRepository = FirebaseDatabaseRepository().obs;
  final _appVersion = RxnString();

  get firebaseDatabaseRepository => this._firebaseDatabaseRepository.value;

  set firebaseDatabaseRepository(value) {
    this._firebaseDatabaseRepository.value = value;
  }

  String? get appVersion => _appVersion.value;

  set appVersion(value) {
    _appVersion.value = value;
  }

  signInWithGoogle() async {
    await Firebase.initializeApp();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignInAccount? googleAccount = await GoogleSignIn(scopes: ["email"]).signIn();
    final GoogleSignInAuthentication? googleAuth = await googleAccount?.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    BotToast.showLoading();
    await firebaseAuth.signInWithCredential(googleAuthCredential);
    if (await firebaseDatabaseRepository.isUserRegistered(firebaseAuth.currentUser?.uid ?? "") == false) {
      await firebaseDatabaseRepository.registerUser(firebaseAuth.currentUser);
      await _checkIsAllowed(firebaseAuth);
    } else {
      await _checkIsAllowed(firebaseAuth);
    }
    BotToast.closeAllLoading();
  }

  Future<void> _checkIsAllowed(FirebaseAuth firebaseAuth) async {
    if (await firebaseDatabaseRepository.isUserAllowed(firebaseAuth.currentUser?.uid ?? "")) {
      if (firebaseAuth.currentUser != null) {
        user = FirebaseAuth.instance.currentUser;
        Get.offAllNamed(Routes.HOME);
      }
    } else {
      if(Get.context!=null){
        showOkDialog(Get.context!, title: "Login Failed", message: "Account not allowed");
      }
      firebaseAuth.signOut();
      GoogleSignIn().disconnect();
    }
  }

  @override
  void onInit() {
    packageInfo().then((value) => appVersion = value.version);
    super.onInit();
  }

}