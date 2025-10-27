import 'package:flutter/material.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';
import 'user_home.dart';

class JgpyLoginScreen extends StatefulWidget {
  final String role;
  const JgpyLoginScreen({Key? key, required this.role}) : super(key: key);

  @override
  _JgpyLoginScreenState createState() => _JgpyLoginScreenState();
}

class _JgpyLoginScreenState extends State<JgpyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRegister = false;
  final JagpyDbHelper _dbHelper = JagpyDbHelper();

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

  Future<void> _loginOrRegister() async {
    if (!_formKey.currentState!.validate()) return;

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    final db = await _dbHelper.db;

    if (isRegister) {
      try {
        await db.insert("users", {
          "username": username,
          "password": password,
          "role": widget.role,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.role} registered! Please login.")),
        );
        setState(() => isRegister = false);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username already exists.")),
        );
      }
    } else {
      final res = await db.query(
        "users",
        where: "username = ? AND password = ? AND role = ?",
        whereArgs: [username, password, widget.role],
      );

      if (res.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${widget.role}!")),
        );

        if (widget.role == "admin") {
          Navigator.pushReplacementNamed(context, "/adminDashboard");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserHomeScreen(username: username),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: myGradient),
        ),
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.blue.shade400),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? "Enter username" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? "Enter password" : null,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: myGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _loginOrRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isRegister ? "Register" : "Login",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => isRegister = !isRegister);
                },
                child: Text(
                  isRegister
                      ? "Already have an account? Login"
                      : "Don’t have an account? Register",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
