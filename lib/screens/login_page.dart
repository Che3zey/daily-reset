import 'package:flutter/material.dart';
import 'challenge_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Reset - Login"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Login (Temporary)"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChallengePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}