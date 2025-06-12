import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String? parentId;
  final String productId;
  final String question;
  final Timestamp questionDate;
  final String questionId;
  final String userId;

  Question({
    this.parentId,
    required this.productId,
    required this.question,
    required this.questionDate,
    required this.questionId,
    required this.userId,
  });

  // Hàm chuyển đổi từ Firestore
  factory Question.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Question(
      parentId: data['parentId'],
      productId: data['productId'] ?? '',
      question: data['question'] ?? '',
      questionDate: data['questionDate'] ?? Timestamp.now(),
      questionId: data['questionId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}
