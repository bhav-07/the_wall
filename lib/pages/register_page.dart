import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final pwdTextController = TextEditingController();
  final confirmPwdTextController = TextEditingController();

  //signUp the user
  void signUp() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    //make sure password match
    if (pwdTextController.text != confirmPwdTextController.text) {
      Navigator.pop(context);
      displayMessage("Passwords do not match!");
      return;
    }

    //try creating the user
    try {
      //create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: pwdTextController.text);

      //after creating the user create a new doc in FB called users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
            'username': emailTextController.text.split('@')[0],//username is the email before the @
            'bio': 'Empty bio...',//initally empty
          });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "Let's create an account",
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
                const SizedBox(height: 25),
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false),
                const SizedBox(height: 25),
                MyTextField(
                    controller: pwdTextController,
                    hintText: 'Password',
                    obscureText: true),
                const SizedBox(height: 25),
                MyTextField(
                    controller: confirmPwdTextController,
                    hintText: 'Confirm Password',
                    obscureText: true),
                const SizedBox(height: 25),
                MyButton(onTap: signUp, text: 'Sign Up'),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text("Login now",
                          style: TextStyle(
                              color: Color.fromARGB(255, 10, 102, 177),
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
