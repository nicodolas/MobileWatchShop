import 'package:ahtshopdongho/models/product_model.dart';
import 'package:ahtshopdongho/widgets/price_sort_widget.dart';

List<Product> sortProductsByPrice(
  List<Product> products,
  PriceSortOption? option,
) {
  final sortedList = List<Product>.from(products); // Sao chép

  if (option == PriceSortOption.ascending) {
    sortedList.sort((a, b) => a.productPrice.compareTo(b.productPrice));
  } else if (option == PriceSortOption.descending) {
    sortedList.sort((a, b) => b.productPrice.compareTo(a.productPrice));
  }
  return sortedList;
}
