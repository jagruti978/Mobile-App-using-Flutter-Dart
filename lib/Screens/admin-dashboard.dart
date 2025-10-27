import 'package:flutter/material.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final JagpyDbHelper db = JagpyDbHelper();

  List<Map<String, dynamic>> lessons = [];
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchLessons();
    fetchQuestions();
  }

  Future<void> fetchLessons() async {
    lessons = await db.getAllLessons();
    setState(() {});
  }

  Future<void> fetchQuestions() async {
    questions = await db.getAllQuestions();
    setState(() {});
  }

  void showLessonDialog({Map<String, dynamic>? lesson}) {
    final _titleController = TextEditingController(text: lesson?['title'] ?? '');
    final _contentController = TextEditingController(text: lesson?['content'] ?? '');
    final _moduleController = TextEditingController(text: lesson != null ? lesson['module'].toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lesson == null ? "Add Lesson" : "Edit Lesson"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _contentController, decoration: const InputDecoration(labelText: "Content"), maxLines: 5),
              TextField(controller: _moduleController, decoration: const InputDecoration(labelText: "Module Number"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String title = _titleController.text.trim();
              String content = _contentController.text.trim();
              int? module = int.tryParse(_moduleController.text.trim());

              if (title.isEmpty || content.isEmpty || module == null) return;

              if (lesson == null) {
                await db.insertLesson(title, content, module);
              } else {
                await db.updateLesson(lesson['id'], title, content, module);
              }

              Navigator.pop(context);
              fetchLessons();
            },
            child: Text(lesson == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void showQuestionDialog({Map<String, dynamic>? question}) {
    final _qController = TextEditingController(text: question?['question_text'] ?? '');
    final _aController = TextEditingController(text: question?['option_a'] ?? '');
    final _bController = TextEditingController(text: question?['option_b'] ?? '');
    final _cController = TextEditingController(text: question?['option_c'] ?? '');
    final _dController = TextEditingController(text: question?['option_d'] ?? '');
    final _answerController = TextEditingController(text: question != null ? question['correct_answer_index'].toString() : '');
    final _moduleController = TextEditingController(text: question != null ? question['module'].toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(question == null ? "Add Question" : "Edit Question"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _qController, decoration: const InputDecoration(labelText: "Question")),
              TextField(controller: _aController, decoration: const InputDecoration(labelText: "Option A")),
              TextField(controller: _bController, decoration: const InputDecoration(labelText: "Option B")),
              TextField(controller: _cController, decoration: const InputDecoration(labelText: "Option C")),
              TextField(controller: _dController, decoration: const InputDecoration(labelText: "Option D")),
              TextField(controller: _answerController, decoration: const InputDecoration(labelText: "Correct Answer (0-3)"), keyboardType: TextInputType.number),
              TextField(controller: _moduleController, decoration: const InputDecoration(labelText: "Module Number"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              int? correctIndex = int.tryParse(_answerController.text.trim());
              int? module = int.tryParse(_moduleController.text.trim());

              if (_qController.text.isEmpty || correctIndex == null || module == null) return;

              if (question == null) {
                await db.insertQuestion(
                  questionText: _qController.text.trim(),
                  optionA: _aController.text.trim(),
                  optionB: _bController.text.trim(),
                  optionC: _cController.text.trim(),
                  optionD: _dController.text.trim(),
                  correctAnswerIndex: correctIndex,
                  module: module,
                );
              } else {
                await db.updateQuestion(
                  question['id'],
                  questionText: _qController.text.trim(),
                  optionA: _aController.text.trim(),
                  optionB: _bController.text.trim(),
                  optionC: _cController.text.trim(),
                  optionD: _dController.text.trim(),
                  correctAnswerIndex: correctIndex,
                  module: module,
                );
              }

              Navigator.pop(context);
              fetchQuestions();
            },
            child: Text(question == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> mergedList = [];

    mergedList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Lessons", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );

    if (lessons.isEmpty) {
      mergedList.add(const Center(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No lessons yet"),
      )));
    } else {
      for (var lesson in lessons) {
        mergedList.add(Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(lesson['title']),
            subtitle: Text('Module ${lesson['module']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => showLessonDialog(lesson: lesson), icon: const Icon(Icons.update, color: Colors.black)),
                IconButton(
                  onPressed: () async {
                    await db.deleteLesson(lesson['id']);
                    fetchLessons();
                  },
                  icon: const Icon(Icons.clear, color: Colors.black),
                ),
              ],
            ),
          ),
        ));
      }
    }

    mergedList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Quiz Questions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );

    if (questions.isEmpty) {
      mergedList.add(const Center(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("No questions yet"),
      )));
    } else {
      for (var q in questions) {
        mergedList.add(Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(q['question_text']),
            subtitle: Text('Module ${q['module']} | Correct Ans: ${q['correct_answer_index']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => showQuestionDialog(question: q), icon: const Icon(Icons.update, color: Colors.black)),
                IconButton(
                  onPressed: () async {
                    await db.deleteQuestion(q['id']);
                    fetchQuestions();
                  },
                  icon: const Icon(Icons.clear, color: Colors.black),
                ),
              ],
            ),
          ),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("JagPy X Admin"), backgroundColor: Colors.cyan),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan),
              child: Center(child: Text("JagPy X Admin", style: TextStyle(color: Colors.white, fontSize: 22))),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => Navigator.pushReplacementNamed(context, '/mainHome'),
            ),
          ],
        ),
      ),
      body: RawScrollbar(
        thumbVisibility: true,
        thickness: 10,
        radius: const Radius.circular(5),
        thumbColor: Colors.cyan,
        child: ListView(
          children: mergedList,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "lessonBtn",
            onPressed: () => showLessonDialog(),
            backgroundColor: Colors.cyan,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "questionBtn",
            onPressed: () => showQuestionDialog(),
            backgroundColor: Colors.lightGreen,
            child: const Icon(Icons.question_mark),
          ),
        ],
      ),
    );
  }
}
