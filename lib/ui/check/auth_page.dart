import 'package:astro44/ui/admin/admin_master_page.dart';
import 'package:astro44/ui/auth/pages/auth_page.dart';
import 'package:astro44/ui/auth/pages/email_verification_page.dart';
import 'package:astro44/ui/master/master_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  Future<bool> isAdmin(String uid) async {
    final db =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return db.data()!['admin'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                if (!user.emailVerified) {
                  return const EmailVerificationPage();
                } else {
                  return FutureBuilder<bool>(
                    future: isAdmin(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.data == true) {
                        return const AdminMasterPage();
                      } else {
                        return const MasterPage();
                      }
                    },
                  );
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
