import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseRepository{

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future getAlarmStatus() async{
    DataSnapshot dataSnapshot = await databaseReference.child('doorbell').once();
    return dataSnapshot.value["isOn"];
  }

  Future getVisitorToday() async{
    int visitorCounter = 0;
    DateTime dateTime = DateTime.now();
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').once();
    Map<dynamic, dynamic> visitors = dataSnapshot.value;
    visitors.forEach((key, value) {
      if (dateTime.day == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).day &&
          dateTime.month == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]) .month &&
          dateTime.year == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).year){
        visitorCounter++;
      }
    });
    return visitorCounter;
  }

  Future getVisitors() async{
    DateTime dateTime = DateTime.now();
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').once();
    Map<dynamic, dynamic> visitors = dataSnapshot.value;
    List<int> visitorLog = List();
    visitors.forEach((key, value) {
      int unixTime = visitors[key]["date"];
      if (dateTime.month == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]) .month &&
          dateTime.year == DateTime.fromMillisecondsSinceEpoch(visitors[key]["date"]).year){
        visitorLog.add(unixTime);
      }
    });
    visitorLog.sort((a, b){
      return b.compareTo(a);
    });
    return visitorLog;
  }

  Future addVisitor() async{
    await databaseReference.child('visitors').push().child("date").set((DateTime.now().millisecondsSinceEpoch));
  }

  Future setAlarmOn() async{
    await databaseReference.child('doorbell/isOn').set(true);
  }

  Future setAlarmOff() async{
    await databaseReference.child('doorbell/isOn').set(false);
  }

}