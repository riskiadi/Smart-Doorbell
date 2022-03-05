import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/utils/helper.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;

class VisitorAllListWidget extends StatelessWidget {

  final String imageUrl;
  final DateTime dateTime;

  const VisitorAllListWidget({Key? key, required this.imageUrl, required this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String clock = DateFormat("HH:mm:ss").format(dateTime);
    String date = DateFormat("dd MMMM yyyy").format(dateTime);
    String ago = timeAgo.format(dateTime.subtract(Duration(hours: 7),),);
    bool isToday = dateTime.isSameDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: ()=> showImageViewer(context, CachedNetworkImageProvider(imageUrl),),
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    spreadRadius: 1.3,
                    offset: Offset(4, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 140,
                  height: 80,
                  fit: BoxFit.cover,
                  fadeInDuration : const Duration(milliseconds: 1000),
                  filterQuality: FilterQuality.low,
                  errorWidget: (context, url, error) {
                    return Center(
                        child: FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.black.withAlpha(180),),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clock, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17,),),
                      Text(date, style: TextStyle(fontSize: 14,),),
                      Text(ago, style: TextStyle(color: Colors.black.withAlpha(100), fontSize: 14,),),
                      SizedBox(height: 10,),
                    ],
                  ),
                  Text(isToday? "Today":"", style: TextStyle(color: Colors.amber.shade800, fontSize: 14,),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
