import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manyaran_system/ui/home.dart';
import 'package:manyaran_system/ui/login.dart';

Future<void> main() async {
  await GetStorage.init();
  await Firebase.initializeApp();
  User user = FirebaseAuth.instance.currentUser;
  if(user != null){
    runApp(MyApp(page: HomePage(user: user,),));
  }else{
    runApp(MyApp(page: LoginPage(),));
  }
}

class MyApp extends StatelessWidget {

  final Widget page;
  const MyApp({@required this.page});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manyaran System',
      theme: ThemeData(
        primarySwatch: Colors.pink
      ),
      debugShowCheckedModeBanner: false,
      home: page,
      builder: EasyLoading.init()
    );
  }



}
