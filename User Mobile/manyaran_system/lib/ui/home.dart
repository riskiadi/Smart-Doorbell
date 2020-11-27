import 'dart:async';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/models/counter.dart';
import 'package:manyaran_system/models/devicestatus.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription visitorSubscription;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPressed = false;

  @override
  void initState() {

    _firebaseMessaging.subscribeToTopic('Doorbell');
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print("onMessage: $message");
      return null;
    }, onResume: (Map<String, dynamic> message) {
      print("onResume: $message");
      openCCTV();
      return null;
    }, onLaunch: (Map<String, dynamic> message) {
      print("onLaunch: $message");
      openCCTV();
      return null;
    });

    _firebaseMessaging.requestNotificationPermissions( const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

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

    super.initState();
  }

  @override
  void dispose() {
    visitorSubscription.cancel();
    super.dispose();
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

  Widget emptyVisitorState() {
    return Container(
      height: MediaQuery.of(context).size.height/1.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("You have no visitors this month.", style: TextStyle(color: Colors.black.withOpacity(0.3)),)
        ],
      ),
    );
  }

  void vibrateDevice() async {
    if(await Vibration.hasVibrator()){
      Vibration.vibrate();
      print('Vibrate');
    }
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
                  margin: const EdgeInsets.only(right: 16, left: 16, bottom: 12),
                  width: double.infinity,
                  height: 0.7,
                  decoration: BoxDecoration(
                      color: const Color(0xFFdfe3e5),
                  ),
                ),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getBellCounter(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      Counter counter = snapshot.data;
                      return InfoWidget(counter: counter);
                    }else{
                      return Container();
                    }
                  },
                ),
                SizedBox(height: 15),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getVisitors(),
                  builder: (context, AsyncSnapshot<List<int>> snapshot) {
                    if(snapshot.hasData){
                      List visitorLog = snapshot.data;
                      if(visitorLog.length<=0) return emptyVisitorState();
                      return Container(
                        width: MediaQuery.of(context).size.width/1.3,
                        padding: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                spreadRadius: 10
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 17, right: 17, top: 14, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Visitor Records", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500),),
                                  PopupMenuButton(
                                    child: Icon(Icons.more_vert_rounded, size: 20, color: Colors.black.withOpacity(0.6),),
                                    onSelected: (value) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Delete Records"),
                                            content: Text("Are you sure want to delete all records?"),
                                            actions: [
                                              FlatButton(child: Text("CANCEL"), onPressed: () => {Navigator.pop(context),},),
                                              FlatButton(
                                                child: Text("DELETE"),
                                                onPressed: () {
                                                  _firebaseDatabaseRepository.deleteRecords();
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    size: 20,
                                                    color: Colors.red.withOpacity(0.9),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Delete records",
                                                    style: TextStyle(
                                                      color: Colors.black.withOpacity(0.6),
                                                    ),
                                                  )
                                                ],
                                              ),
                                          value: "delete",
                                        )
                                      ];
                                    },
                                  )
                                ],
                              )
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: visitorLog.length,
                              itemBuilder: (context, index) {
                                return  Column(
                                  children: [
                                    visitorListWidget(unixTime: visitorLog[index]),
                                    (index+1) == visitorLog.length ? Container() : Container(height: 0.1, color: Colors.black,),
                                  ],
                                );
                              },
                            ),
                          ],
                        )
                      );
                    }else{
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

}

Future<void> openCCTV() async {
  if (await DeviceApps.isAppInstalled('com.macrovideo.v380') != true) {
    await launch(
        "https://play.google.com/store/apps/details?id=com.macrovideo.v380");
  } else {
    DeviceApps.openApp('com.macrovideo.v380');
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
              InkWell(
                child: Text("Smart Doorbell", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                onTap: () {
                  _firebaseDatabaseRepository.getDeviceStatus().then((DeviceStatus value){
                    final int buttonUnix = value.buttonStatus*1000;
                    final int bellUnix = value.bellStatus*1000;
                    DateTime buttonStatus = DateTime.fromMillisecondsSinceEpoch(buttonUnix);
                    DateTime bellStatus = DateTime.fromMillisecondsSinceEpoch(bellUnix);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Device First Boot'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Door Button', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                  SizedBox(width: 5,),
                                  Text(formatTime(buttonUnix), style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.7)),),
                                ],
                              ),
                              SizedBox(height: 2,),
                              Text(DateFormat("dd-LLLL-yyyy kk:mm:ss").format(buttonStatus), style: TextStyle(fontSize: 13),),
                              SizedBox(height: 12,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Door Bell', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                  SizedBox(width: 5,),
                                  Text(formatTime(bellUnix), style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.7)),),
                                ],
                              ),
                              SizedBox(height: 2,),
                              Text(DateFormat("dd-LLLL-yyyy kk:mm:ss").format(bellStatus), style: TextStyle(fontSize: 13),),
                            ],
                          ),
                          actions: [
                            FlatButton(
                              child: Text("OK"),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      },
                    );
                  });
                },
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active_sharp,
                    size: 15,
                  ),
                  SizedBox(width: 5),
                  FutureBuilder(
                    future: _firebaseDatabaseRepository.getVisitorToday(),
                    builder: (context, AsyncSnapshot snapshot) {
                      return RichText(
                        text: TextSpan(
                            text: "The bell rang ",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                              color: Colors.black
                            ),
                          children: <TextSpan>[
                            TextSpan(
                              text: snapshot.data==null ? "-" : snapshot.data.toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " times today.",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black
                              ),
                            ),
                          ]
                        ),
                      );
                    },
                  )
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
              onPressed: () {
                openCCTV();
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

class InfoWidget extends StatelessWidget {
  final Counter counter;
  const InfoWidget({Key key, @required this.counter, }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: MediaQuery.of(context).size.width/1.3,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              spreadRadius: 10,
            )
          ]
      ),
      child: Column(
        children: [
          Text(DateFormat.MMMM().add_y().format(DateTime.now()), style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold)),
          Container(height: 0.1, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 10),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Monthly Records", style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text(
                    "${counter.monthCount}",
                    style: TextStyle(fontWeight: FontWeight.w300),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Annual Records", style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text("${counter.yearCount}",
                    style: TextStyle(fontWeight: FontWeight.w300),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      width: MediaQuery.of(context).size.width/1.3,
      child: IntrinsicHeight(
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              child: Text(DateFormat.d().format(_date), style: TextStyle(fontSize:15, fontWeight: FontWeight.w300),),
              foregroundColor: Colors.black.withOpacity(0.5),
              backgroundColor: Colors.black.withOpacity(0.1),
            ),
            VerticalDivider(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.Hms().format(_date), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                  Text(formatTime(unixTime), style: TextStyle(fontWeight: FontWeight.w300))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

