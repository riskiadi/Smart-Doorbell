import 'package:fijkplayer/fijkplayer.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';

class CamStreamController extends GetxController {

  final _indexPosition = RxnInt();
  final _ipAddress = RxnString();
  final _player = FijkPlayer().obs;

  int? get indexPosition => this._indexPosition.value;

  set indexPosition(value) {
    this._indexPosition.value = value;
  }

  String? get ipAddress => this._ipAddress.value;

  set ipAddress(value) {
    this._ipAddress.value = value;
  }

  FijkPlayer get player => this._player.value;

  set player(value) {
    this._player.value = value;
  }

  @override
  void onInit() {
    super.onInit();

    var args = Get.arguments as List<dynamic>;
    indexPosition = args[0] as int;
    ipAddress = args[1] as String;

    player.setDataSource(Uri.parse(ipAddress??"").toString(), autoPlay: true,);
    player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    player.enterFullScreen();
    Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    player.release();
  }

}