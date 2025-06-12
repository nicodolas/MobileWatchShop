import 'package:ahtshopdongho/widgets/order_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveredOrdersScreen extends StatelessWidget {
  const DeliveredOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập.')));
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 242, 240, 240)),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: currentUser.uid)
                .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đơn hàng.'));
          }

          final allOrders = orderSnapshot.data!.docs;

          // Lấy danh sách returnRequests của user
          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('returnRequests')
                    .where('userId', isEqualTo: currentUser.uid)
                    .snapshots(),
            builder: (context, returnSnapshot) {
              if (returnSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final returnOrderIds =
                  returnSnapshot.hasData
                      ? returnSnapshot.data!.docs
                          .map((doc) => doc['orderId'] as String)
                          .toSet()
                      : <String>{};

              //  Lọc đơn hợp lệ: đã giao, đã trả (hoàn tiền), hoặc đang yêu cầu trả
              final filteredOrders =
                  allOrders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['orderStatus'];
                    final paymentStatus = data['paymentStatus'] ?? '';
                    final orderId = data['orderId'];

                    final isDelivered = status == 'Đã giao';
                    final isReturnedAndRefunded =
                        status == 'Đã trả' &&
                        paymentStatus.trim() == 'Đã hoàn tiền';
                    final isReturnRequested = returnOrderIds.contains(orderId);

                    return isDelivered ||
                        isReturnedAndRefunded ||
                        isReturnRequested;
                  }).toList();

              if (filteredOrders.isEmpty) {
                return const Center(child: Text('Không có đơn hàng phù hợp.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final orderData =
                      filteredOrders[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: OrderCard(orderData: orderData),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
