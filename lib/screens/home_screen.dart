import 'package:flutter/material.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_bottom_navigation_bar_widget.dart';
import 'package:ahtshopdongho/services/product_service.dart';
import 'package:ahtshopdongho/models/product_model.dart';
import 'package:ahtshopdongho/widgets/product_card_widget.dart';
import 'package:ahtshopdongho/screens/product_detail_screen.dart';
import 'package:ahtshopdongho/screens/profile_screen.dart';
import 'package:ahtshopdongho/widgets/common_filter_button_widget.dart';
import 'package:ahtshopdongho/widgets/price_sort_widget.dart';
import 'package:ahtshopdongho/utils/product_sort_utils.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/screens/cart_screen.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/screens/product_search_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final String categoryName;

  const HomeScreen({super.key, required this.user, required this.categoryName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  PriceSortOption? selectedSortOption;
  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];

  int _currentIndex = 0;

  Future<void> loadProducts() async {
    final products = await _productService.getAllProducts();
    setState(() {
      _allProducts =
          products
              .where((product) => product.productStatus != "Ngừng bán")
              .toList();
      _applySorting();
    });
  }

  void _applySorting() {
    _displayedProducts = sortProductsByPrice(_allProducts, selectedSortOption);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
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
          } else if (snapshot.hasData) {
            final List<Product> topSellingProducts =
                snapshot.data![1]
                    .where((product) => product.productStatus != "Ngừng bán")
                    .toList();

            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                if (topSellingProducts.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      "SẢN PHẨM BÁN CHẠY",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final cardWidth = (screenWidth - 3 * 3) / 2;
                        final cardHeight = cardWidth / 0.7;

                        return Stack(
                          children: [
                            SizedBox(
                              height: cardHeight,
                              child: ListView.builder(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: topSellingProducts.length,
                                itemBuilder: (context, index) {
                                  final product = topSellingProducts[index];
                                  return SizedBox(
                                    width: cardWidth,
                                    child: ProductCard(
                                      product: product,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ProductDetailScreen(
                                                      productId:
                                                          product.productId,
                                                      categoryName: "",
                                                      categoryId:
                                                          product.categoryId,
                                                      user: widget.user,
                                                    ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Nút trái
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_left, size: 28),
                                  color: Colors.black54,
                                  onPressed: () {
                                    _scrollController.animateTo(
                                      (_scrollController.offset - 250).clamp(
                                        0.0,
                                        _scrollController
                                            .position
                                            .maxScrollExtent,
                                      ),
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Nút phải
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_right, size: 28),
                                  color: Colors.black54,
                                  onPressed: () {
                                    _scrollController.animateTo(
                                      (_scrollController.offset + 250).clamp(
                                        0.0,
                                        _scrollController
                                            .position
                                            .maxScrollExtent,
                                      ),
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Colors.black),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              builder: (context) {
                                final height =
                                    MediaQuery.of(context).size.height;
                                return SizedBox(
                                  height: height * 2 / 3,
                                  child: FilterBottomSheet(user: widget.user),
                                );
                              },
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text("Bộ lọc"), Icon(Icons.tune)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PriceSortButton(
                          selectedOption: selectedSortOption,
                          onSelected: (option) {
                            setState(() {
                              selectedSortOption = option;
                              _applySorting(); // sắp xếp lại danh sách sản phẩm
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _displayedProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  productId: product.productId,
                                  categoryName: "",
                                  categoryId: product.categoryId,
                                  user: widget.user,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(child: Text('Không có sản phẩm nào.'));
          }
        },
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
