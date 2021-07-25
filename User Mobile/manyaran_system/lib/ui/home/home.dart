
import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:manyaran_system/ui/home/widgets/header_widget.dart';
import 'package:manyaran_system/ui/home/widgets/info_widget.dart';
import 'package:manyaran_system/ui/home/widgets/visitor_record_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:manyaran_system/models/counter.dart';
import 'package:manyaran_system/repository/firebase_database.dart';

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

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      print("OPENED");
    });

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

    super.initState();
  }

  @override
  void dispose() async {
    visitorSubscription.cancel();
    super.dispose();
  }

  Widget emptyVisitorState() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You have no visitors this month.",
            style: TextStyle(color: Colors.black.withOpacity(0.3)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xffF6F8FA),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                HeaderWidget(
                  user: _user,
                  firebaseDatabaseRepository: _firebaseDatabaseRepository,
                ),
                Container(
                  margin:
                      const EdgeInsets.only(right: 16, left: 16, bottom: 12),
                  width: double.infinity,
                  height: 0.7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFdfe3e5),
                  ),
                ),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getBellCounter(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Counter? counter = snapshot.data as Counter?;
                      return InfoWidget(counter: counter);
                    } else {
                      return Container();
                    }
                  },
                ),
                SizedBox(height: 15),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getVisitors(),
                  builder: (context, AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasData) {
                      List<int>? visitorLog = snapshot.data;
                      if (visitorLog!.length <= 0) return emptyVisitorState();
                      return VisitorsRecordsWidget(visitorLog: visitorLog, firebaseDatabaseRepository: _firebaseDatabaseRepository,);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          )),
    );
  }

  _notificationChannelInit() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'manyaran_id',
        'Manyaran System',
        'This channel is used for important notifications.',
        importance: Importance.high,
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
    }
  }

  _subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('Doorbell');
  }

}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background/terminated message");
  print(message.data);
}