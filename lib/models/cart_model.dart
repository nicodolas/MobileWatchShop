import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String productName;
  final int productPrice;
  final int quantity;
  final String selectedColor;
  final String selectedImageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.selectedColor,
    required this.selectedImageUrl,
  });

  factory CartItem.fromMap(Map<dynamic, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: map['productPrice'] ?? 0,
      quantity: map['quantity'] ?? 0,
      selectedColor: map['selectedColor'] ?? '',
      selectedImageUrl: map['selectedImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedImageUrl': selectedImageUrl,
    };
  }
}

class CartModel {
  final List<CartItem> cartItems;
  final DateTime cartUpdatedAt;
  final int totalQuantity;
  final String userId;

  CartModel({
    required this.cartItems,
    required this.cartUpdatedAt,
    required this.totalQuantity,
    required this.userId,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartItems: List<CartItem>.from(
        (map['cartItems'] as List<dynamic>).map(
          (item) => CartItem.fromMap(item as Map<dynamic, dynamic>),
        ),
      ),
      cartUpdatedAt: (map['cartUpdatedAt'] as Timestamp).toDate(),
      totalQuantity: map['totalQuantity'] ?? 0,
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItems': cartItems.map((item) => item.toMap()).toList(),
      'cartUpdatedAt': Timestamp.fromDate(cartUpdatedAt),
      'totalQuantity': totalQuantity,
      'userId': userId,
    };
  }
}
