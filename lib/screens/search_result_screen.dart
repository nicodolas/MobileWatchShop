import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Danh sách sản phẩm mẫu để test
    final List<String> dummyProducts = [
      "Đồng hồ thông minh A",
      "Đồng hồ nữ B",
      "Đồng hồ nam C",
      "Tai nghe không dây D",
      "Điện thoại E",
    ];

    // Lọc sản phẩm dựa trên từ khóa tìm kiếm
    final List<String> filteredProducts =
        dummyProducts
            .where(
              (product) => product.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Kết quả tìm kiếm: $query")),
      body:
          filteredProducts.isEmpty
              ? const Center(child: Text("Không tìm thấy sản phẩm nào."))
              : ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredProducts[index]),
                    onTap: () {
                      // Khi nhấn vào sản phẩm, có thể điều hướng đến trang chi tiết
                      print("Mở chi tiết sản phẩm: ${filteredProducts[index]}");
                    },
                  );
                },
              ),
    );
  }
}
