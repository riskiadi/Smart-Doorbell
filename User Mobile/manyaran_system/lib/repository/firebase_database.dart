import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/models/counter.dart';
import 'package:manyaran_system/models/devicestatus.dart';

class FirebaseDatabaseRepository{

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future<dynamic> getAlarmStatus() async{
    final DataSnapshot dataSnapshot = await databaseReference.child('doorbell').once();
    return dataSnapshot.value["isOn"];
  }

  Future getVisitorToday() async{
    int visitorCounter = 0;
    int unixTime;
    DateTime dateTime = DateTime.now();
    Map<dynamic, dynamic> visitors;
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').child(dateTime.year.toString()).child(DateFormat("MM").format(dateTime).toString()).once();
    visitors = dataSnapshot.value;
    visitors.forEach((key, value) {
      unixTime = visitors[key]["date"] * 1000;
      if (dateTime.day == DateTime.fromMillisecondsSinceEpoch(unixTime, isUtc: true,).day &&
          dateTime.month == DateTime.fromMillisecondsSinceEpoch(unixTime, isUtc: true,) .month &&
          dateTime.year == DateTime.fromMillisecondsSinceEpoch(unixTime, isUtc: true,).year){
        visitorCounter++;
      }
    });
    return visitorCounter;
  }

  Future <List<int>> getVisitors() async{
    int unixTime;
    DateTime dateTime = DateTime.now();
    List<int> visitorLog = <int>[];
    Map<dynamic, dynamic> visitors;
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').child(dateTime.year.toString()).child(DateFormat("MM").format(dateTime).toString()).once();
    if(dataSnapshot.value == null) return visitorLog;
    visitors = dataSnapshot.value;
    visitors.forEach((key, value) {
      unixTime = visitors[key]["date"] - 25200;
      if (dateTime.month == DateTime.fromMillisecondsSinceEpoch(unixTime*1000).month && dateTime.year == DateTime.fromMillisecondsSinceEpoch(unixTime*1000).year){
        visitorLog.add(unixTime);
      }
    });
    visitorLog.sort((a, b){
      return b.compareTo(a);
    });
    return visitorLog;
  }

  Future getBellCounter() async{
    DateTime dateTime = DateTime.now();
    int totalToday = await getVisitorToday();
    int totalMonth = 0;
    int totalYear = 0;
    Map<dynamic, dynamic> anualVisitor;
    DataSnapshot dataSnapshotMonth = await databaseReference.child('visitors').child(dateTime.year.toString()).once();
    anualVisitor = dataSnapshotMonth.value;

    if(anualVisitor[DateFormat("MM").format(dateTime).toString()] != null){
      anualVisitor[DateFormat("MM").format(dateTime).toString()].forEach((key, value) {
        totalMonth++;
      });
    }

    anualVisitor.forEach((key, value) {
      value.forEach((key, value) {
        totalYear++;
      });
    });
    return Counter(todayCount: totalToday, monthCount: totalMonth, yearCount: totalYear);
  }

  Future<DeviceStatus> getDeviceStatus() async{
    DataSnapshot snapshotButton = await databaseReference.child('bellbutton').child('firstBoot').once();
    DataSnapshot snapshotBell = await databaseReference.child('doorbell').child('firstBoot').once();
    DataSnapshot snapshotButtonIP = await databaseReference.child('bellbutton').child('IPAddress').once();
    DataSnapshot snapshotBellIP = await databaseReference.child('doorbell').child('IPAddress').once();
    return DeviceStatus(
      buttonStatus: snapshotButton.value - 25200,
      bellStatus: snapshotBell.value - 25200,
      buttonIP: snapshotButtonIP.value ,
      bellIP: snapshotBellIP.value,
    );
  }

  Future setAlarmOn() async{
    await databaseReference.child('doorbell/isOn').set(true);
  }

  Future setAlarmOff() async{
    await databaseReference.child('doorbell/isOn').set(false);
  }

  Future deleteRecords() async{
    return await databaseReference.child('visitors').remove();
  }

  Future registerUser(User? user) async{
    DateTime dateTime = DateTime.now();
    String dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss").format(dateTime);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('name').set(user?.displayName);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('email').set(user?.email);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('avatar').set(user?.photoURL);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('createdDate').set(dateFormat);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('createdUnix').set(dateTime.millisecondsSinceEpoch);
    await databaseReference.child('app').child('users').child(user?.uid ?? "").child('access').set(false);
  }

  Future<bool> isUserRegistered(String idToken) async{
    DataSnapshot dataSnapshot = await databaseReference.child('app').child('users').child(idToken).once();
    return dataSnapshot.value!=null;
  }

  Future<bool> isUserAllowed(String idToken) async{
    DataSnapshot dataSnapshot = await databaseReference.child('app').child('users').child(idToken).child('access').once();
    print(dataSnapshot.value);
    return dataSnapshot.value;
  }

  Future<DataSnapshot?> getUserRegistered() async{
    DataSnapshot? dataSnapshot = await databaseReference.child('app').child('users').once();
    return dataSnapshot;
  }

  Future setAccess(String idToken, bool access) async{
    await databaseReference.child('app').child('users').child(idToken).child('access').set(access);
  }

}