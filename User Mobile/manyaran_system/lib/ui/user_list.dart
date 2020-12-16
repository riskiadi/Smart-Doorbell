import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manyaran_system/models/user_registered.dart';
import 'package:manyaran_system/repository/firebase_database.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {

  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();
  final List<UserRegisteredModel> _userList = List<UserRegisteredModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "User Permission",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _firebaseDatabaseRepository.getUserRegistered(),
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if(snapshot.hasData){

            _userList.clear();
            Map<String, UserRegisteredModel> userRegisteredModel = userRegisteredModelFromJson(jsonEncode(snapshot.data.value));
            userRegisteredModel.forEach((key, UserRegisteredModel value) {
              _userList.add(
                UserRegisteredModel(
                  idToken: key,
                  email: value.email,
                  name: value.name,
                  access: value.access,
                  avatar: value.avatar,
                  createdDate: value.createdDate,
                  createdUnix: value.createdUnix,
                ),
              );
            });

            return ListView.separated(
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                final item = _userList[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(_userList[index].avatar),),
                  title: Text(item.name, style: TextStyle(color: Colors.black),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.email, style: TextStyle(color: Colors.black),),
                      SizedBox(height: 5,),
                      Text("Registered ${item.createdDate}"),
                    ],
                  ),
                  trailing: Icon(item.access ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff, color: Color(0XFF393e46), size: 26,),
                  onTap: (){
                    setState(() {
                      _firebaseDatabaseRepository.setAccess(item.idToken, item.access ? false : true);
                    });
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            );

          }else{
            return Center(child: CircularProgressIndicator(strokeWidth: 2.6, valueColor: AlwaysStoppedAnimation(Colors.black),), heightFactor: 5,);
          }

        },
      ),
    );
  }
}
