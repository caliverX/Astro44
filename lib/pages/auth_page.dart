import 'package:astro44/pages/email_verification_page.dart';
import 'package:astro44/pages/home_page.dart';
import 'package:astro44/pages/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // User is logged in
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null && user.emailVerified) {
              return HomePage();
            } else {
              return EmailVerificationPage();
            }
          }

          // User is not logged in
          return LoginOrRegisterPage();
        },
      ),
    );
  }
}