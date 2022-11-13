import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manyaran_system/controller/login_controller.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/utils/helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends GetView<LoginController> {

  final _controller = Get.find<LoginController>();

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
                child: Column(
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
                ),
              ),
              Positioned(
                bottom: 150,
                left: 0.5,
                right: 0.5,
                child: Column(
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
                            style: TextStyle(
                                color: Colors.black.withAlpha(150)),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _controller.signInWithGoogle();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 20,
                  left: 0.5,
                  right: 0.5,
                  child: Center(child: Text("Version ${_controller.appVersion}", style: TextStyle(fontSize: 12.sp),),),),
            ],
          ),
        ),
      ),
    );
  }

}

