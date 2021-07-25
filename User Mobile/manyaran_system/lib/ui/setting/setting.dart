import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manyaran_system/ui/login/login.dart';
import 'package:manyaran_system/ui/setting_user_permission/user_list.dart';
import 'package:page_transition/page_transition.dart';

class SettingPage extends StatefulWidget {
  final User? user;

  const SettingPage({required this.user});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user!;
  }

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
          "Account",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          accountHeader(),
        ],
      ),
    );
  }

  Widget accountHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 23),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 17),
                child: Hero(
                  tag: "user_picture",
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_user.photoURL ?? ""),
                    radius: 30,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.displayName ?? "",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.5
                    ),
                  ),
                  SizedBox(height: 7,),
                  Text(
                    _user.email??"-",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20,),
        Divider(height: 1,),
        InkWell(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical:  7,),
            leading: Icon(
              FontAwesomeIcons.users,
              color: Colors.black,
              size: 20,
            ),
            title: Text(
              "User Permission",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: UserListPage()));
            },
          ),
        ),
        Divider(height: 1,),
        InkWell(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical:  7,),
            leading: Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.black,
              size: 20,
            ),
            title: Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            onTap: () {
              _logOut().whenComplete(() {
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: LoginPage()),
                    (route) => false);
              });
            },
          ),
        ),
      ],
    );

  }

  Future _logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
  }

}
