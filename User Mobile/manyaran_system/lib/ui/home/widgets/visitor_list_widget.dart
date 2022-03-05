import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/utils/helper.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class VisitorListWidget extends StatelessWidget {
  final int unixTime;

  VisitorListWidget({Key? key, required this.unixTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime _date = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000, isUtc: true);
    bool isToday = _date.isSameDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      width: MediaQuery.of(context).size.width / 1.2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ]
              ),
              child: Center(
                child: Text(
                  DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(unixTime*1000, isUtc: true)),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 20,
              indent: 8,
              endIndent: 8,
              thickness: 1,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(unixTime*1000, isUtc: true)),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeAgo.format(DateTime.fromMillisecondsSinceEpoch((unixTime - 25200)*1000)),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  isToday ? buildToday() : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToday() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade300,
          borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        "Today",
        style: TextStyle(
          color: Colors.black87.withOpacity(0.3),
        ),
      ),
    );
  }
}