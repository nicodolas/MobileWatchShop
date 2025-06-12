class Product {
  String productId;
  String productName;
  String productDescription;
  String productImageUrl;
  num productPrice;
  //int productStock;
  String categoryId;
  String brandId;
  String productStatus;
  List<Map<String, dynamic>>? colorOptions;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productImageUrl,
    required this.productPrice,
    //required this.productStock,
    required this.categoryId,
    required this.brandId,
    required this.colorOptions,
    required this.productStatus,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productImageUrl: json['productImageUrl'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      //productStock: json['productStock'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      brandId: json['brandId'] ?? '',
      productStatus: json['productStatus'] ?? '',
      colorOptions:
          (json['colorOptions'] as List<dynamic>?)
              ?.map((colorOptions) => colorOptions as Map<String, dynamic>)
              .toList(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      //'productStock': productStock,
      'categoryId': categoryId,
      'brandId': brandId,
      'productStatus': productStatus,
      'colorOptions': colorOptions,
    };
  }
}
