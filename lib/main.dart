import 'package:flutter/material.dart';
import 'package:flutter_first/pages/home.dart';
import 'package:flutter_first/utils/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isloggedin = false;
  var token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getdata();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
          primarySwatch: Colors.yellow,
          primaryColor: Colors.yellow.shade700,
          fontFamily: GoogleFonts.lato().fontFamily,
          scaffoldBackgroundColor: Color.fromARGB(255, 230, 237, 239)),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: MyRoutes.root,
      routes: {
        MyRoutes.root: (context) => isloggedin ? const Home() : const Login(),
        // MyRoutes.login: (context) => const Login(),
        // MyRoutes.home: (context) => const Home(),
      },
    );
  }

  void _getdata() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');

    if (token != null) {
      print(token);
      setState(() {
        isloggedin = true;
      });
    } else {
      setState(() {
        isloggedin = false;
      });
    }
  }
}
