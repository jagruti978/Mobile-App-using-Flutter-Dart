import 'package:flutter/material.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';

class LessonPage extends StatefulWidget {
  final String username;
  final int moduleNumber;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const LessonPage({
    Key? key,
    required this.username,
    required this.moduleNumber,
    required this.isCompleted,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Map<String, dynamic>> lessons = [];
  int currentScreenIndex = 0;
  int visibleParagraphs = 1;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserAndLessons();
  }

  Future<void> fetchUserAndLessons() async {
    final db = JagpyDbHelper();
    final user = await db.getUserByUsername(widget.username);
    if (user == null) return;

    userId = user['id'] as int;

    lessons = await db.getLessonsByModule(widget.moduleNumber);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty || userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentLesson = lessons[currentScreenIndex];
    final paragraphs = (currentLesson['content'] as String).split('\n');
    final isLastScreen = currentScreenIndex == lessons.length - 1;
    final allParasVisible = visibleParagraphs >= paragraphs.length;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2193b0),
                Color(0xFF00bcd4),
                Color(0xFF4caf50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Module ${widget.moduleNumber}'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLesson['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...paragraphs.take(visibleParagraphs).map(
                  (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(p, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const Spacer(),
            if (!allParasVisible)
              ElevatedButton(
                onPressed: () {
                  setState(() => visibleParagraphs++);
                },
                child: const Text("Show More"),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentScreenIndex > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentScreenIndex--;
                    visibleParagraphs = 1;
                  });
                },
                child: const Text("Previous"),
              ),
            ElevatedButton(
              onPressed: () async {
                if (!allParasVisible) {
                  setState(() => visibleParagraphs = paragraphs.length);
                  return;
                }

                final db = JagpyDbHelper();
                // Automatic: use fetched userId
                await db.markLessonCompleted(userId!, currentLesson['id'] as int);

                if (isLastScreen) {
                  final moduleDone = await db.isModuleCompleted(userId!, widget.moduleNumber);
                  widget.onToggle(moduleDone);
                  Navigator.pop(context);
                } else {
                  setState(() {
                    currentScreenIndex++;
                    visibleParagraphs = 1;
                  });
                }
              },
              child: Text(isLastScreen && allParasVisible ? "Finish" : "Next"),
            ),
          ],
        ),
      ),
    );
  }
}
