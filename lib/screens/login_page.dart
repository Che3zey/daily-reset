import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'challenge_page.dart';
import '../services/theme_controller.dart';

class LoginPage extends StatefulWidget {
  final ThemeController themeController;

  const LoginPage({
    super.key,
    required this.themeController,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //save the FCM token
  Future<void> saveToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'email': user.email,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Token save failed: $e"); //print command for debug purposes
    }
  }

  //login
  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      saveToken();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
      return;
    } finally {
      setState(() {
        loading = false;
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengePage(
          themeController: widget.themeController,
        ),
      ),
    );
  }

  //register account
  Future<void> register() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      saveToken();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
      return;
    } finally {
      setState(() {
        loading = false;
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengePage(
          themeController: widget.themeController,
        ),
      ),
    );
  }

  //UI (ui satnds for ur idiot)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            if (loading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),

              TextButton(
                onPressed: register,
                child: const Text("Create Account"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}