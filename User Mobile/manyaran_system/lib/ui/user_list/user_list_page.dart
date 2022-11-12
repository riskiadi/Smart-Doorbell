import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/controller/user_list_controller.dart';

class UserListPage extends GetView<UserListController> {

  @override
  Widget build(BuildContext context) {
    return GetX<UserListController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
          body: _.isLoading.isLoading ?
          Center(child: CircularProgressIndicator(strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation(Colors.black),),
            heightFactor: 5,) :
          ListView.separated(
            physics: BouncingScrollPhysics(),
            itemCount: _.userList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(
                    _.userList[index].avatar ?? ""),),
                title: Text(
                  _.userList[index].name ?? "", style: TextStyle(color: Colors.black),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _.userList[index].email ?? "", style: TextStyle(color: Colors.black),),
                    SizedBox(height: 5,),
                    Text("Registered ${_.userList[index].createdDate}"),
                  ],
                ),
                trailing: Icon(
                  _.userList[index].access ?? false
                      ? FontAwesomeIcons.toggleOn
                      : FontAwesomeIcons.toggleOff,
                  color: Color(0XFF393e46),
                  size: 26,
                ),
                onTap: () => _.setUserAccess(_.userList[index].idToken.toString(), _.userList[index].access ?? false ? false : true),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        );
      },
    );
  }

}
