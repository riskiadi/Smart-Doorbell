import 'package:get/get.dart';
import 'package:manyaran_system/bindings/add_camera_binding.dart';
import 'package:manyaran_system/bindings/cam_stream_binding.dart';
import 'package:manyaran_system/bindings/home_binding.dart';
import 'package:manyaran_system/bindings/login_binding.dart';
import 'package:manyaran_system/bindings/setting_binding.dart';
import 'package:manyaran_system/bindings/user_list_binding.dart';
import 'package:manyaran_system/routes/app_routes.dart';
import 'package:manyaran_system/ui/add_camera/add_camera_page.dart';
import 'package:manyaran_system/ui/cam_stream/cam_stream_page.dart';
import 'package:manyaran_system/ui/home/home_page.dart';
import 'package:manyaran_system/ui/login/login_page.dart';
import 'package:manyaran_system/ui/security/security_page.dart';
import 'package:manyaran_system/ui/setting/setting_page.dart';
import 'package:manyaran_system/ui/user_list/user_list_page.dart';
import 'package:manyaran_system/ui/view_all_visitor/view_all_visitor_page.dart';
import 'package:manyaran_system/ui/youtube_live/youtube_live_page.dart';

class AppPages{

  static final pages = [

    GetPage(name: Routes.INITIAL, page: ()=>LoginPage(), binding: LoginBinding()),
    GetPage(name: Routes.HOME, page: ()=>HomePage(), binding: HomeBinding()),
    GetPage(name: Routes.ADD_CAMERA, page: ()=>AddCameraPage(), binding: AddCameraBinding()),
    GetPage(name: Routes.LOGIN, page: ()=>LoginPage(), binding: LoginBinding()),
    GetPage(name: Routes.CAM_STREAM, page: ()=>CamStreamPage(), binding: CamStreamBinding()),
    GetPage(name: Routes.SECURITY, page: ()=>SecurityPage(), binding: LoginBinding()),
    GetPage(name: Routes.SETTING, page: ()=>SettingPage(), binding: SettingBinding()),
    GetPage(name: Routes.USER_LIST, page: ()=>UserListPage(), binding: UserListBinding()),
    GetPage(name: Routes.VIEW_ALL_VISITOR, page: ()=>ViewAllVisitorPage(), binding: LoginBinding()),
    GetPage(name: Routes.YOUTUBE_LIVE, page: ()=>YoutubeLivePage(), binding: LoginBinding()),

  ];
}
