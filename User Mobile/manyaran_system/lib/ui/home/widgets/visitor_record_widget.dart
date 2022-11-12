import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:manyaran_system/ui/home/widgets/visitor_list_widget.dart';
import 'package:manyaran_system/ui/view_all_visitor/view_all_visitor_page.dart';
import 'package:page_transition/page_transition.dart';

class VisitorsRecordsWidget extends StatelessWidget {

  final List visitorLog;

  VisitorsRecordsWidget({
    required this.visitorLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Container(
          child: ListView.builder(
            shrinkWrap: true,
            controller: ScrollController(keepScrollOffset: true),
            itemCount: visitorLog.length,
            itemBuilder: (context, index) {
              return VisitorListWidget(unixTime: visitorLog[index]);
            },
          ),
      ),
    );
  }
}