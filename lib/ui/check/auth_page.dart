import 'package:astro44/ui/auth/pages/auth_page.dart';
import 'package:astro44/ui/auth/pages/email_verification_page.dart';
import 'package:astro44/ui/master/master_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

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

          if (snapshot.hasData) {

            User? user = snapshot.data;
            if (user != null) {
              if(!user.emailVerified) {
                return const EmailVerificationPage();
              } else {
                return  const MasterPage();
              }


            } else {
                          return const AuthPage();
            }
          } else {
            return const AuthPage();
          }
        }),
    );
  }
}