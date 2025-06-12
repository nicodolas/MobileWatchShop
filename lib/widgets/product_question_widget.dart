import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ahtshopdongho/models/question_model.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final String productId;

  const QuestionAnswerScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  _QuestionAnswerScreenState createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Question> _questions = [];
  bool _isLoading = true;
  final TextEditingController _questionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    print('Đang lấy câu hỏi cho productId: ${widget.productId}');

    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot =
          await _firestore
              .collection('questions')
              .where('productId', isEqualTo: widget.productId)
              .orderBy('questionDate', descending: true)
              .get();

      final questions =
          snapshot.docs
              .map(
                (doc) => Question.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

      setState(() {
        _questions = questions;
        _isLoading = false;
        print('List câu hỏi được cập nhật: $_questions');
      });
      for (var q in _questions) {
        print(
          "🔹 ID: ${q.questionId}, Nội dung: ${q.question}, ParentId: ${q.parentId}, Ngày hỏi: ${q.questionDate.toDate()}",
        );
      }
    } catch (error) {
      print("Error fetching questions: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải câu hỏi: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, List<Question>> _groupReplies(List<Question> allQuestions) {
    Map<String, List<Question>> replyMap = {};

    for (var q in allQuestions) {
      if (q.parentId != null && q.parentId!.isNotEmpty) {
        replyMap.putIfAbsent(q.parentId!, () => []).add(q);
      }
    }

    print("Tổng số câu trả lời được nhóm: ${replyMap.length}");
    return replyMap;
  }

  Widget _buildQuestionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_questions.isEmpty) {
      return const Center(child: Text('Chưa có câu hỏi nào.'));
    }

    final groupedReplies = _groupReplies(_questions);

    // Chỉ hiển thị các câu hỏi chính (có `parentId == null`)
    print("Tổng số câu hỏi và câu trả lời trước khi lọc: ${_questions.length}");
    List<Question> topLevelQuestions =
        _questions
            .where((q) => q.parentId == null || q.parentId!.isEmpty)
            .toList();
    print(
      "Số câu hỏi sau khi lọc (topLevelQuestions): ${topLevelQuestions.length}",
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topLevelQuestions.length,
      itemBuilder: (context, index) {
        final question = topLevelQuestions[index];
        return _buildQuestionItem(question, groupedReplies);
      },
    );
  }

  Widget _buildQuestionItem(
    Question question,
    Map<String, List<Question>> groupedReplies,
  ) {
    final replies = groupedReplies[question.questionId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Text(
            question.question,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            'Ngày hỏi: ${question.questionDate.toDate()}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),

        // Hiển thị danh sách câu trả lời đúng cách
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children:
                  replies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.question,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Trả lời vào: ${reply.questionDate.toDate()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        const Divider(),
      ],
    );
  }

  Future<void> _askQuestion() async {
    if (_formKey.currentState!.validate()) {
      final questionText = _questionController.text.trim();
      if (questionText.isNotEmpty) {
        if (_currentUser == null) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Đăng nhập'),
                  content: const Text('Bạn cần đăng nhập để đặt câu hỏi.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
          );
          return;
        }

        final userUid = _currentUser!.uid;
        final questionId = _firestore.collection('questions').doc().id;

        final newQuestion = Question(
          questionId: questionId,
          productId: widget.productId,
          question: questionText,
          questionDate: Timestamp.now(),
          userId: userUid,
          parentId: null,
        );

        try {
          await _firestore.collection('questions').doc(questionId).set({
            'questionId': newQuestion.questionId,
            'productId': newQuestion.productId,
            'question': newQuestion.question,
            'questionDate': newQuestion.questionDate,
            'userId': newQuestion.userId,
            'parentId': newQuestion.parentId,
          });

          _questionController.clear();
          _fetchQuestions();
        } catch (error) {
          print("Error adding question: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi gửi câu hỏi: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuestionList(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Đặt câu hỏi...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập câu hỏi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _askQuestion,
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     //appBar: AppBar(title: const Text('Hỏi đáp sản phẩm')),
  //     body: Column(
  //       children: [
  //         Expanded(child: _buildQuestionList()),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Form(
  //             key: _formKey,
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: TextFormField(
  //                     controller: _questionController,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Đặt câu hỏi...',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                     validator: (value) {
  //                       if (value == null || value.trim().isEmpty) {
  //                         return 'Vui lòng nhập câu hỏi';
  //                       }
  //                       return null;
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 ElevatedButton(
  //                   onPressed: _askQuestion,
  //                   child: const Text('Gửi'),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
//}