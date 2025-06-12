import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference _categoriesCollection = FirebaseFirestore.instance
      .collection('categories');

  // Lấy tên danh mục theo ID
  Future<String?> getCategoryNameById(String categoryId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _categoriesCollection.doc(categoryId).get();

      if (docSnapshot.exists) {
        return docSnapshot['categoryName'];
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy tên danh mục: $e');
      return null;
    }
  }

  // Lấy toàn bộ danh mục
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await _categoriesCollection.get();
      return snapshot.docs
          .map(
            (doc) => {
              'categoryId': doc.id,
              ...doc.data() as Map<String, dynamic>,
            },
          )
          .toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách danh mục: $e');
      return [];
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    final categoryDoc =
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .get();
    if (categoryDoc.exists) {
      return categoryDoc['categoryName'];
    }
    return '';
  }
}
