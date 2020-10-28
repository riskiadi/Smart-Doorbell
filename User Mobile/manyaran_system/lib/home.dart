import 'dart:convert';

import 'package:device_apps/device_apps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:manyaran_system/models/visitors.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  AndroidNotificationDetails androidNotificationDetails;
  IOSNotificationDetails iosNotificationDetails;
  NotificationDetails notificationDetails;
  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();

  List<String> visitorList = List();

  @override
  void initState() {

    initialize();

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.subscribeToTopic('Doorbell');
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print("onMessage: $message");
          setState(() {
            visitorList.add("dapet data x");
          });
          return null;
        },
        onResume: (Map<String, dynamic> message) {
          print("onResume: $message");
          setState(() {
            visitorList.add("dapet data y");
          });
          return null;
        },
        onLaunch: (Map<String, dynamic> message) {
          print("onLaunch: $message");
          setState(() {
            visitorList.add("dapet data z");
          });
          return null;
        }
    );

    _firebaseDatabaseRepository.getVisitors().then((DataSnapshot dataSnapshot){
      // visitorList.add(jsonDecode(dataSnapshot.value.keys));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color(0xffF6F8FA),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWidget(),
                FlatButton(onPressed: () async {

                  // String appPackage = "com.macrovideo.v380";
                  // bool isInstalled = await DeviceApps.isAppInstalled(appPackage);
                  // if(isInstalled){
                  //   DeviceApps.openApp('com.macrovideo.v380');
                  // }else{
                  //   launch('https://play.google.com/store/apps/details?id=com.macrovideo.v380');
                  // }

                }, child: Text("dd")),

                FutureBuilder(
                  future: _firebaseDatabaseRepository.getVisitors(),
                  builder: (context, snapshot) {
                    return Text(snapshot.data.value.keys.toString());
                  },
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: visitorList.length,
                  itemBuilder: (context, index) {
                    return Text(visitorList[index]);
                  },
                ),

              ],
            ),
          )),
    );
  }

  void initialize() async{
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification );
    androidNotificationDetails = AndroidNotificationDetails(
        'manyaran_id',
        'Manyaran System',
        'Manyaran System Notification',
        priority: Priority.high,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('doorbell_sound'),
        playSound: true
    );
    iosNotificationDetails = IOSNotificationDetails();
    notificationDetails =  NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>().createNotificationChannel(
        AndroidNotificationChannel(
          'manyaran_id',
          'Manyaran System',
          'Manyaran System Notification',
           importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('doorbell_sound'),
            playSound: true
        )
    );

    //Show Notifiation Popup
    // await flutterLocalNotificationsPlugin.show(0, "Local Notification", "this is local notification", notificationDetails);

  }

  Future onSelectNotification(String payload) {
      if(payload!=null){
        print(payload);
      }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text(title),
          content: Text(body),
        );
      },
    );
  }


}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Smart Doorbell",
                style: TextStyle(
                    fontSize: 19,
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.notifications_active_sharp, size: 15,),
                  SizedBox(width: 5),
                  Text(
                    "You have 0 visitor today.",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
            ],
          ),
          SvgPicture.asset('assets/images/avatar.svg', width: 34,)
        ],
      ),
    );
  }
}
