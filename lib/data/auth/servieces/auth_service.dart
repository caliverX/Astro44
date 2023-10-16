import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    // Begin interactive sign-in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Sign in the user
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Get the user's username and fullname
    final String username = gUser.displayName as String;
    final String fullname = gUser.email;

    // Save the user's username and fullname to Firestore
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
    await userDoc.set({
      'username': username,
      'fullname': fullname,
    });

    return userCredential;
  }
}