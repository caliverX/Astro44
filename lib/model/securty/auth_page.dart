import 'package:astro44/model/securty/email_verification_page.dart';
import 'package:astro44/model/securty/login_or_register_page.dart';
import 'package:astro44/componets/navigationbar.dart' as MyNavigationBar;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide NavigationBar;

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // User is logged in
          if (snapshot.hasData) {
            // User is logged in
            User? user = snapshot.data;
            if (user != null && user.emailVerified) {
              // User is logged in and email is verified
              return  const MyNavigationBar.NavigationBar(); // Replace "HomePage()" with "NavigationBar()"
            } else {
              // User is logged in and email is not verified
              return const EmailVerificationPage();
            }
          } else {
            // User is not logged in
            return const LoginOrRegisterPage();
          }
        }),
    );
  }
}