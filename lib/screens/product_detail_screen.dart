import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/smart_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/men_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/women_watch_list_screen.dart';
import 'package:ahtshopdongho/services/brand_service.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ahtshopdongho/services/product_service.dart';
import 'package:ahtshopdongho/services/category_service.dart';
import 'package:ahtshopdongho/models/product_model.dart';
import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
import 'package:ahtshopdongho/widgets/breadcrumb_widget.dart';
import 'package:ahtshopdongho/widgets/product_option_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ahtshopdongho/utils/currency_formatter.dart';
import 'package:ahtshopdongho/widgets/return_policy_widget.dart';
import 'package:ahtshopdongho/widgets/product_question_widget.dart';
import 'package:ahtshopdongho/widgets/product_card_widget.dart';
import 'package:ahtshopdongho/models/user_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String categoryName;
  final String categoryId;
  final AppUser user;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.categoryName,
    required this.categoryId,
    required this.user,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  late Future<Product> _productFuture;
  late Future<List<Product>> _relatedFuture;
  String? brandName;
  int _currentImageIndex = 0; // Ảnh hiện tại trong carousel
  ScrollController _scrollController = ScrollController();
  List<Product> _allProducts = [];
  String categoryName = '';

  @override
  void dispose() {
    _scrollController.dispose(); // Giải phóng bộ nhớ
    super.dispose();
  }

  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);

    _productFuture.then((product) {
      _relatedFuture = fetchRelatedProducts(
        productId: widget.productId,
        categoryId: product.categoryId,
      );
    });

    loadBrandName();
    _loadAllProducts();
    _loadCategoryName();
  }

  Future<void> _loadAllProducts() async {
    final products = await _productService.getAllProducts();
    setState(() {
      _allProducts = products;
    });
  }

  Future<List<Product>> fetchRelatedProducts({
    required String productId,
    required String categoryId,
  }) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .get();

    final products =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return Product.fromJson(data);
        }).toList();

    // Bỏ sản phẩm hiện tại
    return products.where((product) => product.productId != productId).toList();
  }

  Future<void> _loadCategoryName() async {
    final productDoc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get();
    final categoryId = productDoc.data()?['categoryId'];

    if (categoryId != null) {
      final name = await _categoryService.getCategoryName(categoryId);
      setState(() {
        categoryName = name;
      });
    }
  }

  Future<void> loadBrandName() async {
    try {
      final product = await _productFuture;
      final name = await BrandService.getBrandName(product.brandId);
      setState(() {
        brandName = name ?? 'Không tìm thấy thương hiệu';
      });
    } catch (e) {
      debugPrint('Lỗi lấy brandName: $e');
      setState(() {
        brandName = 'Lỗi tải brandName';
      });
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
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            final List<Map<String, dynamic>> colorOptions =
                (product.toJson()['colorOptions'] as List<dynamic>?)
                    ?.map((item) => item as Map<String, dynamic>)
                    .toList() ??
                [];

            // Lấy all URL ảnh
            final List<String> allProductImages = [product.productImageUrl];
            for (var option in colorOptions) {
              final imageUrl = option['imageUrl'] as String?;
              if (imageUrl != null && imageUrl.isNotEmpty) {
                allProductImages.add(imageUrl);
              }
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      thickness: 6,

                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                if (widget.categoryName.trim().isNotEmpty)
                                  BreadcrumbItem(
                                    title: widget.categoryName,
                                    onTap: () {
                                      Widget targetScreen;
                                      switch (widget.categoryName) {
                                        case "Đồng hồ thông minh":
                                          targetScreen = SmartWatchListScreen(
                                            categoryName: widget.categoryName,
                                            selectedBrands: [],
                                            selectedPriceRange: RangeValues(
                                              0,
                                              200000,
                                            ),
                                            user: widget.user,
                                          );
                                          break;
                                        case "Đồng hồ nữ":
                                          targetScreen = WomenWatchListScreen(
                                            categoryName: widget.categoryName,
                                            selectedBrands: [],
                                            selectedPriceRange: RangeValues(
                                              0,
                                              200000,
                                            ),
                                            user: widget.user,
                                          );
                                          break;
                                        case "Đồng hồ nam":
                                          targetScreen = MenWatchListScreen(
                                            categoryName: widget.categoryName,
                                            selectedBrands: [],
                                            selectedPriceRange: RangeValues(
                                              0,
                                              200000,
                                            ),
                                            user: widget.user,
                                          );
                                          break;
                                        default:
                                          return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => targetScreen,
                                        ),
                                      );
                                    },
                                  ),
                                BreadcrumbItem(
                                  title: product.productName,
                                  onTap: null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Carousel ảnh
                            if (allProductImages.isNotEmpty)
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 200.0,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.8,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                ),
                                items:
                                    allProductImages.map((imageUrl) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Center(
                                                        child: Icon(
                                                          Icons.error,
                                                        ),
                                                      ),
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              ),
                            if (allProductImages.length > 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    allProductImages.asMap().entries.map((
                                      entry,
                                    ) {
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              _currentImageIndex == entry.key
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              product.productName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Thương hiệu: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  brandName ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Giá: ${CurrencyFormatter.formatCurrency(product.productPrice)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Container(
                            //   padding: const EdgeInsets.all(8),
                            //   color: Colors.red,
                            //   child: const Text(
                            //     'Giảm đến 50.000 VNĐ khi thanh toán trực tiếp tại cửa hàng ngay hôm nay!!',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 16),

                            ProductOptions(
                              colorOptions: colorOptions,
                              product: product,
                              user: widget.user,
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              child: Column(
                                children: [
                                  ExpansionTile(
                                    title: const Text("Chi tiết sản phẩm"),
                                    leading: const Icon(Icons.add),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product.productDescription,
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 1),

                                  ExpansionTile(
                                    title: const Text("Chính sách đổi trả"),
                                    leading: const Icon(Icons.add),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ReturnPolicyWidget(),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 1),

                                  ExpansionTile(
                                    title: const Text("Chính sách thanh toán"),
                                    leading: const Icon(Icons.add),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Thông tin về phương thức thanh toán.",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 1),

                                  ExpansionTile(
                                    title: const Text("Hỏi đáp"),
                                    leading: const Icon(Icons.add),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: QuestionAnswerScreen(
                                          productId: product.productId,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, height: 1),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            _buildRecommendedProducts(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu'));
          }
        },
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return FutureBuilder<List<Product>>(
      future: _relatedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'CÓ THỂ BẠN THÍCH',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true, // Đảm bảo không chiếm toàn bộ màn hình
              physics:
                  const NeverScrollableScrollPhysics(), // Tránh lỗi cuộn kép
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 7.0,
                mainAxisSpacing: 7.0,
                childAspectRatio: 0.65,
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
                              categoryName: categoryName,
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
      },
    );
  }
}
