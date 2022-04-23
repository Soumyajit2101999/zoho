import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_first/api/api.dart';
import 'package:flutter_first/pages/home.dart';
import 'package:flutter_first/utils/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var name = "";
  // ignore: non_constant_identifier_names
  bool ChangedButton = false;
  bool icon = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _showmessage(msg) {
    final snackbar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  moveToHome(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        ChangedButton = true;
      });

      var data = {
        'email': emailController.text,
        'password': passwordController.text
      };

      var res = await callApi().postData(data, 'login');
      var body = json.decode(res.body);
      if (body['success'] == true) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', body['access_token']);
        localStorage.setString('user', json.encode(body['user']));

        var userJson = localStorage.getString('user');
        var user = json.decode(userJson!);

        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          icon = true;
        });
        await Future.delayed(const Duration(milliseconds: 100));
        //await Navigator.pushNamedReplacement(context, MyRoutes.home);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
        );
      } else {
        _showmessage(body['error']);

        setState(() {
          ChangedButton = false;
          icon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        // color: Colors.red,
        child: ListView(
          children: [
            Image.asset("assets/images/login_image.png", fit: BoxFit.cover),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Welcome",
                style: GoogleFonts.pacifico(
                    textStyle: TextStyle(
                        color: Colors.yellow.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        letterSpacing: 2)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Enter Email",
                          labelText: "Email",
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "Email cannot be empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                          setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.password_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "Username cannot be empty";
                          } else if (value != null && value.length < 6) {
                            return "Password length should be atleast 6";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),

                      Material(
                        color: Colors.yellow.shade700,
                        borderRadius: ChangedButton
                            ? BorderRadius.circular(50)
                            : BorderRadius.circular(10),
                        child: InkWell(
                          //splashColor: Colors.black,
                          onTap: () => moveToHome(context),
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            height: 50.0,
                            width: ChangedButton ? 50.0 : 100.0,
                            alignment: Alignment.center,

                            // shape: ChangedButton?BoxShape.circle:BoxShape.rectangle),
                            child: ChangedButton
                                ? (icon
                                    ? Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 34,
                                      )
                                    : CircularProgressIndicator(
                                        color: Colors.white))
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 32.0, horizontal: 32.0),
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       Navigator.pushNamed(context, MyRoutes.home);
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.symmetric(
                      //           vertical: 12.0, horizontal: 16.0),
                      //       child: Text("Login",
                      //           style: TextStyle(
                      //               fontWeight: FontWeight.bold, fontSize: 16.0)),
                      //     ),
                      //     style: ButtonStyle(
                      //       backgroundColor:
                      //           MaterialStateProperty.all(Colors.yellow.shade700),
                      //       foregroundColor:
                      //           MaterialStateProperty.all(Colors.black87),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                )),
          ],
          // child: Form(
          //   key: _formKey,
          //   child: Column(
          //     children: [
          //       // const SizedBox(
          //       //   height: 50.0,
          //       // ),
          //       // Image.asset("assets/images/login_image.png", fit: BoxFit.cover),
          //       const SizedBox(
          //         height: 20.0,
          //       ),
          //       Text(
          //         "Welcome",
          //         style: GoogleFonts.pacifico(
          //             textStyle: TextStyle(
          //                 color: Colors.yellow.shade700,
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 42,
          //                 letterSpacing: 2)),
          //       ),
          //       const SizedBox(
          //         height: 20.0,
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(
          //             vertical: 16.0, horizontal: 32.0),
          //         child: Column(
          //           children: [
          //             TextFormField(
          //               controller: emailController,
          //               decoration: const InputDecoration(
          //                 prefixIcon: Icon(
          //                   Icons.email_outlined,
          //                   color: Colors.grey,
          //                 ),
          //                 hintText: "Enter Email",
          //                 labelText: "Email",
          //                 labelStyle: TextStyle(),
          //                 border: OutlineInputBorder(),
          //               ),
          //               validator: (value) {
          //                 if (value != null && value.isEmpty) {
          //                   return "Email cannot be empty";
          //                 }
          //                 return null;
          //               },
          //               onChanged: (value) {
          //                 name = value;
          //                 setState(() {});
          //               },
          //             ),
          //             const SizedBox(
          //               height: 30.0,
          //             ),
          //             TextFormField(
          //               controller: passwordController,
          //               obscureText: true,
          //               decoration: const InputDecoration(
          //                 prefixIcon: Icon(
          //                   Icons.password_outlined,
          //                   color: Colors.grey,
          //                 ),
          //                 hintText: "Enter Password",
          //                 labelText: "Password",
          //                 border: OutlineInputBorder(),
          //               ),
          //               validator: (value) {
          //                 if (value != null && value.isEmpty) {
          //                   return "Username cannot be empty";
          //                 } else if (value != null && value.length < 6) {
          //                   return "Password length should be atleast 6";
          //                 }
          //                 return null;
          //               },
          //             ),
          //             const SizedBox(
          //               height: 40.0,
          //             ),

          //             Material(
          //               color: Colors.yellow.shade700,
          //               borderRadius: ChangedButton
          //                   ? BorderRadius.circular(50)
          //                   : BorderRadius.circular(10),
          //               child: InkWell(
          //                 //splashColor: Colors.black,
          //                 onTap: () => moveToHome(context),
          //                 child: AnimatedContainer(
          //                   duration: const Duration(seconds: 1),
          //                   height: 50.0,
          //                   width: ChangedButton ? 50.0 : 100.0,
          //                   alignment: Alignment.center,

          //                   // shape: ChangedButton?BoxShape.circle:BoxShape.rectangle),
          //                   child: ChangedButton
          //                       ? (icon
          //                           ? Icon(
          //                               Icons.done,
          //                               color: Colors.white,
          //                               size: 34,
          //                             )
          //                           : CircularProgressIndicator(
          //                               color: Colors.white))
          //                       : const Text(
          //                           "Login",
          //                           style: TextStyle(
          //                               color: Colors.white,
          //                               fontWeight: FontWeight.bold,
          //                               fontSize: 18),
          //                         ),
          //                 ),
          //               ),
          //             ),
          //             // Padding(
          //             //   padding: const EdgeInsets.symmetric(
          //             //       vertical: 32.0, horizontal: 32.0),
          //             //   child: ElevatedButton(
          //             //     onPressed: () {
          //             //       Navigator.pushNamed(context, MyRoutes.home);
          //             //     },
          //             //     child: Padding(
          //             //       padding: const EdgeInsets.symmetric(
          //             //           vertical: 12.0, horizontal: 16.0),
          //             //       child: Text("Login",
          //             //           style: TextStyle(
          //             //               fontWeight: FontWeight.bold, fontSize: 16.0)),
          //             //     ),
          //             //     style: ButtonStyle(
          //             //       backgroundColor:
          //             //           MaterialStateProperty.all(Colors.yellow.shade700),
          //             //       foregroundColor:
          //             //           MaterialStateProperty.all(Colors.black87),
          //             //     ),
          //             //   ),
          //             // )
          //           ],
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
