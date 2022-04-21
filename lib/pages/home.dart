import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_first/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../api/api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ignore: prefer_typing_uninitialized_variables
  var data, value, size, height, width;
  String location = 'Null, Press Button';
  late ProgressDialog pr;
  //var snackBar;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    _getdata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    pr = ProgressDialog(context);

    return Scaffold(
      //Header
      appBar: AppBar(
        // title: const Center(child: Text("HOME")),
        backgroundColor: Colors.yellow.shade700,
      ),

      //Body
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 248, 248, 248),

                  borderRadius: BorderRadius.circular(10),
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                    const BoxShadow(color: Colors.black87, blurRadius: 10)
                  ],
                ),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            child: const Icon(
                              Icons.schedule,
                              size: 50,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            child: TimeWidget(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: const Text(
                        "GENERAL 10 : 00 AM TO 07 : 00 PM",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            wordSpacing: 2,
                            letterSpacing: 1,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Material(
                      color: value == 2
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        //splashColor: Colors.black,
                        onTap: () async => {_attendance(context)},
                        child: Container(
                          height: 50.0,
                          width: 150.0,
                          alignment: Alignment.center,
                          // shape: ChangedButton?BoxShape.circle:BoxShape.rectangle),
                          child: value == 2
                              ? const Text(
                                  "CHECK IN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              : const Text(
                                  "CHECK OUT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),

      //Footer
      drawer: const MyDrawer(),
    );
  }

  void _getdata() async {
    var res = await callApi().getData('view_attendance');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      setState(() {
        value = body['value'];
      });
      // var userJson = localStorage.getString('user');
      // var user = json.decode(userJson!);
    }
  }

  _attendance(BuildContext context) async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
    pr.show();
    Position position = await _getGeoLocationPosition();
    var location =
        position.latitude.toString() + "," + position.longitude.toString();
    var res;
    var checkin_data = {'location': location, 'work': 0};
    var checkout_data = {'location': location};
    if (value == 2) {
      res = await callApi().postDataToken(checkin_data, 'checkin');
      var body = json.decode(res.body);
      if (body['success'] == true) {
        final snackBar = SnackBar(
          content: Text(body['result']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          value = 1;
        });
      } else {
        final snackBar = SnackBar(
          content: Text(body['result']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          value = 2;
        });
      }
    } else {
      res = await callApi().postDataToken(checkout_data, 'checkout');
      var body = json.decode(res.body);
      if (body['success'] == true) {
        // snackBar = SnackBar(
        //   content: Text(body['result']),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);

        final snackBar = SnackBar(
          content: Text(body['result']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        setState(() {
          value = 2;
        });
      } else {
        final snackBar = SnackBar(
          content: Text(body['result']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    pr.hide();
  }
}

class TimeWidget extends StatefulWidget {
  const TimeWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  var formatted_time = DateFormat('HH:mm:ss').format(DateTime.now());
  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        formatted_time = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatted_time,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 50),
    );
  }
}
