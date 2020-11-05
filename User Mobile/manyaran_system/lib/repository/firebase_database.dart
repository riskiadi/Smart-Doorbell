import 'package:firebase_database/firebase_database.dart';
import 'package:weather/weather.dart';

class FirebaseDatabaseRepository{

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future getAlarmStatus() async{
    DataSnapshot dataSnapshot = await databaseReference.child('doorbell').once();
    return dataSnapshot.value["isOn"];
  }

  Future getVisitorToday() async{
    int visitorCounter = 0;
    int unixTime;
    DateTime dateTime = DateTime.now();
    Map<dynamic, dynamic> visitors;
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').child(dateTime.year.toString()).child(dateTime.month.toString()).once();
    visitors = dataSnapshot.value;
    visitors.forEach((key, value) {
      unixTime = visitors[key]["date"] * 1000;
      if (dateTime.day == DateTime.fromMillisecondsSinceEpoch(unixTime).day &&
          dateTime.month == DateTime.fromMillisecondsSinceEpoch(unixTime) .month &&
          dateTime.year == DateTime.fromMillisecondsSinceEpoch(unixTime).year){
        visitorCounter++;
      }
    });
    return visitorCounter;
  }

  Future getVisitors() async{
    int unixTime;
    DateTime dateTime = DateTime.now();
    List<int> visitorLog = List();
    Map<dynamic, dynamic> visitors;
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').child(dateTime.year.toString()).child(dateTime.month.toString()).once();
    if(dataSnapshot.value == null) return visitorLog;
    visitors = dataSnapshot.value;
    visitors.forEach((key, value) {
      unixTime = visitors[key]["date"] * 1000;
      if (dateTime.month == DateTime.fromMillisecondsSinceEpoch(unixTime).month && dateTime.year == DateTime.fromMillisecondsSinceEpoch(unixTime).year){
        visitorLog.add(unixTime);
      }
    });
    visitorLog.sort((a, b){
      return b.compareTo(a);
    });
    return visitorLog;
  }

  Future setAlarmOn() async{
    await databaseReference.child('doorbell/isOn').set(true);
  }

  Future setAlarmOff() async{
    await databaseReference.child('doorbell/isOn').set(false);
  }

  Future getWeather() async{
    WeatherFactory wf = new WeatherFactory("78ac1e65c9434b6fa3255dcc7a1a7109", language: Language.INDONESIAN);
    Weather weather= await wf.currentWeatherByCityName('semarang');
    return weather;
  }

}