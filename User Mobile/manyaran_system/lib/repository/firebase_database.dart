import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseRepository{

  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future getAlarmStatus() async{
    DataSnapshot dataSnapshot = await databaseReference.child('doorbell').once();
    return dataSnapshot.value["isOn"];
  }

  Future getVisitors() async{
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').once();
    return dataSnapshot;
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