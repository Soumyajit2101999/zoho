import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_first/api/api.dart';
import 'package:flutter_first/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  var user_name;
  var name;
  var image;
  var image_url =
      "https://achievex.technexsolutions.in/frontend/images/user-profile/";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getdata();
  }

  void _getdata() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.getString('token');
    localStorage.getString('user');

    var userJson = localStorage.getString('user');
    var user = json.decode(userJson!);

    setState(() {
      name = user['name'];
      user_name = user['email'];
      image = image_url + user['profile_pic'];
    });
  }

  @override
  Widget build(BuildContext context) {
    const imageurl =
        "https://miro.medium.com/max/1200/1*mk1-6aYaf_Bes1E3Imhc0A.jpeg";

    return Drawer(
      child: Container(
        //color: Colors.yellow.shade700,
        child: ListView(
          children: [
            DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  accountName: Text(name.toString()),
                  accountEmail: Text(user_name.toString()),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        NetworkImage(image != null ? image : imageurl),
                  ),
                )),
            const SizedBox(
              height: 50,
            ),
            const ListTile(
              leading: Icon(CupertinoIcons.home),
              title: Text(
                "Home",
                textScaleFactor: 1.2,
              ),
            ),
            const ListTile(
              leading: Icon(CupertinoIcons.profile_circled),
              title: Text(
                "Profile",
                textScaleFactor: 1.2,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              onTap: () {
                logout();
              },
              title: const Text(
                "Logout",
                textScaleFactor: 1.2,
              ),
            )
          ],
        ),
      ),
    );
  }

  logout() async {
    var res = await callApi().postDataToken('data', 'logout');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false,
      );
    } else {
      print(body['success']);
    }
  }
}
