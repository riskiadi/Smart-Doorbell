import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/ui/add_camera/add_camera.dart';
import 'package:manyaran_system/ui/security/security.dart';
import 'package:page_transition/page_transition.dart';

class HomeMenuWidget extends StatelessWidget {
  const HomeMenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw/1.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: ()=>Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                alignment: Alignment.bottomCenter,
                child: AddCameraPage(),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/outdoor_camera_128px.png',
                    width: 22.h,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    "Camera",
                    style: TextStyle(
                      color: HexColor("#3F3F3F"),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.w,),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/security_configuration_128px.png',
                    width: 22.h,
                  ),
                  SizedBox(height: 5,),
                  Text("Security", style: TextStyle(color: HexColor("#3F3F3F"), fontSize: 12.sp,),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
