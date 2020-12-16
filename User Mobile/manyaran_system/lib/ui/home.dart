import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:page_transition/page_transition.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:manyaran_system/ui/setting.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

extension DateOnlyCompare on DateTime{
  bool isSameDay(DateTime other){
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();

class HomePage extends StatefulWidget {

  final User user;

  const HomePage({@required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User _user;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription visitorSubscription;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPressed = false;

  @override
  void initState() {

    _user = widget.user;

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
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                HeaderWidget(user: _user,),
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
                // cameraViewer(),
                SizedBox(height: 15),
                FutureBuilder(
                  future: _firebaseDatabaseRepository.getVisitors(),
                  builder: (context, AsyncSnapshot<List<int>> snapshot) {
                    if(snapshot.hasData){
                      List visitorLog = snapshot.data;
                      if(visitorLog.length<=0) return emptyVisitorState();
                      return VisitorsRecordsWidget(visitorLog: visitorLog);
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

class cameraViewer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(child: VlcPlayer(
      controller: VlcPlayerController(),
      aspectRatio: 480,
      url: 'rtsp://192.168.100.17',
      placeholder: Container(child: Text('Cam Ready!'),),
    ),);
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

  final User user;

  const HeaderWidget({Key key, @required this.user}) : super(key: key);

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
                child: Text("Smart Doorbell", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Color(0XFFBE3D60),),),
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
                    color:  Colors.black,
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
                                fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          children: <TextSpan>[
                            TextSpan(
                              text: snapshot.data==null ? "-" : snapshot.data.toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color:  Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " times today.",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color:  Colors.black,
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
          InkWell(
            child: Hero(
              tag: "user_picture",
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL),
              ),
            ),
            onTap: (){
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SettingPage(user: user,)));
            },
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      width: MediaQuery.of(context).size.width/1.2,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xffBE3D60).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 5),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Visitor", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15,),),
          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${counter.monthCount}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text("Monthly Records", style: TextStyle(color: Colors.black.withOpacity(0.6),),),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${counter.yearCount}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text("Annual Records", style: TextStyle(color: Colors.black.withOpacity(0.6),),),

                ],
              ),
            ],
          ),
          SizedBox(height: 23,),
          Text("Widgets", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15,),),
          SizedBox(height: 12,),
          Container(
            width: double.infinity,
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  buildBellButton(context),
                  SizedBox(width: 15,),
                  buildCctvButton(),
                  SizedBox(width: 15,),
                  buildAddWidgetButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildBellButton(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Color(0xffBE3D60),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Color(0xffBE3D60).withOpacity(0.7), blurRadius: 2)],
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(height: 5,),
              Text(
                "Bell",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          onTap: () async{

            final dialog = await showAlertDialog<OkCancelResult>(
              context: context,
              title: "Ring the bell?",
              message: "Your doorbell will be ringing",
              barrierDismissible: true,
              style: AdaptiveStyle.cupertino,
              actions: [
                AlertDialogAction(
                    label: "Cancel",
                    isDefaultAction: true,
                    key: OkCancelResult.cancel),
                AlertDialogAction(
                  label: "Yes",
                  key: OkCancelResult.ok,
                ),
              ],
            );

            if(dialog==OkCancelResult.ok) _firebaseDatabaseRepository.setAlarmOn();

          },
        ),
      ),
    );
  }

  Container buildCctvButton() {

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Color(0xffBE3D60),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Color(0xffBE3D60).withOpacity(0.7), blurRadius: 2)],
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/cctv.svg',
                width: 20,
                color: Colors.white,
              ),
              SizedBox(height: 5,),
              Text(
                "Cam",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          onTap: (){
            openCCTV();
          },
        ),
      ),
    );

  }

  Container buildAddWidgetButton() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 2)],
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.black.withOpacity(0.4),
                size: 20,
              ),
              SizedBox(height: 5,),
              Text(
                "Add",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  letterSpacing: 1,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

class VisitorsRecordsWidget extends StatelessWidget {

  final List visitorLog;
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0);

  VisitorsRecordsWidget({@required this.visitorLog,});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width/1.2,
        padding: const EdgeInsets.only(bottom: 5, left: 17, right: 17, top: 20,),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0xffBE3D60).withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 5),
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Visitor Records", style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),),
                    SizedBox(height: 5,),
                    Text(DateFormat.MMMM().add_y().format(DateTime.now()), style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12,),),
                  ],
                ),
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
            ),
            SizedBox(height: 10,),
            Container(
              height: 400,
              child: Stack(
                children: [
                  Scrollbar(
                    thickness: 4,
                    controller: _scrollController,
                    radius: Radius.circular(30),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: ScrollController(keepScrollOffset: true),
                      itemCount: visitorLog.length,
                      itemBuilder: (context, index) {
                        return  Column(
                          children: [
                            index==0 ? SizedBox(height: 14,) : Container(),
                            visitorListWidget(unixTime: visitorLog[index]),
                            (index+1) == visitorLog.length ? Container() : Container(height: 0.1, color: Colors.black,),
                            index+1==visitorLog.length ? SizedBox(height: 14,) : Container(),
                          ],
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white,
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        )
    );
  }
}

class visitorListWidget extends StatelessWidget {

  final int unixTime;

  visitorListWidget({Key key, this.unixTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime _date = DateTime.fromMillisecondsSinceEpoch(unixTime);
    DateTime _dateNow = DateTime.now();
    bool isToday = _date.isSameDay(_dateNow);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      width: MediaQuery.of(context).size.width/1.2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat.d().format(_date), style: TextStyle(fontSize:14, fontWeight: FontWeight.bold, color: Colors.black,),),
            VerticalDivider(width: 20,),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.Hms().format(_date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      isToday ? SizedBox(width: 7,) : Container(),
                      isToday ? buildToday() : Container(),
                    ],
                  ),
                  Text(formatTime(unixTime), style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 13,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align buildToday(){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
            color: Color(0xffBE3D60),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text(
          "today",
          style: TextStyle(
            color: Colors.white.withOpacity(1),
            fontWeight: FontWeight.w300
          ),
        ),
      ),
    );
  }
  
}
