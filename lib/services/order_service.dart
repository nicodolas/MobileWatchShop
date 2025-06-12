import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getOrdersForCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final querySnapshot =
        await _firestore
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
