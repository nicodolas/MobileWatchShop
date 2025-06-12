import 'package:ahtshopdongho/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:ahtshopdongho/services/cart_service.dart';
import 'package:ahtshopdongho/models/product_model.dart';

class ProductOptions extends StatefulWidget {
  final List<Map<String, dynamic>> colorOptions;
  final Product product;
  final AppUser user;

  const ProductOptions({
    super.key,
    required this.colorOptions,
    required this.product,
    required this.user,
  });

  @override
  _ProductOptionsState createState() => _ProductOptionsState();
}

class _ProductOptionsState extends State<ProductOptions> {
  Map<String, dynamic>? selectedColorOption;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    for (final option in widget.colorOptions) {
      if (option['stock'] > 0) {
        selectedColorOption = option;
        break;
      }
    }
  }

  void increaseQuantity() {
    if (selectedColorOption != null &&
        quantity < selectedColorOption!['stock']) {
      setState(() {
        quantity++;
      });
    } else {
      // Optional: thông báo nếu người dùng nhấn quá giới hạn
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vượt quá số lượng chúng tôi có thể cung cấp: ${selectedColorOption!['stock']}',
          ),
        ),
      );
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Màu sắc:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            // Tránh tràn nếu nhiều màu
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  widget.colorOptions.map((option) {
                    final colorName = option['color'] as String;
                    final isSelected =
                        selectedColorOption?['color'] == colorName;
                    final isOutOfStock = option['stock'] == 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed:
                            isOutOfStock
                                ? null
                                : () {
                                  setState(() {
                                    selectedColorOption = option;
                                  });
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isOutOfStock ? Colors.grey : Colors.white,
                          foregroundColor:
                              isSelected ? Colors.black : Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: isSelected ? Colors.black : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          colorName,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isOutOfStock ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              IconButton(
                onPressed: decreaseQuantity,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  padding: EdgeInsets.zero,
                ),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$quantity', style: const TextStyle(fontSize: 16)),
              ),
              IconButton(
                onPressed: increaseQuantity,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  padding: EdgeInsets.zero,
                ),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  if (selectedColorOption != null &&
                      selectedColorOption!['stock'] > 0) {
                    final itemToAdd = {
                      'productId': widget.product.productId,
                      'productName': widget.product.productName,
                      'productPrice': widget.product.productPrice,
                      'quantity': quantity,
                      'selectedColor': selectedColorOption!['color'],
                      'selectedImageUrl': selectedColorOption!['imageUrl'],
                    };
                    await CartService().addToCart(
                      widget.user.userId,
                      itemToAdd,
                    );
                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder:
                          (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            content: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(222, 255, 255, 255),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Đã thêm vào giỏ hàng $quantity ${selectedColorOption!['color']}",
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );

                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn màu sắc.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Thêm vào giỏ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
