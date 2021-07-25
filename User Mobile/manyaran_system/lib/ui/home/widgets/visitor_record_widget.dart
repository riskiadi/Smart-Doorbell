
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:manyaran_system/ui/home/widgets/visitor_list_widget.dart';

class VisitorsRecordsWidget extends StatelessWidget {

  final List visitorLog;
  final FirebaseDatabaseRepository firebaseDatabaseRepository;
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0);

  VisitorsRecordsWidget({
    required this.visitorLog, required this.firebaseDatabaseRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width / 1.2,
        padding: const EdgeInsets.only(
          bottom: 5,
          left: 17,
          right: 17,
          top: 20,
        ),
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
                    Text(
                      "Visitor Records",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      DateFormat.MMMM().add_y().format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  onSelected: (value) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Delete Records"),
                          content:
                          Text("Are you sure want to delete all records?"),
                          actions: [
                            TextButton(
                              child: Text("CANCEL"),
                              onPressed: () => {
                                Navigator.pop(context),
                              },
                            ),
                            TextButton(
                              child: Text("DELETE"),
                              onPressed: () {
                                firebaseDatabaseRepository.deleteRecords();
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
            SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400, minHeight: 0),
              child: Container(
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
                            return Column(
                              children: [
                                index == 0
                                    ? SizedBox(
                                  height: 14,
                                )
                                    : Container(),
                                VisitorListWidget(unixTime: visitorLog[index]),
                                (index + 1) == visitorLog.length
                                    ? Container()
                                    : Container(
                                  height: 0.1,
                                  color: Colors.black,
                                ),
                                index + 1 == visitorLog.length
                                    ? SizedBox(
                                  height: 14,
                                )
                                    : Container(),
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
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.0),
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
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}