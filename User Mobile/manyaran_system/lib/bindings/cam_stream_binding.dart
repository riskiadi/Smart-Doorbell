import 'package:get/get.dart';
import 'package:manyaran_system/controller/cam_stream_controller.dart';

class CamStreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CamStreamController>(() => CamStreamController());
  }
}