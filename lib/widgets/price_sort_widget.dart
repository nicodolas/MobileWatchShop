import 'package:flutter/material.dart';

enum PriceSortOption { ascending, descending }

extension PriceSortOptionExtension on PriceSortOption {
  String get label {
    switch (this) {
      case PriceSortOption.ascending:
        return 'Tăng dần';
      case PriceSortOption.descending:
        return 'Giảm dần';
    }
  }
}

class PriceSortButton extends StatelessWidget {
  final PriceSortOption? selectedOption;
  final void Function(PriceSortOption) onSelected;

  const PriceSortButton({
    Key? key,
    required this.selectedOption,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PriceSortOption>(
      initialValue: selectedOption,
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: PriceSortOption.ascending,
              child: Text('Giá: Tăng dần'),
            ),
            const PopupMenuItem(
              value: PriceSortOption.descending,
              child: Text('Giá: Giảm dần'),
            ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedOption == null
                    ? 'Giá'
                    : 'Giá: ${selectedOption!.label}',
                style: const TextStyle(
                  //fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.attach_money_outlined, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
