import 'package:flutter/material.dart';
import 'lesson_page.dart';
import 'quiz_page.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';

class UserHomeScreen extends StatefulWidget {
  final String username;
  const UserHomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<Map<String, dynamic>> modules = [];
  List<bool> completedModules = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserAndModules();
  }

  Future<void> fetchUserAndModules() async {
    final db = JagpyDbHelper();

    final user = await db.getUserByUsername(widget.username);
    if (user == null) return;
    userId = user['id'] as int;

    final dbClient = await db.db;
    final moduleList =
    await dbClient.rawQuery('SELECT DISTINCT module FROM lessons ORDER BY module ASC');

    List<bool> completed = [];
    for (var m in moduleList) {
      int moduleNum = m['module'] as int;
      bool isDone = await db.isModuleCompleted(userId!, moduleNum);
      completed.add(isDone);
    }

    setState(() {
      modules = moduleList.map((m) => {'module': m['module']}).toList();
      completedModules = completed;
    });
  }

  void _openModule(int index) {
    if (index == modules.length) {
      if (completedModules.contains(false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("please complete all modules before attempting the quiz."),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(username: widget.username),
          ),
        );
      }
    } else {
      int moduleNumber = modules[index]['module'] as int;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonPage(
            username: widget.username,
            moduleNumber: moduleNumber,
            isCompleted: completedModules[index],
            onToggle: (val) {
              setState(() {
                completedModules[index] = val;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = modules.map((m) => 'Module ${m['module']}').toList();
    items.add('Quiz');

    return Scaffold(
      appBar: AppBar(
        title: const Text("JagPy X - Dashboard"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.cyan, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.cyan, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  "JagPy X User",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/mainHome');
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
            bool isCompleted =
            (index < items.length - 1) ? completedModules[index] : false;

            Gradient cardGradient;

            if (index == items.length - 1) {
              // Quiz
              cardGradient = const LinearGradient(
                colors: [Color(0xFFFFF9C4), Color(0xFFFBC02D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
            } else if (isCompleted) {
              // Completed Module
              cardGradient = const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
            } else {
              // Incomplete Module
              cardGradient = const LinearGradient(
                colors: [Colors.blue, Colors.cyan, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
            }

            return GestureDetector(
              onTap: () => _openModule(index),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: cardGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      items[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
