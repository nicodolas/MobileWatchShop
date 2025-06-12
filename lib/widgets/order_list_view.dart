import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderListView extends StatelessWidget {
  final String? status; // null = tất cả

  const OrderListView({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Bạn chưa đăng nhập.'));
    }

    // Query Firestore
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('Không có đơn hàng.'));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final order = docs[index].data();
            final createdAt = order['createdAt']?.toDate();

            return ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('Tổng tiền: ${order['total']} đ'),
              subtitle: Text('Trạng thái: ${order['status']}'),
              trailing: Text(
                createdAt != null
                    ? '${createdAt.day}/${createdAt.month} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                    : '',
              ),
              onTap: () {
                // TODO: Mở trang chi tiết đơn hàng nếu muốn
              },
            );
          },
        );
      },
    );
  }
}
