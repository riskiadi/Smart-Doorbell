import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/controller/home_controller.dart';
import 'package:manyaran_system/data/models/ip_camera.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/utils/constant.dart';
import 'package:manyaran_system/utils/helper.dart';

class IpCamPreviewWidget extends GetView<HomeController> {
  final bool isUsingLocalConnection;
  final List<IPCamera>? ipCamList;

  const IpCamPreviewWidget({Key? key, required this.isUsingLocalConnection, required this.ipCamList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: ipCamList?.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              return GestureDetector(
                onTap: () {

                  BotToast.showLoading();

                  isLocalConnection().then((isLocal){

                    Get.toNamed(Routes.CAM_STREAM, arguments: [index, isLocal ?  "${ipCamList?[index].ipLocal}" : "${ipCamList?[index].ipInternet}"]);

                    BotToast.closeAllLoading();
                    BotToast.showSimpleNotification(
                      title: "Using ${isLocal ? "local" : "internet"} connection.",
                      duration: Duration(seconds: 10),
                      align: Alignment.bottomCenter,
                    );

                  });

                },
                child: Padding(
                  padding: EdgeInsets.only(left: index==0 ? 35:10 , right: index== ipCamList!.length-1 ? 35:10,),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ]),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                                child: Image.network(
                                  "$LAST_SNAPSHOT/cctv%2Flast_snapshot%2F$index.jpg?alt=media",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/thumbnail_cctv.jpg',fit: BoxFit.cover,),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 30,
                                      spreadRadius: 45,
                                      offset: Offset(0, 9),
                                    )
                                  ]
                              ),
                            ),
                          ),
                          Positioned(
                              left: 20,
                              top: 14,
                              right: 20,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 7,
                                          width: 7,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                              color: ipCamList?[index].isOnline ?? false ? HexColor(ONLINE_COLOR) : HexColor(OFFLINE_COLOR),
                                              borderRadius: BorderRadius.circular(100),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: ipCamList?[index].isOnline ?? false ? HexColor(ONLINE_COLOR).withOpacity(0.8) : HexColor(OFFLINE_COLOR).withOpacity(0.8),
                                                    blurRadius: 5,
                                                    spreadRadius: 1
                                                ),
                                              ]
                                          ),
                                        ),
                                        Text(
                                          ipCamList?[index].isOnline ?? false ? "Live" : "Offline",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              letterSpacing: 1.3,
                                              fontWeight: FontWeight.w300
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${ipCamList?[index].name}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

}
