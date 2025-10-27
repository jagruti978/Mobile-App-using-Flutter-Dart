import 'package:flutter/material.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';
import 'dart:async';
import 'screens/first_screen.dart';
import 'screens/jgpy_login.dart';
import 'screens/jgpyhome_screen.dart';
import 'screens/admin-dashboard.dart';
import 'screens/user_home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = JagpyDbHelper();
  await dbHelper.db;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JagPY X',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen1(),

      routes: {
        "/login": (context) => JgpyLoginScreen(role: "user"),
        "/adminLogin": (context) => JgpyLoginScreen(role: "admin"),
        "/adminDashboard": (context) => AdminDashboardScreen(),
        "/mainHome": (context) => HomeScreen(),
      },
    );
  }
}
