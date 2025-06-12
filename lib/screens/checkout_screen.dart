import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ahtshopdongho/screens/cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/models/shipping_address_model.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/services/brand_service.dart';
import 'package:ahtshopdongho/widgets/cart_item_card_widget.dart';
import 'package:ahtshopdongho/screens/address_section_screen.dart';
import 'package:ahtshopdongho/services/user_service.dart';
import 'package:ahtshopdongho/services/cart_service.dart';
import 'package:ahtshopdongho/payments/momo_payment_service.dart';
import 'package:ahtshopdongho/payments/momo_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final AppUser user;
  final String categoryName;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.user,
    required this.categoryName,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPayment = 'Momo';
  final CartService _cartService = CartService();
  // final BrandService _brandService = BrandService();
  // final MomoPaymentService _momoPaymentService = MomoPaymentService();
  Set<String> selectedProduct = {};
  Set<String> selectedProductKeys = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final userService = UserService();
  String street = '';
  String ward = '';
  String district = '';
  String province = '';
  ShippingAddress? _shippingAddress;
  bool _flag = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final address = await userService.getUserAddress(widget.user.userId);
    if (address != null) {
      setState(() {
        _shippingAddress = address;
      });
    }
  }

  //Lưu đơn
  Future<void> placeOrder() async {
    if (_shippingAddress == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập địa chỉ giao hàng!')));
      return;
    }

    final totalAmount = widget.cartItems.fold<int>(
      0,
      (sum, item) =>
          sum + (item['productPrice'] as int) * (item['quantity'] as int),
    );

    final paymentMethodSnapshot =
        await FirebaseFirestore.instance
            .collection('paymentMethods')
            .where(
              'name',
              isEqualTo: selectedPayment == 'Tiền mặt' ? 'Tiền mặt' : 'Momo',
            )
            .limit(1)
            .get();

    if (paymentMethodSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phương thức thanh toán không hợp lệ')),
      );
      return;
    }

    final paymentMethodDoc = paymentMethodSnapshot.docs.first;
    final paymentMethodId = paymentMethodDoc.id;

    final paymentStatus =
        selectedPayment == 'Momo' ? 'Đã thanh toán' : 'Chưa thanh toán';

    final orderItems =
        widget.cartItems.map((item) {
          final price = item['productPrice'] as int;
          final quantity = item['quantity'] as int;
          return {
            'price': price,
            'productId': item['productId'],
            'productName': item['productName'],
            'quantity': quantity,
            'selectedColor': item['selectedColor'] ?? '',
            'selectedImageUrl': item['selectedImageUrl'] ?? '',
            'amount': price * quantity,
          };
        }).toList();

    final orderData = {
      'orderDate': Timestamp.now(),
      'orderStatus': 'Đang giao',
      'orderTotalAmount': totalAmount,
      'paymentMethodId': paymentMethodId,
      'paymentStatus': paymentStatus,
      'userId': widget.user.userId,
      'orderShippingAddress': {
        'province': _shippingAddress!.province,
        'district': _shippingAddress!.district,
        'ward': _shippingAddress!.ward,
        'street': _shippingAddress!.street,
      },
      'orderItems': orderItems,
      'returnStatus': '',
    };

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData);
      // orderId = documentId
      await docRef.update({'orderId': docRef.id});

      final userId = FirebaseAuth.instance.currentUser?.uid;

      final cartCollection = FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .collection('items');

      final cartItems = await cartCollection.get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt hàng thành công')));

      // Có thể xóa giỏ hàng hoặc điều hướng màn hình khác tại đây
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi đặt hàng: $e')));
    }
  }

  Future<String?> getPaymentMethodId(String methodName) async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('paymentMethods')
            .where('paymentMethodName', isEqualTo: methodName)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docData = querySnapshot.docs.first.data();
      return docData['paymentMethodId'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cartItems;

    final int total = cartItems.fold(0, (sum, item) {
      return sum + (item['productPrice'] as int) * (item['quantity'] as int);
    });

    return Scaffold(
      appBar: HomeAppBar(),
      drawer: HomeDrawerWidget(
        categoryName: widget.categoryName,
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin giao hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Họ tên",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Địa chỉ giao hàng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final updatedAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AddressScreen(
                                initialAddress: _shippingAddress,
                                userId: widget.user.userId,
                              ),
                        ),
                      );

                      if (updatedAddress != null &&
                          updatedAddress is ShippingAddress) {
                        setState(() {
                          _shippingAddress = updatedAddress;
                        });
                      }
                    },
                    child: Text(
                      _shippingAddress?.fullAddress ?? 'Thêm địa chỉ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Sản phẩm đã chọn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Column(
              children:
                  cartItems.map((item) {
                    return CartItemCard(
                      item: item,
                      quantity: item['quantity'] ?? 1,
                      showCheckbox: false,
                      showDelete: false,
                      getBrandName:
                          () => BrandService.getBrandNameForCartItem(
                            item['productId'],
                          ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            const Text(
              "Phương thức thanh toán",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _buildPaymentOption('Momo', Icons.qr_code),
                const SizedBox(width: 12),
                _buildPaymentOption('Tiền mặt', Icons.money),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng cộng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} ₫',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  if (name.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập đầy đủ thông tin!'),
                      ),
                    );
                    return;
                  }
                  if (_shippingAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng chọn địa chỉ giao hàng'),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _flag = true;
                  });

                  final paymentMethodName =
                      selectedPayment == 'Tiền mặt' ? 'Tiền mặt' : 'Momo';

                  if (selectedPayment == 'Momo') {
                    final momoResponse = await MomoPaymentService()
                        .createMomoPayment(total);
                    final qrUrl = momoResponse?['payUrl'];

                    if (qrUrl != null) {
                      setState(() {
                        _flag = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MomoPaymentScreen(
                                qrUrl: qrUrl,
                                timeout: const Duration(minutes: 10),
                              ),
                        ),
                      );
                      return;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể tạo mã QR Momo'),
                        ),
                      );
                      return;
                    }
                  }

                  final paymentMethodId = await getPaymentMethodId(
                    paymentMethodName,
                  );

                  final orderData = {
                    'orderDate': DateTime.now(),
                    'orderStatus': 'Đang giao',
                    'orderTotalAmount': total,
                    'paymentMethodId': paymentMethodId,
                    'paymentStatus':
                        paymentMethodName == 'Momo'
                            ? 'Đã thanh toán'
                            : 'Chưa thanh toán',
                    'userId': widget.user.userId,
                    'orderShippingAddress': {
                      'province': _shippingAddress!.province,
                      'district': _shippingAddress!.district,
                      'ward': _shippingAddress!.ward,
                      'street': _shippingAddress!.street,
                    },
                    'orderItems':
                        widget.cartItems.map((item) {
                          final price = item['productPrice'] as int;
                          final quantity = item['quantity'] as int;
                          return {
                            'productId': item['productId'],
                            'productName': item['productName'],
                            'price': price,
                            'quantity': quantity,
                            'selectedColor': item['selectedColor'],
                            'selectedImageUrl': item['selectedImageUrl'],
                            'amount': price * quantity,
                          };
                        }).toList(),
                    'returnStatus': '',
                  };

                  // Tạo đơn xong
                  final docRef = await FirebaseFirestore.instance
                      .collection('orders')
                      .add(orderData);

                  await docRef.update({
                    'orderId': docRef.id,
                  }); // cập nhật orderId = doc id

                  // Trừ stock
                  for (final item in widget.cartItems) {
                    final productId = item['productId'];
                    final selectedImageUrl = item['selectedImageUrl'];
                    final quantity = item['quantity'];

                    final productRef = FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId);

                    await FirebaseFirestore.instance.runTransaction((
                      transaction,
                    ) async {
                      final snapshot = await transaction.get(productRef);
                      if (!snapshot.exists) return;

                      final data = snapshot.data()!;
                      final colorOptions = List<Map<String, dynamic>>.from(
                        data['colorOptions'] ?? [],
                      );

                      final updatedColorOptions =
                          colorOptions.map((option) {
                            if (option['imageUrl'] == selectedImageUrl) {
                              final currentStock = option['stock'] ?? 0;
                              return {
                                ...option,
                                'stock': (currentStock - quantity).clamp(
                                  0,
                                  currentStock,
                                ),
                              };
                            }
                            return option;
                          }).toList();

                      transaction.update(productRef, {
                        'colorOptions': updatedColorOptions,
                      });
                    });
                  }

                  for (final item in widget.cartItems) {
                    await _cartService.removeFromCart(widget.user.userId, item);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Đặt hàng thành công\nAHTShop cảm ơn sự ủng hộ của bạn!",
                            ),
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 1), // Hiển thị 1s
                    ),
                  );

                  // 1s sau chuyển hướng
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CartScreen(
                              user: widget.user,
                              categoryName: widget.categoryName,
                            ),
                      ),
                    );
                  });
                },
                child: const Text(
                  "Đặt Hàng",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon) {
    final isSelected = selectedPayment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPayment = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
