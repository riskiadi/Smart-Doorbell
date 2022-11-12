import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manyaran_system/routes/app_pages.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/utils/helper.dart';

Future<void> main() async {
  await GetStorage.init();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
        builder: (context, child) => GetMaterialApp(
          title: 'Manyaran System',
          theme: ThemeData(
              primarySwatch: Colors.amber,
              fontFamily: 'Poppins'
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: user != null ? Routes.HOME : Routes.LOGIN,
          getPages: AppPages.pages,
          defaultTransition: Transition.fadeIn,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }

}