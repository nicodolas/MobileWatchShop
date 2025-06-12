import 'package:flutter/material.dart';
import 'package:ahtshopdongho/utils/currency_formatter.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showCheckbox;
  final bool isSelected;
  final bool showDelete;
  final int quantity;
  final void Function(bool?)? onCheckboxChanged;
  final void Function()? onDelete;
  final void Function()? onIncrease;
  final void Function()? onDecrease;
  final Future<String> Function()? getBrandName;

  const CartItemCard({
    super.key,
    required this.item,
    required this.quantity,
    this.showCheckbox = false,
    this.isSelected = false,
    this.showDelete = false,
    this.onCheckboxChanged,
    this.onDelete,
    this.onIncrease,
    this.onDecrease,
    this.getBrandName,
  });

  @override
  Widget build(BuildContext context) {
    final price = int.tryParse(item['productPrice'].toString()) ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              Checkbox(value: isSelected, onChanged: onCheckboxChanged),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['selectedImageUrl'] ?? 'https://via.placeholder.com/100',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['productName'] ?? 'Tên sản phẩm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDelete)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String>(
                    future: getBrandName?.call(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Đang tải thương hiệu...',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Lỗi tải thương hiệu',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        );
                      }
                      return Text(
                        'Thương hiệu: ${snapshot.data}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text("Màu sắc: ${item['selectedColor']}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${CurrencyFormatter.formatCurrency(price)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _quantityButton(
                            icon: Icons.remove,
                            onTap: onDecrease,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _quantityButton(icon: Icons.add, onTap: onIncrease),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, void Function()? onTap}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
