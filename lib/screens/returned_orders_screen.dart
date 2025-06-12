import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/models/return_order_model.dart';

class ReturnedOrdersScreen extends StatefulWidget {
  const ReturnedOrdersScreen({super.key});

  @override
  _ReturnedOrdersScreenState createState() => _ReturnedOrdersScreenState();
}

class _ReturnedOrdersScreenState extends State<ReturnedOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Đơn hàng đã trả"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi xảy ra"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          final returnedOrders =
              allDocs.where((doc) {
                final returnStatus = doc['returnStatus']?.toString().trim();
                return returnStatus == 'Đã trả';
              }).toList();

          if (returnedOrders.isEmpty) {
            return const Center(
              child: Text(
                "Không có đơn hàng nào đã trả",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: returnedOrders.length,
            itemBuilder: (context, index) {
              final doc = returnedOrders[index];
              final orderId = doc['orderId'];
              final totalAmount = doc['orderTotalAmount'];
              final returnItems = doc['returnItems'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    "Mã đơn: $orderId",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Tổng tiền: ${totalAmount.toString()}đ",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  children:
                      returnItems.map((item) {
                        final mapItem = item as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  mapItem['selectedImageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 60,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mapItem['productName'] ?? "Không rõ tên",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Màu: ${mapItem['selectedColor']}  |  SL: ${mapItem['quantity']}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "Giá: ${mapItem['price']}đ",
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
