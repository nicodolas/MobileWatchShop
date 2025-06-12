import 'package:ahtshopdongho/widgets/order_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShippingOrdersScreen extends StatelessWidget {
  const ShippingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn đang giao'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: currentUser.uid)
                .where('orderStatus', isEqualTo: 'Đang giao')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đơn hàng đang giao.'));
          }

          final shippingOrders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: shippingOrders.length,
            itemBuilder: (context, index) {
              final orderData =
                  shippingOrders[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: OrderCard(
                  orderData: orderData,
                  fromShippingScreen: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
