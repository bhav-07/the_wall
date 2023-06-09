import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/button.dart';
import 'package:the_wall/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final pwdTextController = TextEditingController();

  //sign in the user
  void signIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );


    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text, password: pwdTextController.text);

          //pop the loading circle
          Navigator.pop(context);
    } on FirebaseAuthException catch (e) {

      Navigator.pop(context); 
      displayMessage(e.code);
    }
  }

  //display the error message while sign in
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
                    height: 30,
                  ),
                  Text(
                    "Welcome back 😄",
                    style: TextStyle(fontSize: 30, color: Colors.grey[700]),
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
                  MyButton(onTap: signIn, text: 'Sign In'),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text("Register now",
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
        ));
  }
}
