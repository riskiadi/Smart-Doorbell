
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class VisitorListWidget extends StatelessWidget {
  final int unixTime;

  VisitorListWidget({Key? key, required this.unixTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime _date = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
    bool isToday = _date.isSameDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      width: MediaQuery.of(context).size.width / 1.2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.d().format(DateTime.fromMillisecondsSinceEpoch(unixTime*1000)),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            VerticalDivider(
              width: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(unixTime*1000)),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      isToday
                          ? SizedBox(
                        width: 7,
                      )
                          : Container(),
                      isToday ? buildToday() : Container(),
                    ],
                  ),
                  Text(
                    timeAgo.format(DateTime.fromMillisecondsSinceEpoch(unixTime*1000)),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align buildToday() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
            color: Color(0xffBE3D60), borderRadius: BorderRadius.circular(10)),
        child: Text(
          "today",
          style: TextStyle(
              color: Colors.white.withOpacity(1), fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}