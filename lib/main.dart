import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/login_page.dart';
import 'firebase_options.dart';
import '../services/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // this is the the firebase initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // this is the hive intitialize
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // this is for notification permisiions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController themeController = ThemeController();

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        debugPrint("Notification: ${message.notification!.title}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daily Reset',

          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.themeMode,

          home: LoginPage(
            themeController: themeController,
          ),
        );
      },
    );
  }
}