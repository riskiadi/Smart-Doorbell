import 'package:get/get.dart';
import 'package:manyaran_system/controller/add_camera_controller.dart';

class AddCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddCameraController>(() => AddCameraController());
  }
}