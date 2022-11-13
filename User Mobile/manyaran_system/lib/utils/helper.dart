import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:manyaran_system/data/repository/firebase_database.dart';
import 'package:network_tools/network_tools.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'constant.dart';

final getStorage = GetStorage();
final firebaseRepository = FirebaseDatabaseRepository();
User? user = FirebaseAuth.instance.currentUser;

extension DateOnlyCompare on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

HexColor darkTextColor = HexColor("#1F2E45");

Future<bool> isLocalConnection() async{
  var isUsingLocalConnection = await PortScanner.isOpen(LOCAL_GATEWAY, 80, timeout: Duration(seconds: 3));
  return isUsingLocalConnection?.openPort.isNotEmpty ?? false;

  // if(isUsingLocalConnection.isOpen){
  //   OpenPort isHaveIpCam = await PortScanner.isOpen(RTSP_IP_ADDR, 554, timeout: Duration(seconds: 3));
  //   return isHaveIpCam.isOpen;
  // }else{
  //   OpenPort isLocalConnection = await PortScanner.isOpen(RTSP_IP_ADDR, 554);
  //   OpenPort isHaveIpCam = await PortScanner.isOpen(RTSP_IP_ADDR, 554, timeout: Duration(seconds: 3));
  //   return isHaveIpCam.isOpen;
  // }

}

Future<PackageInfo> packageInfo()async => await PackageInfo.fromPlatform();

camIsOnline(String ipcamera) async{
  var isLocalConnection = await PortScanner.isOpen(ipcamera, 554);
  return isLocalConnection?.openPort.isNotEmpty ?? false;
}

toastS(String title){
  BotToast.showSimpleNotification(title: title, titleStyle: TextStyle(color: Colors.white), duration: Duration(seconds: 4), backgroundColor: Colors.indigo, align: Alignment.bottomCenter);
}

showOkDialog(BuildContext context, { String title = "Title", String message = "Message" }){
  showAlertDialog<OkCancelResult>(
      context: context,
      title: title,
      message: message,
      style: AdaptiveStyle.iOS,
      actions: [
        AlertDialogAction(label: "OK", key: OkCancelResult.cancel)
      ]);
}