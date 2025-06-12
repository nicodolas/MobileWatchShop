import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCurrency(num amount) {
    final NumberFormat formatter = NumberFormat("#,### VNĐ", "vi_VN");
    return formatter.format(amount);
  }
}
