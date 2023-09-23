// Import necessary packages.
import 'package:astro44/servieces/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astro44/componets/my_textfield.dart';
import 'package:astro44/componets/my_button.dart';
import 'package:astro44/componets/square.dart';

// Define the LoginPage class.
class LoginPage extends StatefulWidget {
  final Function()?
      onTap; // Callback function for when the user taps the "Register now" button.

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Define the _LoginPageState class.
class _LoginPageState extends State<LoginPage> {
  // Create text editing controllers for the email and password fields.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign the user in.
  void signInUser() async {
    // Show a loading indicator.
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Try to sign in the user.
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Pop the loading indicator.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop the loading indicator.
      Navigator.pop(context);

      // Show an error message.
      showErorrMessage(e.code);
    }
  }

  // Show an error message to the user.
  void showErorrMessage(String message) {
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
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Reset the user's password.
  void resetPassword() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      // Pop the loading indicator.
      Navigator.pop(context);

      // Show a success message.
      showResetPasswordSuccessMessage();
    } on FirebaseAuthException catch (e) {
      // Pop the loading indicator.
      Navigator.pop(context);

      // Show an error message.
      showErorrMessage(e.code);
    }
  }

  // Show a success message to the user after their password has been reset.
  void showResetPasswordSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Password Reset Email Sent',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
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
                const SizedBox(height: 25),
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 25),
                //welcome back
                Text(
                  "Welcome Back! We Missed You!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

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

                //forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: resetPassword,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                //sign in button
                mybutton(
                  text: "Sign In",
                  onTap: signInUser,
                ),
                const SizedBox(height: 50),

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
                    SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
