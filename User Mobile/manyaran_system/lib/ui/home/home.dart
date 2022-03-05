import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/models/ip_camera.dart';
import 'package:manyaran_system/ui/home/widgets/header_widget.dart';
import 'package:manyaran_system/ui/home/widgets/home_menu.dart';
import 'package:manyaran_system/ui/home/widgets/info_widget.dart';
import 'package:manyaran_system/ui/home/widgets/skeleton_list_widget.dart';
import 'package:manyaran_system/ui/home/widgets/visitor_record_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:manyaran_system/models/counter.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:manyaran_system/ui/view_all_visitor/view_all_visitor.dart';
import 'package:page_transition/page_transition.dart';
import 'widgets/ip_cam_preview_widget.dart';
import 'widgets/last_captured_visitor_widget.dart';
import 'widgets/skeleton_container_widget.dart';
import 'widgets/skeleton_info_widget.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();
  late User? _user;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late StreamSubscription visitorSubscription;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    _notificationChannelInit();
    _subscribeTopic();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_messageHandler);

    _user = widget.user;

    visitorSubscription = FirebaseDatabase.instance
        .reference()
        .child('visitors')
        .onChildChanged
        .listen((event) {
      print("DIUBAH");
      setState(() {});
    });
    visitorSubscription = FirebaseDatabase.instance
        .reference()
        .child('visitors')
        .onChildAdded
        .listen((event) {
      print("DITAMBAHKAN");
      setState(() {});
    });
    visitorSubscription = FirebaseDatabase.instance
        .reference()
        .child('visitors')
        .onChildRemoved
        .listen((event) {
      print("DIHAPUS");
      setState(() {});
    });


    firebaseRepository.getLastCamSnapshot();
    super.initState();
  }

  @override
  void dispose() async {
    visitorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
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
                        user: _user,
                        firebaseDatabaseRepository: _firebaseDatabaseRepository,
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
                        future: _firebaseDatabaseRepository.getBellCounter(),
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
                        builder: (context, AsyncSnapshot<List<IPCamera>> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return SkeletonContainerWidget(height: 90,);
                          }
                          if(snapshot.hasData){
                            return IpCamPreviewWidget(isUsingLocalConnection: false, ipCamList: snapshot.data,);
                          }else{
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text("You haven't added a camera yet."),
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
                        future: _firebaseDatabaseRepository.getVisitors(limit: 5),
                        builder: (context, AsyncSnapshot<List<int>> snapshot) {
                          if (snapshot.hasData) {
                            List<int>? visitorLog = snapshot.data;
                            if (visitorLog!.length <= 0) return Container();
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
                              onTap: () => Navigator.push(
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
                        future: _firebaseDatabaseRepository.getVisitors(limit: 5),
                        builder: (context, AsyncSnapshot<List<int>> snapshot) {
                          if (snapshot.hasData) {
                            List<int>? visitorLog = snapshot.data;
                            if (visitorLog!.length <= 0) return emptyVisitorState();
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
    );
  }


  Widget emptyVisitorState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50.h),
      child: Text(
        "You have no visitors this month.",
        style: TextStyle(
          color: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }


  _notificationChannelInit() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'manyaran_id',
        'Manyaran System',
        'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
        sound: RawResourceAndroidNotificationSound(
          'notification',
        ),
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _messageHandler(initialMessage);
      }
    }
  }

  _subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('Doorbell');
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background/terminated message");
    print(message.data);
  }

  _messageHandler(RemoteMessage message) async{
    Map<String, dynamic> messageData = message.data;
    showImageViewer(context, CachedNetworkImageProvider(messageData["image_url"]));
  }

}


