import 'package:ahtshopdongho/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionService {
  final CollectionReference _questionsCollection = FirebaseFirestore.instance
      .collection('questions');

  Future<List<Question>> fetchQuestionsForProduct(String productId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('questions')
            .where('productId', isEqualTo: productId)
            .orderBy('questionDate')
            .get();
    return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
  }

  Map<String, List<Question>> groupReplies(List<Question> allQuestions) {
    Map<String, List<Question>> replyMap = {};
    for (var q in allQuestions) {
      if (q.parentId != null) {
        replyMap.putIfAbsent(q.parentId!, () => []).add(q);
      }
    }
    return replyMap;
  }
}
