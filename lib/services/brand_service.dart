import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService {
  // final CollectionReference _brandCollection = FirebaseFirestore.instance
  //     .collection('brands');

  static Future<String?> getBrandName(String brandId) async {
    final brandDoc =
        await FirebaseFirestore.instance
            .collection('brands')
            .doc(brandId)
            .get();
    if (brandDoc.exists) {
      return brandDoc.data()?['brandName'] as String?;
    }
    return '';
  }

  static Future<String?> getBrandNameByProductId(String productId) async {
    final productDoc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

    if (productDoc.exists) {
      final brandId = productDoc.data()?['brandId'] as String?;
      if (brandId != null) {
        final brandDoc =
            await FirebaseFirestore.instance
                .collection('brands')
                .doc(brandId)
                .get();
        if (brandDoc.exists) {
          return brandDoc.data()?['brandName'] as String?;
        }
      }
    }
  }

  static Future<String> getBrandNameForCartItem(String productId) async {
    final brandName = await BrandService.getBrandNameByProductId(productId);
    return brandName ?? 'Không rõ';
  }
}
