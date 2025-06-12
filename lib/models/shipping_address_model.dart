class ShippingAddress {
  final String street;
  final String ward;
  final String district;
  final String province;

  ShippingAddress({
    required this.street,
    required this.ward,
    required this.district,
    required this.province,
  });

  String get fullAddress => '$street, $ward, $district, $province';

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      street: map['street'] ?? '',
      ward: map['ward'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'ward': ward,
      'district': district,
      'province': province,
    };
  }
}
