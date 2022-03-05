
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/models/devicestatus.dart';
import 'package:manyaran_system/ui/setting/setting.dart';

class HeaderWidget extends StatelessWidget {
  final User? user;
  final FirebaseDatabaseRepository firebaseDatabaseRepository;

  const HeaderWidget({Key? key, required this.user, required this.firebaseDatabaseRepository}) : super(key: key);

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
                child: Text(
                  "Manyaran System",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0XFFBE3D60),
                  ),
                ),
                onTap: () {
                  firebaseDatabaseRepository.getDeviceStatus().then((DeviceStatus value) {
                    final int buttonUnix = value.buttonStatus * 1000;
                    final int bellUnix = value.bellStatus * 1000;
                    final String buttonIP = value.buttonIP;
                    final String bellIP = value.bellIP;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Device Booting Status', style: TextStyle(fontSize: 18),),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Door Button',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    timeAgo.format(DateTime.fromMillisecondsSinceEpoch(buttonUnix)),
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Text("Date: ", style: TextStyle(fontSize: 13),),
                                    Text(
                                      DateFormat("dd LLLL yyyy kk:mm:ss")
                                          .format(DateTime.fromMillisecondsSinceEpoch(buttonUnix)),
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Text("IP: ", style: TextStyle(fontSize: 13),),
                                    Text(buttonIP,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Door Bell',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    timeAgo.format(DateTime.fromMillisecondsSinceEpoch(bellUnix)),
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Text("Date: ", style: TextStyle(fontSize: 13),),
                                    Text(
                                      DateFormat("dd LLLL yyyy kk:mm:ss")
                                          .format(DateTime.fromMillisecondsSinceEpoch(bellUnix)),
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Text("IP: ", style: TextStyle(fontSize: 13),),
                                    Text(bellIP,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
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
              Text("Welcome, ${user?.displayName?.split(" ").elementAt(0)}!", style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
              ),),
            ],
          ),
          InkWell(
            child: Hero(
              tag: "user_picture",
              child: CircleAvatar(
                backgroundImage: NetworkImage(user?.photoURL ?? ""),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: SettingPage(
                        user: user,
                      )));
            },
          ),
        ],
      ),
    );
  }
}