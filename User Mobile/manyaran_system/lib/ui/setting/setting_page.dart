import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/controller/setting_controller.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/utils/helper.dart';
import 'package:page_transition/page_transition.dart';

class SettingPage extends GetView<SettingController> {

  @override
  Widget build(BuildContext context) {

    final _controller = Get.find<SettingController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Account",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 23),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 17),
                      child: Hero(
                        tag: "user_picture",
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              user?.photoURL ?? ""),
                          radius: 30,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.5
                          ),
                        ),
                        SizedBox(height: 7,),
                        Text(
                          user?.email ?? "-",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Divider(height: 1,),
              InkWell(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 7,),
                  leading: Icon(
                    FontAwesomeIcons.users,
                    color: Colors.black,
                    size: 20,
                  ),
                  title: Text(
                    "User Permission",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  onTap: ()=> Get.toNamed(Routes.USER_LIST),
                ),
              ),
              Divider(height: 1,),
              InkWell(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 7,),
                  leading: Icon(
                    FontAwesomeIcons.powerOff,
                    color: Colors.black,
                    size: 20,
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {

                    _controller.logout().whenComplete(()=> Get.offNamedUntil(Routes.LOGIN, (route) => false));


                    // _.logout().whenComplete(() {
                    //   Navigator.pushAndRemoveUntil(
                    //       context,
                    //       PageTransition(
                    //           type: PageTransitionType.fade,
                    //           child: LoginPage()),
                    //           (route) => false);
                    // });


                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
