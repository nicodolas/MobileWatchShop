import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_bottom_navigation_bar_widget.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/services/cart_service.dart';
import 'package:ahtshopdongho/services/brand_service.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/widgets/cart_item_card_widget.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/product_search_screen.dart';
import 'package:ahtshopdongho/screens/profile_screen.dart';
import 'package:ahtshopdongho/screens/checkout_screen.dart';
import 'package:ahtshopdongho/utils/currency_formatter.dart';

class CartScreen extends StatefulWidget {
  final AppUser user;
  final String categoryName;

  const CartScreen({super.key, required this.user, required this.categoryName});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 2;
  final CartService _cartService = CartService();
  //final BrandService _brandService = BrandService();
  Set<String> selectedProduct = {};
  Set<String> selectedProductKeys = {};

  // Tạo một identifier cho mỗi item (ghép productId và color)
  String getItemKey(Map<String, dynamic> item) {
    return '${item['productId']}_${item['selectedColor']}';
  }

  double total = 0.0;
  int selectedTotalQuantity = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomeScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductSearchScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CartScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
                  user: widget.user,
                  categoryName: widget.categoryName,
                ),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      drawer: HomeDrawerWidget(
        categoryName: widget.categoryName,
        user: widget.user,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cartService.streamUserCart(widget.user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          // Nếu không có document nào trong kết quả truy vấn
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyCart();
          }

          // Lấy document đầu tiên từ kết quả truy vấn (vì dùng limit(1))
          final doc = snapshot.data!.docs.first;
          var cartData =
              doc.data() as Map<String, dynamic>; // Lấy dữ liệu từ document đó

          if (cartData.isEmpty) {
            return _buildEmptyCart();
          }

          List<dynamic> cartItems = cartData["cartItems"] ?? [];

          return cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartWithItems(cartItems);
        },
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Ôi không, giỏ hàng của bạn đang trống!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Khi bạn thêm sản phẩm, chúng sẽ xuất hiện ở đây.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(List<dynamic> cartItems) {
    int selectedTotalQuantity = cartItems
        .where((item) => selectedProductKeys.contains(getItemKey(item)))
        .fold(0, (sum, item) => sum + (item['quantity'] ?? 0) as int);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            // Tránh nhảy lên đầu màn hình
            key: const PageStorageKey<String>('cart_list_view'),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              final itemKey = getItemKey(item);
              final quantity = item['quantity'] ?? 1;

              return CartItemCard(
                item: item,
                quantity: quantity,
                showCheckbox: true,
                isSelected: selectedProductKeys.contains(itemKey),
                showDelete: true,
                onCheckboxChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedProductKeys.add(itemKey);
                    } else {
                      selectedProductKeys.remove(itemKey);
                    }

                    total = cartItems
                        .where(
                          (item) =>
                              selectedProductKeys.contains(getItemKey(item)),
                        )
                        .fold(0.0, (sum, item) {
                          final price = item['productPrice'] ?? 0;
                          final quantity = item['quantity'] ?? 0;
                          return sum + (price * quantity);
                        });
                  });
                },
                onDelete:
                    () => _cartService.removeFromCart(widget.user.userId, item),
                // onIncrease:
                //     () => _cartService.updateCartItemQuantity(
                //       widget.user.userId,
                //       item,
                //       quantity + 1,
                //     ),
                onIncrease: () async {
                  final productId = item['productId'];
                  final selectedColor = item['selectedColor'];
                  final selectedImageUrl = item['selectedImageUrl'];

                  final productSnapshot =
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(productId)
                          .get();

                  if (!productSnapshot.exists) return;

                  final productData = productSnapshot.data()!;
                  final List<dynamic> colorOptions =
                      productData['colorOptions'] ?? [];

                  final selectedOption = colorOptions.firstWhere(
                    (opt) =>
                        opt['color'] == selectedColor &&
                        opt['imageUrl'] == selectedImageUrl,
                    orElse: () => null,
                  );

                  final int stock = selectedOption['stock'] ?? 0;

                  if ((item['quantity'] ?? 0) + 1 > stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sản phẩm chỉ còn lại $stock chiếc trong kho hoy ><',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                    return;
                  }

                  // OK => tăng số lượng
                  await _cartService.updateCartItemQuantity(
                    widget.user.userId,
                    item,
                    (item['quantity'] ?? 0) + 1,
                  );
                },

                onDecrease: () async {
                  if (quantity > 1) {
                    await _cartService.updateCartItemQuantity(
                      widget.user.userId,
                      item,
                      quantity - 1,
                    );
                  } else {
                    await _cartService.removeFromCart(widget.user.userId, item);
                  }
                },
                getBrandName:
                    () =>
                        BrandService.getBrandNameForCartItem(item['productId']),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              Checkbox(
                value:
                    cartItems.isNotEmpty &&
                    cartItems.every(
                      (item) => selectedProductKeys.contains(getItemKey(item)),
                    ),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedProductKeys = {
                        for (var item in cartItems) getItemKey(item),
                      };
                    } else {
                      selectedProductKeys.clear();
                    }

                    // Tính lại total
                    total = cartItems
                        .where(
                          (item) =>
                              selectedProductKeys.contains(getItemKey(item)),
                        )
                        .fold(0, (sum, item) {
                          final price = item['productPrice'] ?? 0;
                          final quantity = item['quantity'] ?? 0;
                          return sum + (price * quantity);
                        });
                  });
                },
              ),

              const Text('Tất cả'),
              const Spacer(),
              //Tổng tiền
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    CurrencyFormatter.formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final List<Map<String, dynamic>> selectedItems =
                      cartItems
                          .where((item) {
                            final itemKey = getItemKey(item);
                            return selectedProductKeys.contains(itemKey);
                          })
                          .map((e) => e as Map<String, dynamic>)
                          .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(
                            cartItems: selectedItems,
                            user: widget.user,
                            categoryName: widget.categoryName,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedProductKeys.isEmpty ? Colors.grey : Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Thanh Toán ($selectedTotalQuantity)',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
