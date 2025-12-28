import 'package:flutter/material.dart';
import 'auth/drone_login_screen.dart';

void main() {
  runApp(const DroneApp());
}

class DroneApp extends StatelessWidget {
  const DroneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Unit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const DroneLoginScreen(),
    );
  }
}

