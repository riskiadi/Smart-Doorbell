import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:network_tools/network_tools.dart';
import 'constant.dart';

final getStorage = GetStorage();

extension DateOnlyCompare on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

HexColor darkTextColor = HexColor("#1F2E45");

Future<bool> isLocalConnection() async{
  OpenPort isUsingLocalConnection = await PortScanner.isOpen(LOCAL_GATEWAY, 80, timeout: Duration(seconds: 3));
  if(isUsingLocalConnection.isOpen){
    OpenPort isHaveIpCam = await PortScanner.isOpen(RTSP_IP_ADDR, 554, timeout: Duration(seconds: 3));
    return isHaveIpCam.isOpen;
  }else{
    OpenPort isLocalConnection = await PortScanner.isOpen(RTSP_IP_ADDR, 554);
    OpenPort isHaveIpCam = await PortScanner.isOpen(RTSP_IP_ADDR, 554, timeout: Duration(seconds: 3));
    return isHaveIpCam.isOpen;
  }
}

camIsOnline(String ipcamera) async{
  OpenPort isLocalConnection = await PortScanner.isOpen(ipcamera, 554);
  return isLocalConnection.isOpen;
}

toastS(String title){
  BotToast.showSimpleNotification(title: title, titleStyle: TextStyle(color: Colors.white), duration: Duration(seconds: 4), backgroundColor: Colors.indigo,);
}
