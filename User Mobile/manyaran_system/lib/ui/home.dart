import 'dart:async';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPressed = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  AndroidNotificationDetails androidNotificationDetails;
  IOSNotificationDetails iosNotificationDetails;
  NotificationDetails notificationDetails;
  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();

  StreamSubscription visitorSubscription;

  @override
  void initState() {

    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildChanged.listen((event) {
      print("DIUBAH");
      setState(() {});
    });

    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildAdded.listen((event) {
      print("DITAMBAHKAN");
      setState(() {});
    });

    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildRemoved.listen((event) {
      print("DIHAPUS");
      setState(() {});
    });

    initialize();

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.subscribeToTopic('Doorbell');
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print("onMessage: $message");
      return null;
    }, onResume: (Map<String, dynamic> message) {
      print("onResume: $message");
      return null;
    }, onLaunch: (Map<String, dynamic> message) {
      print("onLaunch: $message");
      return null;
    });
    super.initState();
  }

  @override
  void dispose() {
    visitorSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xffF6F8FA),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: floatingButtonCustom(context),
          body: SingleChildScrollView(
            child: Column(
              children: [
                HeaderWidget(),
                Container(
                  margin: const EdgeInsets.only(right: 16, left: 16, bottom: 20),
                  width: double.infinity,
                  height: 0.7,
                  decoration: BoxDecoration(
                      color: const Color(0xFFdfe3e5),
                  ),
                ),
                FlatButton(onPressed: (){_firebaseDatabaseRepository.addVisitor();}, child: Text("Dummy Visitor")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_people_sharp, color: Colors.black.withOpacity(0.7),),
                    SizedBox(width: 10),
                    Text("Home Visitors", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.black.withOpacity(0.7)),),
                  ],
                ),
                SizedBox(height: 10),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getVisitors(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData){

                      DateTime dt = DateTime.now();

                      DataSnapshot dataSnapshot = snapshot.data;
                      if(dataSnapshot.value==null) return emptyVisitorState();
                      Map<dynamic, dynamic> visitors = dataSnapshot.value;
                      List<int> visitorLog = List();
                      visitors.forEach((key, value) {
                        int unixTime = visitors[key]["date"];
                        visitorLog.add(unixTime);

                        //COMPARE VISITOR TODAY
                        if(
                        dt.day == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).day &&
                            dt.month == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).month &&
                            dt.year == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).year
                        ){
                          print("VISITOR EQUAL NOW = 1");
                        }else{
                          print("VISITOR EQUAL NOW = 0");
                        }


                      });
                      visitorLog.sort((a, b){
                        return b.compareTo(a);
                      });
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: visitorLog.length,
                        itemBuilder: (context, index) {
                          return  Column(
                            children: [
                              visitorListWidget(unixTime: visitorLog[index])
                            ],
                          );
                        },
                      );
                    }else{
                      return Text("LOADING...");
                    }
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          )),
    );
  }

  Widget floatingButtonCustom(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Press hold to ring a bell"),));
      },
      onLongPress: (){
        vibrateDevice();
        _firebaseDatabaseRepository.setAlarmOn();
        setState(() {
          _isPressed = true;
        });
      },
      onLongPressUp: () {
        vibrateDevice();
        _firebaseDatabaseRepository.setAlarmOff();
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
              begin: Alignment(-1.0, -2.0),
              end: Alignment(1.0, 2.0),
              colors: <Color>[
                Color(0xff2296f3),
                Color(0xff06b3fa),
                Color(0xff1c9df5)
              ]),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xff2296f3).withOpacity(0.7), blurRadius: 10
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: _isPressed ? Colors.black.withOpacity(0.5) : Colors.white,
            ),
            SizedBox(width: 14),
            Text(
              "Press and Hold",
              style: TextStyle(
                  color: _isPressed ? Colors.black.withOpacity(0.5) : Colors.white,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w300
              ),
            )
          ],
        ),
      ),
    );
  }

  Column emptyVisitorState() {
    return Column(
      children: [
        Icon(
          Icons.sticky_note_2_outlined,
          size: 30,
          color: Colors.black.withOpacity(0.5),
        ),
        SizedBox(height: 10),
        Text("Visitor log is empty.", style: TextStyle(color: Colors.black.withOpacity(0.5)),)
      ],
    );
  }

  void initialize() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    androidNotificationDetails = AndroidNotificationDetails(
        'manyaran_id', 'Manyaran System', 'Manyaran System Notification',
        priority: Priority.high,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('doorbell_sound'),
        playSound: true);
    iosNotificationDetails = IOSNotificationDetails();
    notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        .createNotificationChannel(AndroidNotificationChannel(
            'manyaran_id', 'Manyaran System', 'Manyaran System Notification',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('doorbell_sound'),
            playSound: true));

    //Show Notifiation Popup
    // await flutterLocalNotificationsPlugin.show(0, "Local Notification", "this is local notification", notificationDetails);
  }

  Future onSelectNotification(String payload) {
    if (payload != null) {
      print(payload);
    }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
        );
      },
    );
  }

}

void vibrateDevice() async {
  if(await Vibration.hasVibrator()){
    Vibration.vibrate();
    print('Vibrate');
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Smart Doorbell",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active_sharp,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "You have 0 visitor today.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ],
          ),
          Container(
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              color: Color(0xff04aef5),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/cctv.svg',
                    width: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Open CCTV",
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
              onPressed: () async {
                if(await DeviceApps.isAppInstalled('com.macrovideo.v380')!=true){
                  await launch("https://play.google.com/store/apps/details?id=com.macrovideo.v380");
                }else{
                  DeviceApps.openApp('com.macrovideo.v380');
                }
              },
            ),
            decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20)
                ]
            ),
          )
        ],
      ),
    );
  }
}

class visitorListWidget extends StatelessWidget {

  final int unixTime;

  const visitorListWidget({Key key, this.unixTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime _date = DateTime.fromMillisecondsSinceEpoch(unixTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: MediaQuery.of(context).size.width/1.3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Text(DateFormat.Hm().format(_date), style: TextStyle(fontWeight: FontWeight.w300),),
            VerticalDivider(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.d().add_MMMM().add_y().format(_date), style: TextStyle(fontWeight: FontWeight.w300),),
                  Text(formatTime(unixTime), style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4)),)
                ],

              ),
            )
          ],
        ),
      ),
    );
  }
}