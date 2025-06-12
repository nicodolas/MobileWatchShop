import 'package:ahtshopdongho/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:ahtshopdongho/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ahtshopdongho/services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Color addButtonColor = Colors.white;
  List<Map<String, dynamic>> availableColors = [];
  bool isLoadingColors = false;

  @override
  void initState() {
    super.initState();
    _fetchProductColors();
  }

  Future<void> _fetchProductColors() async {
    setState(() => isLoadingColors = true);

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product.productId)
              .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['colorOptions'] != null) {
          availableColors = List<Map<String, dynamic>>.from(
            data['colorOptions'].map(
              (item) => {
                'color': item['color'],
                'imageUrl': item['imageUrl'],
                'stock': item['stock'],
              },
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi lấy colorOptions: $e');
    }

    setState(() => isLoadingColors = false);
  }

  Future<void> _onAddPressedWithImage(
    String selectedColor,
    int quantity,
    String imageUrl,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đăng nhập để thêm vào giỏ hàng")),
      );
      return;
    }

    try {
      final cartService = CartService();
      final itemToAdd = {
        'productId': widget.product.productId,
        'productName': widget.product.productName,
        'productPrice': widget.product.productPrice,
        'quantity': quantity,
        'selectedColor': selectedColor,
        'selectedImageUrl': imageUrl,
      };

      await cartService.addToCart(user.uid, itemToAdd);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã thêm vào giỏ hàng")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm: $e")));
    }
  }

  Future<void> showColorSelectionPopup(
    BuildContext context,
    Product product,
    Function(String color, int quantity, String imageUrl) onAdd,
  ) async {
    List<Map<String, dynamic>> availableColors = [];
    int selectedIndex = 0;
    int selectedQuantity = 1;
    bool isLoadingColors = true;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.productId)
        .get()
        .then((doc) {
          if (doc.exists) {
            final data = doc.data();
            if (data != null && data['colorOptions'] != null) {
              availableColors = List<Map<String, dynamic>>.from(
                data['colorOptions'].map(
                  (item) => {
                    'color': item['color'],
                    'imageUrl': item['imageUrl'],
                    'stock': item['stock'],
                  },
                ),
              );
            }
          }
          isLoadingColors = false;
        });

    if (availableColors.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final selected = availableColors[selectedIndex];
            final maxStock = selected['stock'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chọn màu và số lượng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableColors.length,
                      itemBuilder: (context, index) {
                        final color = availableColors[index];
                        final isSelected = index == selectedIndex;
                        final inStock = (color['stock'] ?? 0) > 0;

                        return GestureDetector(
                          onTap: () {
                            if (inStock) {
                              setModalState(() {
                                selectedIndex = index;
                                selectedQuantity = 1;
                              });
                            }
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: !inStock ? Colors.grey.shade200 : null,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child:
                                      color['imageUrl'] != null &&
                                              color['imageUrl'] != ''
                                          ? Image.network(
                                            color['imageUrl'],
                                            fit: BoxFit.contain,
                                          )
                                          : const Icon(
                                            Icons.image_not_supported,
                                          ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  color['color'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: inStock ? Colors.black : Colors.grey,
                                  ),
                                ),
                                if (!inStock)
                                  const Text(
                                    'Hết hàng',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Số lượng:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nút trừ
                      InkWell(
                        onTap:
                            selectedQuantity > 1
                                ? () => setModalState(() => selectedQuantity--)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Số lượng
                      Container(
                        width: 50,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$selectedQuantity',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Nút cộng
                      InkWell(
                        onTap:
                            selectedQuantity < maxStock
                                ? () => setModalState(() => selectedQuantity++)
                                : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed:
                        selected['stock'] > 0
                            ? () {
                              Navigator.of(context).pop();
                              onAdd(
                                selected['color'],
                                selectedQuantity,
                                selected['imageUrl'],
                              );
                            }
                            : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Thêm vào giỏ"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: product.productImageUrl,
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.formatCurrency(product.productPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: addButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        showColorSelectionPopup(context, product, (
                          String selectedColor,
                          int quantity,
                          String imageUrl,
                        ) {
                          _onAddPressedWithImage(
                            selectedColor,
                            quantity,
                            imageUrl,
                          );
                        });
                      },
                      icon: const Icon(Icons.add_outlined),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
