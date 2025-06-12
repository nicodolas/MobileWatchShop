import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamUserCart(String userId) {
    return _db
        .collection("carts")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .snapshots();
  }

  // Tìm document giỏ của user
  Future<DocumentReference?> _getUserCartDocRef(String userId) async {
    final snapshot =
        await _db
            .collection('carts')
            .where("userId", isEqualTo: userId)
            .limit(1)
            .get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.reference : null;
  }

  Future<void> removeFromCart(
    String userId,
    Map<String, dynamic> itemToRemove,
  ) async {
    final docRef = await _getUserCartDocRef(userId);

    if (docRef == null) {
      return;
    }

    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>;

    final rawCartItems = data['cartItems'];
    final cartItems =
        rawCartItems is List
            ? List<Map<String, dynamic>>.from(rawCartItems)
            : <Map<String, dynamic>>[];

    cartItems.removeWhere(
      (item) =>
          item['productId'] == itemToRemove['productId'] &&
          item['selectedImageUrl'] == itemToRemove['selectedImageUrl'],
    );

    await docRef.update({
      'cartItems': cartItems,
      'cartUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addToCart(String userId, Map<String, dynamic> itemToAdd) async {
    final docRef = await _getUserCartDocRef(userId);

    final productSnapshot =
        await _db.collection('products').doc(itemToAdd['productId']).get();
    if (!productSnapshot.exists) {
      throw Exception('Sản phẩm không tồn tại!!!!!');
    }
    final productData = productSnapshot.data()!;
    final List<dynamic> colorOptions = productData['colorOptions'] ?? [];

    final selectedOption = colorOptions.firstWhere(
      (opt) =>
          opt['color'] == itemToAdd['selectedColor'] &&
          opt['imageUrl'] == itemToAdd['selectedImageUrl'],
      orElse: () => null,
    );

    if (selectedOption == null) {
      throw Exception('Không tìm thấy màu.');
    }

    final int stock = selectedOption['stock'] ?? 0;
    final int quantityToAdd = itemToAdd['quantity'] ?? 1;

    // Nếu chưa có giỏ thì cũng ktra stock
    if (docRef == null) {
      if (quantityToAdd > stock) {
        throw Exception('Sản phẩm chỉ còn $stock cái trong kho thôi nha ><');
      }

      await _db.collection('carts').add({
        'userId': userId,
        'cartItems': [itemToAdd],
        'createdAt': FieldValue.serverTimestamp(),
        'cartUpdatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data() as Map<String, dynamic>;

      final rawCartItems = data['cartItems'];
      final cartItems =
          rawCartItems is List
              ? List<Map<String, dynamic>>.from(rawCartItems)
              : <Map<String, dynamic>>[];

      bool itemFound = false;
      int quantityInCart = 0;

      for (var item in cartItems) {
        if (item['productId'] == itemToAdd['productId'] &&
            item['selectedImageUrl'] == itemToAdd['selectedImageUrl']) {
          quantityInCart = item['quantity'] ?? 0;
          final int totalQuantity = quantityInCart + quantityToAdd;
          if (totalQuantity > stock) {
            throw Exception('Sản phẩm chỉ còn $stock cái trong kho thui.');
          }
          item['quantity'] = totalQuantity;
          itemFound = true;
          break;
        }
      }

      // Nếu sp chưa có trong giỏ
      if (!itemFound) {
        if (quantityToAdd > stock) {
          throw Exception('Sản phẩm chỉ còn $stock cái trong kho hoy.');
        }
        cartItems.add(itemToAdd);
      }

      await docRef.update({
        'cartItems': cartItems,
        'cartUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    Map<String, dynamic> itemToUpdate,
    int newQuantity,
  ) async {
    final docRef = await _getUserCartDocRef(userId);

    if (docRef == null) {
      return;
    }

    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>;

    final rawCartItems = data['cartItems'];
    final cartItems =
        rawCartItems is List
            ? List<Map<String, dynamic>>.from(rawCartItems)
            : <Map<String, dynamic>>[];

    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == itemToUpdate['productId'] &&
          cartItems[i]['selectedImageUrl'] ==
              itemToUpdate['selectedImageUrl']) {
        cartItems[i]['quantity'] = newQuantity;
        break;
      }
    }

    await docRef.update({
      'cartItems': cartItems,
      'cartUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
