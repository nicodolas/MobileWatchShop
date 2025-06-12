import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceService {
  Future<void> createInvoice(Order order) async {
    final invoiceRef = FirebaseFirestore.instance.collection('invoices').doc();

    final invoiceData = {
      'invoiceId': invoiceRef.id,
      'orderId': order.orderId,
      'userId': order.userId,
      'amount': order.orderTotalAmount,
      'invoiceDate': Timestamp.now(),
      'items': order.orderItems, // giữ nguyên cấu trúc mảng
      'paymentMethodId': order.paymentMethodId,
    };

    await invoiceRef.set(invoiceData);
  }
}

class Order {
  final String orderId;
  final String userId;
  final int orderTotalAmount;
  final List<dynamic> orderItems;
  final String paymentMethodId;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderTotalAmount,
    required this.orderItems,
    required this.paymentMethodId,
  });

  // Factory để tạo Order từ map (Firestore)
  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      orderId: data['orderId'],
      userId: data['userId'],
      orderTotalAmount: data['orderTotalAmount'],
      orderItems: data['orderItems'] ?? [],
      paymentMethodId: data['paymentMethodId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'orderTotalAmount': orderTotalAmount,
      'orderItems': orderItems,
      'paymentMethodId': paymentMethodId,
    };
  }
}
