import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manyaran_system/ui/home/home.dart';
import 'package:manyaran_system/ui/login/login.dart';


Future<void> main() async {
  await GetStorage.init();
  await Firebase.initializeApp();
  User? user = FirebaseAuth.instance.currentUser;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if(user != null){
    runApp(MyApp(page: HomePage(user: user,),));
  }else{
    runApp(MyApp(page: LoginPage(),));
  }

}

class MyApp extends StatelessWidget {
  final Widget page;
  const MyApp({required this.page});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
        builder: () => GetMaterialApp(
          title: 'Manyaran System',
          theme: ThemeData(
              primarySwatch: Colors.amber,
              fontFamily: 'Poppins'
          ),
          debugShowCheckedModeBanner: false,
          home: page,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}