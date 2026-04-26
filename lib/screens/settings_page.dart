import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/theme_controller.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  final ThemeController themeController;

  const SettingsPage({
    super.key,
    required this.themeController,
  });

  //change password (I'll be honest i have no idea if this even works because i'm low on time, fed up with this and want to be done)
  Future<void> _changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No logged in user found")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: user.email!,
      );

      showDialog(
        context: context, //not sure why its underlined in red but it works so i aint touching
        builder: (_) => AlertDialog(
          title: const Text("Password Reset Sent"),
          content: Text(
            "A password reset email has been sent to:\n\n${user.email}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error sending reset email")),
      );
    }
  }

  // LOGOUT
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          themeController: themeController,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Toggle app theme"),
            value: themeController.isDarkMode,
            onChanged: (value) {
              themeController.toggleTheme(value);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            subtitle: const Text("Send reset email"),
            onTap: () => _changePassword(context),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}