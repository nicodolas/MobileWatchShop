import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/models/product_model.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Lấy all sản phẩm
  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _productsCollection.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromJson({...data, 'productId': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  // Lấy sản phẩm theo loại, thương hiệu, khoảng giá
  Future<List<Product>> getProductsByCategory(
    String categoryId,
    List<String> selectedBrands,
    RangeValues priceRange,
  ) async {
    print('Đang lấy list sản phẩm cho loại: $categoryId');
    try {
      QuerySnapshot querySnapshot =
          await _productsCollection
              .where('categoryId', isEqualTo: categoryId)
              .get();

      List<Product> products = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String brandId = data['brandId'] ?? '';
        String productStatus = data['productStatus'] ?? '';

        if (productStatus == "Ngừng bán") {
          continue; // Bỏ qua
        }

        // Truy vấn collection brands lấy brandName
        DocumentSnapshot brandSnapshot =
            await FirebaseFirestore.instance
                .collection('brands')
                .doc(brandId)
                .get();

        String brandName =
            brandSnapshot.exists ? brandSnapshot['brandName'] : '';

        if ((selectedBrands.isEmpty || selectedBrands.contains(brandName)) &&
            (data['productPrice'] >= priceRange.start &&
                data['productPrice'] <= priceRange.end)) {
          data['brandName'] = brandName;
          products.add(Product.fromJson(data));
        }
      }
      print('Số sản phẩm lọc được (ko bao gồm ngừng bán): ${products.length}');
      return products;
    } catch (e) {
      print('Error lấy list sản phẩm theo danh mục: $e');
      return [];
    }
  }

  // Lấy chi tiết sản phẩm
  Future<Product> getProductById(String productId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _productsCollection.doc(productId).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return Product.fromJson(data);
      } else {
        throw Exception('Không tim tìm thấy sản phẩm.');
      }
    } catch (e) {
      print('Error lấy list sản phẩm bằng id: $e');
      throw e;
    }
  }

  // Lấy top 5 sản phẩm bán chạy
  Future<List<Product>> getTopSellingProducts() async {
    final invoicesSnapshot =
        await FirebaseFirestore.instance.collection('invoices').get();

    print("Số lượng hóa đơn: ${invoicesSnapshot.docs.length}");

    Map<String, int> productSalesCount = {};

    for (var invoice in invoicesSnapshot.docs) {
      final data = invoice.data();
      final purchasedProducts = data['invoiceItems'];
      if (purchasedProducts == null || purchasedProducts.isEmpty) {
        continue;
      }

      for (var product in purchasedProducts) {
        if (product is Map<String, dynamic>) {
          final productId = product['productId'];
          int quantity = (product['quantity'] as num?)?.toInt() ?? 1;

          if (productId != null) {
            productSalesCount[productId] =
                (productSalesCount[productId] ?? 0) + quantity;
          }
        }
      }
    }

    List<MapEntry<String, int>> sortedEntries =
        productSalesCount.entries.toList();
    sortedEntries.sort((a, b) => b.value.compareTo(a.value));

    List<String> topProductIds =
        sortedEntries.take(5).map((entry) => entry.key).toList();

    if (topProductIds.isEmpty) return [];

    try {
      final productsSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where(FieldPath.documentId, whereIn: topProductIds)
              .get();

      if (productsSnapshot.docs.isNotEmpty) {
        return productsSnapshot.docs
            .map((doc) => Product.fromJson(doc.data()!))
            .toList();
      } else {
        List<Product> topProducts = [];
        for (String productId in topProductIds) {
          final doc =
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get();
          if (doc.exists) {
            topProducts.add(Product.fromJson(doc.data()!));
          }
        }
        return topProducts;
      }
    } catch (e) {
      print("Lỗi truy vấn Firestore: $e");
      return [];
    }
  }

  Future<void> getProductColors(String productId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

    final data = doc.data();
    if (data == null) return;

    List<dynamic> colorOptions = data['colorOptions'];

    for (var colorOption in colorOptions) {
      print('Màu: ${colorOption['color']}');
      print('Ảnh: ${colorOption['imageUrl']}');
      print('Tồn kho: ${colorOption['stock']}');
    }
  }
}
