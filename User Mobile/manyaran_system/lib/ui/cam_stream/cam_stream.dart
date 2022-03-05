import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:fijkplayer/fijkplayer.dart';

class CamStreamPage extends StatefulWidget {

  final int indexPosition;
  final String ipAddress;

  CamStreamPage({Key? key, required this.ipAddress, required this.indexPosition}) : super(key: key);

  @override
  _CamStreamPageState createState() => _CamStreamPageState();
}

class _CamStreamPageState extends State<CamStreamPage> {

  final FijkPlayer player = FijkPlayer();

  @override
  void initState(){
    super.initState();
    player.setDataSource(Uri.parse(widget.ipAddress).toString(), autoPlay: true,);
    player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    player.enterFullScreen();
    Wakelock.enable();
  }

  @override
  void dispose() async {
    super.dispose();
    Wakelock.disable();
    player.release();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FijkView(
          player: player,
          color: Colors.black,
        ),
      ),
    );
  }

}
