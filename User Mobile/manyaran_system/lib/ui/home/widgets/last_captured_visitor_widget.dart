import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

class LastCapturedVisitorWidget extends StatelessWidget {
  final List<int>? visitorLog;

  const LastCapturedVisitorWidget({Key? key, this.visitorLog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return visitorLog == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 170,
                  width: 1.sw / 1.2,
                  child: Swiper(
                    itemCount: visitorLog?.length ?? 0,
                    scale: 1,
                    pagination: SwiperPagination(),
                    physics: BouncingScrollPhysics(),
                    autoplay: true,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                          visitorLog![index] * 1000,
                          isUtc: true);
                      var encodedPath = Uri.encodeComponent(
                          "cctv/snapshot/${DateFormat('yyyy/MM/dd').format(dateTime)}/${visitorLog?[index]}.jpg");
                      var imagePath =
                          "https://firebasestorage.googleapis.com/v0/b/manyaran-sistem.appspot.com/o/$encodedPath?alt=media";
                      return InkWell(
                        onTap: () {
                          showImageViewer(context, CachedNetworkImageProvider(imagePath));
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              bottom: 0,
                              child: CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 7,
                              right: 7,
                              child: GlassmorphicContainer(
                                width: 150.w,
                                height: 30,
                                borderRadius: 100,
                                blur: 7,
                                alignment: Alignment.center,
                                border: 0,
                                linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.25),
                                    ],
                                    stops: [0.1,1,],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.5),
                                    Colors.white.withOpacity(0.5),
                                  ],
                                ),
                                child: Text(
                                  "${DateFormat('dd-MM-yyyy').format(dateTime)}, ${DateFormat('HH : mm : ss').format(dateTime)}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          );
  }
}
