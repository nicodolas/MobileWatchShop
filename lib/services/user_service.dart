import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/models/shipping_address_model.dart';

class UserService {
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      print("Đang truy vấn document ID: $userId từ collection: users");

      DocumentSnapshot doc = await _userCollection.doc(userId).get();

      if (!doc.exists) {
        print("hông tìm thấy document với ID: $userId");
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;
      print("Dữ liệu người dùng: $data");
      return data;
    } catch (e) {
      print("Lỗi Firestore: $e");
      return null;
    }
  }

  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _userCollection.doc(userId).update(updatedData);
    } catch (e) {
      print("Error");
    }
  }

  Future<ShippingAddress?> getUserAddress(String userId) async {
    final doc = await _userCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data['userAddress'] == null) return null;

    return ShippingAddress.fromMap(
      Map<String, dynamic>.from(data['userAddress']),
    );
  }
}
