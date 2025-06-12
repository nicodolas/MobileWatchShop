class Brand {
  String brandId;
  String brandName;

  Brand({required this.brandId, required this.brandName});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(brandId: json['brandId'], brandName: json['brandName']);
  }

  Map<String, dynamic> toJson() {
    return {'brandId': brandId, 'brandName': brandName};
  }
}
