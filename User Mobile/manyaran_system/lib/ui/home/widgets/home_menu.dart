import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/ui/add_camera/add_camera_page.dart';
import 'package:manyaran_system/ui/security/security_page.dart';
import 'package:page_transition/page_transition.dart';

class HomeMenuWidget extends StatelessWidget {
  const HomeMenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw/1.2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: ()=> Get.toNamed(Routes.ADD_CAMERA),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0,6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16,),
                    child: Image.asset(
                      'assets/images/outdoor_camera_128px.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Text(
                "Manage\nCamera",
                style: TextStyle(
                  color: HexColor("#3F3F3F"),
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(width: 15.w,),
          Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: ()=>Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    alignment: Alignment.bottomCenter,
                    child: SecurityPage(),
                  ),
                ),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0,6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16,),
                    child: Image.asset(
                      'assets/images/system_task_128px.png',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Text("System\nMonitoring", style: TextStyle(color: HexColor("#3F3F3F"), fontSize: 12.sp,), textAlign: TextAlign.center,),
            ],
          ),
          SizedBox(width: 15.w,),
          Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: ()=>Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    alignment: Alignment.bottomCenter,
                    child: SecurityPage(),
                  ),
                ),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0,6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16,),
                    child: Image.asset(
                      'assets/images/video_camera_128px.png',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Text("Youtube\nLive"
                  "", style: TextStyle(color: HexColor("#3F3F3F"), fontSize: 12.sp,), textAlign: TextAlign.center,),
            ],
          ),
        ],
      ),
    );
  }
}
