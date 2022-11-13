import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/controller/home_controller.dart';
import 'package:manyaran_system/data/models/counter.dart';
import 'package:manyaran_system/data/models/ip_camera.dart';
import 'package:manyaran_system/ui/home/widgets/empty_visitor.dart';
import 'package:manyaran_system/ui/home/widgets/header_widget.dart';
import 'package:manyaran_system/ui/home/widgets/home_menu.dart';
import 'package:manyaran_system/ui/home/widgets/info_widget.dart';
import 'package:manyaran_system/ui/home/widgets/skeleton_list_widget.dart';
import 'package:manyaran_system/ui/home/widgets/visitor_record_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:manyaran_system/ui/view_all_visitor/view_all_visitor_page.dart';
import 'package:manyaran_system/utils/helper.dart';
import 'package:page_transition/page_transition.dart';
import 'widgets/ip_cam_preview_widget.dart';
import 'widgets/last_captured_visitor_widget.dart';
import 'widgets/skeleton_container_widget.dart';
import 'widgets/skeleton_info_widget.dart';

class HomePage extends GetView<HomeController> {

  @override
  Widget build(BuildContext context) {

    return GetX<HomeController>(
      builder: (_) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: HexColor("#ECEBF0"),
            body: Container(
              color: HexColor("#ECEBF0"),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: HeaderWidget(
                          user: user,
                          firebaseDatabaseRepository: _.firebaseDatabaseRepository,
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 130,
                        child: FutureBuilder(
                          future: _.firebaseDatabaseRepository.getBellCounter(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Counter? counter = snapshot.data as Counter?;
                              return InfoWidget(counter: counter);
                            } else {
                              return SkeletonInfoWidget();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 35),
                    AnimationConfiguration.staggeredList(
                      position: 2,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: Container(
                          width: 1.sw / 1.2,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Feature",
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 2,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: HomeMenuWidget(),
                      ),
                    ),
                    SizedBox(height: 40),
                    AnimationConfiguration.staggeredList(
                      position: 3,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: Container(
                          width: 1.sw / 1.2,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "IP Camera Stream",
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 3,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: FutureBuilder(
                          future: firebaseRepository.getIPCamera(),
                          builder: (context,
                              AsyncSnapshot<List<IPCamera>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SkeletonContainerWidget(height: 90,);
                            }
                            if (snapshot.hasData) {
                              return IpCamPreviewWidget(
                                isUsingLocalConnection: false,
                                ipCamList: snapshot.data,);
                            } else {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                                child: Center(
                                  child: EmptyContentWidget(title: "You haven't added a camera yet."),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    AnimationConfiguration.staggeredList(
                      position: 4,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: Container(
                          width: 1.sw / 1.2,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Last Captured Visitor",
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 4,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: FutureBuilder(
                          future: _.firebaseDatabaseRepository.getVisitors(
                              limit: 5),
                          builder: (context,
                              AsyncSnapshot<List<int>> snapshot) {
                            if (snapshot.hasData) {
                              List<int>? visitorLog = snapshot.data;
                              if (visitorLog!.length <= 0)
                                return EmptyContentWidget(title: "No recent photos were captured.",);
                              return LastCapturedVisitorWidget(
                                visitorLog: visitorLog,
                              );
                            } else {
                              return SkeletonContainerWidget();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    AnimationConfiguration.staggeredList(
                      position: 5,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: Container(
                          width: 1.sw / 1.2,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Visitor This Month",
                                style: TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        alignment: Alignment.bottomCenter,
                                        child: ViewAllVisitorPage(),
                                      ),
                                    ),
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 5,
                      duration: Duration(seconds: 1),
                      child: SlideAnimation(
                        verticalOffset: 100,
                        child: FutureBuilder(
                          future: _.firebaseDatabaseRepository.getVisitors(
                              limit: 5),
                          builder: (context,
                              AsyncSnapshot<List<int>> snapshot) {
                            if (snapshot.hasData) {
                              List<int>? visitorLog = snapshot.data;
                              if (visitorLog!.length <= 0)
                                return EmptyContentWidget(title: "You have no visitors this month.",);
                              return VisitorsRecordsWidget(
                                visitorLog: visitorLog,
                              );
                            } else {
                              return SkeletonListWidget();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ) ;
      },
    );

  }

}



