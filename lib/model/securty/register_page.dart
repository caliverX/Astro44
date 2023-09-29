import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:astro44/componets/my_textfield.dart';
import 'package:astro44/componets/my_button.dart';
import 'package:astro44/componets/square.dart';
import 'package:astro44/servieces/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final firestore = FirebaseFirestore.instance;
  final usernameController = TextEditingController();
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  void signUserUp() async {
    setState(() {
      isLoading = true;
    });
    final userDoc = firestore.collection('users').doc();

    try {
      if (passwordController.text == confirmPasswordController.text) {
        // Create the user with email and password
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Add the username and fullname to the UserCredential object
        userCredential.user?.updateProfile(
            displayName: usernameController.text, photoURL: null);

        // Send email verification
        await userCredential.user?.sendEmailVerification();

        // Save the user data to Firestore
        userDoc.set({
          'username': usernameController.text,
          'fullname': fullnameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        });

        // Show success message or navigate to the next screen
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple,
              title: const Center(
                child: Text(
                  'Registration Successful. Please check your email for verification.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // You can navigate to the next screen here if needed
                  },
                ),
              ],
            );
          },
        );
      } else {
        showErrorDialog("Passwords don't match!");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          showErrorDialog('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          showErrorDialog('The account already exists for that email.');
        } else if (e.code == 'username-in-use') {
          showErrorDialog('The username already used.');
        } else {
          showErrorDialog('An error occurred. Please try again later.');
        }
      } else {
        showErrorDialog('An error occurred. Please try again later.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 10),
                //creating account
                Text(
                  "let's create an account for you!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                //username
                Mytextfield(
                  controller: usernameController,
                  hintText: "username",
                  obscurText: false,
                ),
                const SizedBox(height: 10),

                //fullname
                Mytextfield(
                  controller: fullnameController,
                  hintText: "full name",
                  obscurText: false,
                ),
                const SizedBox(height: 10),

                //email
                Mytextfield(
                  controller: emailController,
                  hintText: "email",
                  obscurText: false,
                ),
                const SizedBox(height: 10),

                //password
                Mytextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscurText: true,
                ),
                const SizedBox(height: 10),

                //conform password
                Mytextfield(
                  controller: confirmPasswordController,
                  hintText: "confirm Password",
                  obscurText: true,
                ),
                const SizedBox(height: 20),

                //sign in button
                mybutton(
                  text: "Sign Up",
                  onTap: signUserUp,
                ),
                const SizedBox(height: 15),

                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                //google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google button
                    SquareTitle(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: "lib/images/Google__G__Logo.svg.png"),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already Have An Account? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                            
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
