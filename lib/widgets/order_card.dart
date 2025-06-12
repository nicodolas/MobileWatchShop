//import 'package:ahtshopdongho/screens/returned_orders_screen.dart';
import 'package:ahtshopdongho/screens/return_request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final bool fromShippingScreen;

  const OrderCard({
    super.key,
    required this.orderData,
    this.fromShippingScreen = false,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String? returnRequestStatus; // Trạng thái yêu cầu trả hàng
  bool showAllItems = false;

  @override
  void initState() {
    super.initState();
    fetchReturnRequestStatus(); // Gọi khi load card
  }

  void fetchReturnRequestStatus() async {
    final orderId = widget.orderData['orderId'];
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('returnRequests')
            .where('orderId', isEqualTo: orderId)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      setState(() {
        returnRequestStatus = data['status'] ?? 'Chờ xác nhận';
      });
    }
  }

  Future<void> createInvoiceFromOrder(Map<String, dynamic> orderData) async {
    final invoiceData = {
      'invoiceDate': DateTime.now(),
      'invoiceId': '',
      'invoiceItems': orderData['orderItems'],
      'invoiceShippingAddress': orderData['orderShippingAddress'],
      'invoiceStatus': "Đã thanh toán",
      'invoiceTotalAmount': orderData['orderTotalAmount'],
      'orderId': orderData['orderId'],
      'paymentMethodId': orderData['paymentMethodId'],
      'userId': orderData['userId'],
    };

    final invoiceRef = await FirebaseFirestore.instance
        .collection('invoices')
        .add(invoiceData);

    await invoiceRef.update({'invoiceId': invoiceRef.id});
  }

  @override
  Widget build(BuildContext context) {
    final List items = widget.orderData['orderItems'];
    final orderDate = (widget.orderData['orderDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(orderDate);
    final String orderStatus = widget.orderData['orderStatus'] ?? '';
    final String paymentStatus = widget.orderData['paymentStatus'] ?? '';
    final bool isPaid = paymentStatus.toLowerCase() == 'Đã thanh toán';
    final displayedItems = showAllItems ? items : items.take(1).toList();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Trạng thái trả hàng + Trạng thái đơn hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                returnRequestStatus != null
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        //
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Trả hàng: $returnRequestStatus',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                    : const SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      orderStatus,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 216, 39, 39),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 164, 101, 101),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Danh sách sản phẩm
            ...displayedItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['selectedImageUrl'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Màu: ${item['selectedColor']}'),
                          Text('x${item['quantity']}'),
                        ],
                      ),
                    ),
                    // Giá
                    Text('${item['amount']}đ'),
                  ],
                ),
              );
            }).toList(),

            if (items.length > 1)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAllItems = !showAllItems;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAllItems ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 42, 43, 44),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      showAllItems
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color.fromARGB(255, 93, 95, 97),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Đã hoàn tiền
            if (orderStatus.toLowerCase() == 'đã hủy' && isPaid)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.info, color: Colors.red, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Đã hoàn tiền',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Tổng tiền
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tổng số tiền (${items.length} sản phẩm): ${widget.orderData['orderTotalAmount']}đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            // Nút chức năng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isPaid && !widget.fromShippingScreen)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ReturnRequestScreen(
                                orderData: widget.orderData,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 30, 29, 29),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color.fromARGB(255, 39, 39, 39),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Trả hàng / Hoàn tiền'),
                  ),

                if (widget.fromShippingScreen && orderStatus == 'Đang giao')
                  ElevatedButton(
                    onPressed: () async {
                      final orderId = widget.orderData['orderId'];
                      final orderData = widget.orderData;
                      try {
                        // Cập nhật trạng thái đơn
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .update({
                              'orderStatus': 'Đã giao',
                              'paymentStatus': 'Đã thanh toán',
                            });

                        print('Order data: $orderData');

                        // Tạo hóa đơn
                        final invoiceData = {
                          'invoiceDate': DateTime.now(),
                          'invoiceId': '',
                          'invoiceItems': orderData['orderItems'],
                          'invoiceShippingAddress':
                              orderData['orderShippingAddress'],
                          'invoiceStatus': "Đã thanh toán",
                          'invoiceTotalAmount': orderData['orderTotalAmount'],
                          'orderId': orderId,
                          'paymentMethodId': orderData['paymentMethodId'],
                          'userId': orderData['userId'],
                        };

                        final invoiceRef = await FirebaseFirestore.instance
                            .collection('invoices')
                            .add(invoiceData);

                        // Ghi invoiceId vào chính cái document đó
                        await invoiceRef.update({'invoiceId': invoiceRef.id});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật trạng thái đơn hàng.'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lỗi khi cập nhật đơn hàng.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 30, 29, 29),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Đã nhận hàng'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
