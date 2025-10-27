import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;

  final List<String> items = [
    "Module 1: Basics Introduction About Python",
    "Module 2: Data Types",
    "Module 3: Control Flow",
    "Module 4: Functions",
    "Module 5: OOP",
    "Quiz"
  ];

  final LinearGradient myGradient = const LinearGradient(
    colors: [
      Color(0xFF42A5F5),
      Color(0xFF4DD0E1),
      Color(0xFF66BB6A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: myGradient)),
        title: const Text("JagPy X"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: myGradient),
              child: const Center(
                child: Text("JagPy X Menu", style: TextStyle(color: Colors.black, fontSize: 22)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(_isLoggedIn ? "Logout" : "Login / Register"),
              onTap: () {
                setState(() {
                  if (_isLoggedIn) {
                    _isLoggedIn = false;
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Admin Login"),
              onTap: () {
                Navigator.pushNamed(context, '/adminLogin');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (!_isLoggedIn) {
                  Navigator.pushNamed(context, '/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening ${items[index]}")),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: myGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    items[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
