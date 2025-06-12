import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnRequestScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const ReturnRequestScreen({super.key, required this.orderData});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();

  final List<String> reasons = [
    'Hàng bị lỗi',
    'Giao sai sản phẩm',
    'Không giống mô tả',
    'Thiếu hàng',
    'Lý do khác',
  ];

  // Chỉ số các sản phẩm được chọn để trả hàng
  final Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    final orderItems = widget.orderData['orderItems'] as List<dynamic>;
    final orderDate = (widget.orderData['orderDate']).toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Yêu cầu trả hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã đơn hàng: ${widget.orderData['orderId']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Ngày đặt: $formattedDate',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const Text(
              'Chọn sản phẩm muốn trả:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];
                final isSelected = selectedIndexes.contains(index);

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedIndexes.add(index);
                        } else {
                          selectedIndexes.remove(index);
                        }
                      });
                    },
                    title: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item['selectedImageUrl'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Màu: ${item['selectedColor']}'),
                              Text('Số lượng: ${item['quantity']}'),
                              Text('Giá: ${item['amount']}đ'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Chọn lý do trả hàng:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            // Radio lựa chọn lý do trả hàng
            ...reasons.map((reason) {
              return RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                title: Text(reason),
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
              );
            }).toList(),

            if (selectedReason == 'Lý do khác') ...[
              const SizedBox(height: 10),
              const Text('Vui lòng nhập lý do cụ thể:'),
              const SizedBox(height: 6),
              TextField(
                controller: otherReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final reason =
                      selectedReason == 'Lý do khác'
                          ? otherReasonController.text.trim()
                          : selectedReason;

                  if (reason == null || reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng chọn hoặc nhập lý do trả hàng.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (selectedIndexes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng chọn ít nhất một sản phẩm để trả.',
                        ),
                      ),
                    );
                    return;
                  }

                  final selectedItems =
                      orderItems
                          .asMap()
                          .entries
                          .where((entry) => selectedIndexes.contains(entry.key))
                          .map((entry) => entry.value)
                          .toList();

                  final orderId = widget.orderData['orderId'];

                  // Tạo document mới cho return request với returnId riêng
                  final returnDocRef =
                      FirebaseFirestore.instance
                          .collection('returnRequests')
                          .doc();

                  final returnId = returnDocRef.id;

                  // Lưu yêu cầu trả hàng vào Firestore
                  await returnDocRef.set({
                    'returnId': returnId,
                    'orderId': orderId,
                    'userId': widget.orderData['userId'],
                    'requestDate': Timestamp.now(),
                    'returnItems': selectedItems,
                    'reason': reason,
                    'status': 'Chờ xác nhận',
                  });

                  // Cập nhật trạng thái trả hàng vào đơn hàng
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .update({
                        'returnItems': selectedItems,
                        'returnStatus': 'Chờ xác nhận',
                      });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi yêu cầu trả hàng')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Gửi yêu cầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
