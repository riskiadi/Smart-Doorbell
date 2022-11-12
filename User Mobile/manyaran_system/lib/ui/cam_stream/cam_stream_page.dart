import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/controller/cam_stream_controller.dart';
import 'package:fijkplayer/fijkplayer.dart';

class CamStreamPage extends GetView<CamStreamController> {

  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<CamStreamController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FijkView(
            player: _controller.player,
            color: Colors.black,
          ),
        ),
      );
    });
  }

}