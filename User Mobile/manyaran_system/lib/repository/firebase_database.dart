import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseRepository{
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();


  Future<DataSnapshot> getVisitors() async{
    DataSnapshot dataSnapshot = await databaseReference.child('visitors').once();
    return dataSnapshot;
  }

}