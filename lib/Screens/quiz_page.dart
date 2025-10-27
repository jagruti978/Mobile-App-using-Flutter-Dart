import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jagpy_app/db/jagpy_db_helper.dart';
import 'certificate_page.dart';

class QuizPage extends StatefulWidget {
  final String username;
  const QuizPage({Key? key, required this.username}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 180;
  Timer? timer;
  int? selectedIndex;

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final db = JagpyDbHelper();
    final rawQuestions = await db.getAllQuestions();
    questions = List<Map<String, dynamic>>.from(rawQuestions);
    questions.shuffle();
    setState(() {});
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        finishQuiz();
      }
    });
  }

  void checkAnswer(int idx) {
    setState(() {
      selectedIndex = idx;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (idx == questions[currentQuestionIndex]['correct_answer_index']) score++;

      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedIndex = null;
        });
      } else {
        finishQuiz();
      }
    });
  }

  void finishQuiz() {
    timer?.cancel();
    int total = questions.length;
    double percentage = (score / total) * 100;

    if (percentage >= 50) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CertificatePage(username: widget.username),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Result"),
          content: const Text("Better luck next time! you need at least 50% correct answers."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Time Left: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              "Q${currentQuestionIndex + 1}. ${question['question_text']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...['option_a', 'option_b', 'option_c', 'option_d'].asMap().entries.map(
                  (entry) {
                int idx = entry.key;
                String key = entry.value;
                Color outlineColor = Colors.orange;

                if (selectedIndex != null) {
                  if (idx == question['correct_answer_index'] && idx == selectedIndex) {
                    outlineColor = Colors.green;
                  } else if (idx == selectedIndex && idx != question['correct_answer_index']) {
                    outlineColor = Colors.red;
                  }
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: outlineColor, width: 2),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: selectedIndex == null ? () => checkAnswer(idx) : null,
                    child: Text(question[key] ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
