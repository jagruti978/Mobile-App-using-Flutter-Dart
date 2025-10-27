import 'package:flutter/material.dart';
import 'dart:async';
import 'jgpyhome_screen.dart';

class SplashScreen2 extends StatefulWidget {
  @override
  _SplashScreen2State createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
    with SingleTickerProviderStateMixin {
  double progress = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        progress += 0.1;
      });
      if (progress >= 1) {
        timer.cancel();
        _controller.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            RotationTransition(
              turns: _controller,
              child: Image.asset("assets/snake_loading.png", height: 150),
            ),
            SizedBox(height: 20),

            Text(
              "LOADING PROGRESS...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),

            SizedBox(height: 10),
            Text("${(progress * 100).toInt()}%"),
          ],
        ),
      ),
    );
  }
}
