import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ahtshopdongho/screens/login.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/models/product_model.dart';
import 'package:ahtshopdongho/screens/edit_profile.dart';
import 'package:ahtshopdongho/screens/login.dart';
import 'package:ahtshopdongho/services/user_service.dart';
import 'package:ahtshopdongho/services/product_service.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/cart_screen.dart';
import 'package:ahtshopdongho/screens/oder_empty_screen.dart';
import 'package:ahtshopdongho/screens/product_search_screen.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/screens/returned_orders_screen.dart';
import 'package:ahtshopdongho/screens/shipping_order_screen.dart';
import 'package:ahtshopdongho/screens/delivered_orders_screen.dart';
import 'package:ahtshopdongho/widgets/home_bottom_navigation_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final String categoryName;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.categoryName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final PageController pageController = PageController();

  int _currentIndex = 3;

  // @override
  // void initState() {
  //   super.initState();
  // }

  // Future<void> loadProducts() async {
  //   final products = await _productService.getAllProducts();
  //   setState(() {
  //     _allProducts =
  //         products
  //             .where((product) => product.productStatus != "Ngừng bán")
  //             .toList();
  //   });
  // }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Đồng ý'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => LoginPage(pageController: pageController),
            ),
            (route) => false,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công')));
        }
      } catch (e) {
        debugPrint('Lỗi logout: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
      }
    }
  }

  Widget _buildOrderItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget targetScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    final pages = [
      HomeScreen(categoryName: widget.categoryName, user: widget.user),
      ProductSearchScreen(categoryName: widget.categoryName, user: widget.user),
      CartScreen(categoryName: widget.categoryName, user: widget.user),
      ProfileScreen(categoryName: widget.categoryName, user: widget.user),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      drawer: HomeDrawerWidget(
        categoryName: widget.categoryName,
        user: widget.user,
      ),
      body: FutureBuilder<List<List<Product>>>(
        future: Future.wait([
          _productService.getAllProducts(),
          _productService.getTopSellingProducts(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải sản phẩm: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu sản phẩm'));
          }

          // final topSellingProducts =
          //     snapshot.data![1]
          //         .where((product) => product.productStatus != "Ngừng bán")
          //         .toList();

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _userService.getUserData(widget.user.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text("Lỗi tải thông tin người dùng"),
                    );
                  }

                  final userData = snapshot.data!;
                  final userAvatarUrl = userData['userAvatarUrl'] ?? '';
                  final userName = userData['userName'] ?? '';
                  final userId = widget.user.userId;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(userId: userId),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.yellow[700],
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                userAvatarUrl.isNotEmpty
                                    ? NetworkImage(userAvatarUrl)
                                    : null,
                            child:
                                userAvatarUrl.isEmpty
                                    ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.black,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'ID: ${userId.substring(0, 6)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => const OrderEmptyScreen(initialTabIndex: 0),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Đơn hàng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Xem tất cả đơn hàng",
                            style: TextStyle(color: Colors.blue),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOrderItem(
                      context,
                      Icons.local_shipping,
                      'Đang giao',
                      const ShippingOrdersScreen(),
                    ),
                    _buildOrderItem(
                      context,
                      Icons.check_circle_outline,
                      'Đã giao',
                      const DeliveredOrdersScreen(),
                    ),
                    _buildOrderItem(
                      context,
                      Icons.replay_circle_filled,
                      'Đã trả',
                      const ReturnedOrdersScreen(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.logout, color: Colors.black, size: 28),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Xác nhận đăng xuất'),
                              content: const Text(
                                'Bạn có chắc chắn muốn đăng xuất?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Đăng xuất'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (_) => LoginPage(
                                  pageController: PageController(
                                    initialPage: 0,
                                  ),
                                  initialEmail: null,
                                ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
