import 'package:ahtshopdongho/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String userId;
  final List<Product> products;
  final String status; // ví dụ: 'pending', 'shipped', 'delivered'
  final Timestamp createdAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      products:
          (json['products'] as List<dynamic>)
              .map((item) => Product.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'status': status,
      'createdAt': createdAt,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
