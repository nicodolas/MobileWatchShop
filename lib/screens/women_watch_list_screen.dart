import 'package:flutter/material.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/models/product_model.dart';
import 'package:ahtshopdongho/services/product_service.dart';
import 'product_detail_screen.dart';
import 'package:ahtshopdongho/widgets/product_card_widget.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_bottom_navigation_bar_widget.dart';
import 'package:ahtshopdongho/widgets/breadcrumb_widget.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/cart_screen.dart';
import 'package:ahtshopdongho/screens/profile_screen.dart';
import 'package:ahtshopdongho/widgets/common_filter_button_widget.dart';
import 'package:ahtshopdongho/widgets/price_sort_widget.dart';
import 'package:ahtshopdongho/utils/product_sort_utils.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/screens/product_search_screen.dart';

class WomenWatchListScreen extends StatefulWidget {
  final String categoryName;
  final List<String> selectedBrands;
  final RangeValues selectedPriceRange;
  final AppUser user;

  const WomenWatchListScreen({
    super.key,
    required this.categoryName,
    required this.selectedBrands,
    required this.selectedPriceRange,
    required this.user,
  });

  @override
  _WomenWatchListScreenState createState() => _WomenWatchListScreenState();
}

class _WomenWatchListScreenState extends State<WomenWatchListScreen> {
  final ProductService _productService = ProductService();
  final String _womenWatchCategoryId = 'Z98iv9rceZkKC020qPXa';
  PriceSortOption? selectedSortOption;
  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];

  int _currentIndex = 0;
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
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
        Navigator.push(
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
    // Đây là dòng code bạn đã dùng để sắp xếp
    _displayedProducts = sortProductsByPrice(_allProducts, selectedSortOption);
    // THÊM DÒNG NÀY ĐỂ BUỘC UI CẬP NHẬT
    // Chỉ thêm dòng này nếu bạn đang debug và muốn đảm bảo setState được gọi.
    // Trong trường hợp lý tưởng, nó nên được gọi bởi hàm cha (onSelected, loadProducts).
    if (mounted) {
      // Chỉ gọi setState nếu widget còn tồn tại
      setState(() {});
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
      body: FutureBuilder<List<Product>>(
        future: _productService.getProductsByCategory(
          _womenWatchCategoryId,
          widget.selectedBrands,
          widget.selectedPriceRange,
        ), // Gọi service
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final products =
                snapshot.data!
                    .where((product) => product.productStatus != "Ngừng bán")
                    .toList();
            if (products.isEmpty) {
              return const Center(
                child: Text('Không có sản phẩm nào trong danh mục này.'),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                Breadcrumb(
                  items: [
                    BreadcrumbItem(
                      title: 'Trang chủ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => HomeScreen(
                                  categoryName: widget.categoryName,
                                  user: widget.user,
                                ),
                          ),
                        );
                      },
                    ),
                    BreadcrumbItem(
                      title: widget.categoryName,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => WomenWatchListScreen(
                                  categoryName: "Đồng hồ nữ",
                                  selectedBrands: [],
                                  selectedPriceRange: RangeValues(0, 200000),
                                  user: widget.user,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Center(
                    child: Text(
                      'Đồng hồ nữ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                              //barrierColor: Colors.black.withOpacity(0.5),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
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
                  physics:
                      const NeverScrollableScrollPhysics(), // Để GridView không cuộn riêng
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  productId: product.productId,
                                  categoryName: "Đồng hồ nữ",
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
            return const Center(child: Text('Không có dữ liệu.'));
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
