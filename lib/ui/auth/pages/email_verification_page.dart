import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astro44/ui/home/pages/home_page.dart';
import 'package:astro44/ui/check/auth_page.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  // This variable stores the state of the user's email verification.
  bool isEmailVerified = false;

  // This variable stores the state of the resend email button.
  bool canResendEmail = false;

  // This variable stores a timer that is used to periodically check if the user's email is verified.
  Timer? timer;

  // This variable stores the current user.
  User? _user;

  @override
  void initState() {
    // Call the superclass's initState() method.
    super.initState();

    // Check if the user's email is verified.
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // If the user's email is not verified, start a timer to periodically check if the user's email is verified.
    if (!isEmailVerified) {
      _sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) async {
          // Get the current user.
          _user = FirebaseAuth.instance.currentUser!;

          // Reload the current user's data.
          await _user!.reload();

          // Check if the user's email is verified.
          checkEmailVerified();
        },
      );
    }
  }

  // This method sends a verification email to the user.
  void _sendVerificationEmail() async {
    try {
      // Get the current user.
      final user = FirebaseAuth.instance.currentUser!;

      // Send a verification email to the user.
      await user.sendEmailVerification();

      // Disable the resend email button for 5 seconds.
      setState(() => canResendEmail = false);

      // Wait for 5 seconds.
      await Future.delayed(const Duration(seconds: 5));

      // Enable the resend email button.
      setState(() => canResendEmail = true);
    } catch (e) {
      // Print the error.
      print(e);
    }
  }

  @override
  void dispose() {
    // Cancel the timer.
    timer?.cancel();

    // Call the superclass's dispose() method.
    super.dispose();
  }

  // This method checks if the user's email is verified.
  Future checkEmailVerified() async {
    // Get the current user's email verification status.
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // Update the state.
    setState(() {});

    // If the user's email is verified, cancel the timer and navigate to the Auth page.
    if (isEmailVerified) {
      timer?.cancel();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AuthCheck()));
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? HomePage()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Verify Email".tr,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                  "A verfication email is sent".tr,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.email, size: 32),
                  label:  Text(
                    "Resent Email".tr,
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: canResendEmail ? _sendVerificationEmail : null,
                ),
                const SizedBox(
                  height: 8,
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child:  Text(
                    "cancell".tr,
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
                FloatingActionButton(onPressed: () async {
                  String uui = FirebaseAuth.instance.currentUser!.uid;
                  print(uui);


                  var fcm = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uui).get();
                  var data = {
                    "to": fcm.get('fcm'),
                    "notification": {
                      "body": "New announcement assigned",
                      "OrganizationId": "2",
                      "content_available": true,
                      "priority": "high",
                      "subtitle": "Elementary School",
                      "title": "hello"
                    },
                  };
                  const JsonEncoder encoder = JsonEncoder.withIndent('  ');

                  final String jsonString = encoder.convert(data);

                  var respond = await http.post(
                      Uri.parse("https://fcm.googleapis.com/fcm/send"),
                      headers: {
                        "Content-Type": "application/json",
                        "Authorization":
                            "key=AAAAGtuQ8Q0:APA91bHTnUy4ifPviejyRt18FgeLdBJ_k7GIu40gegveSF0qIHVMZVfw5_-7YFduyEaJwPIqzZKaoOLUbvzZqOr-sEfVcrlCkA4DDue-ha8SMz34GzQ24saUoHLCJrbe51s04pBdrQvR"
                      },
                      body: jsonString);

                  print(respond.body);
                })
              ],
            ),
          ),
        );
}
