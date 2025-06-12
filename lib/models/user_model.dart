import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String userName;
  final String fullName;
  final String userEmail;
  final String userPhone;
  final String userAvatarUrl;
  final String dateOfBirth;
  final DateTime userCreatedAt;
  final UserAddress userAddress;

  AppUser({
    required this.userId,
    required this.userName,
    required this.fullName,
    required this.userEmail,
    required this.userPhone,
    required this.userAvatarUrl,
    required this.dateOfBirth,
    required this.userCreatedAt,
    required this.userAddress,
  });

  factory AppUser.fromMap(String userId, Map<String, dynamic> map) {
    return AppUser(
      userId: userId,
      userName: map['userName'],
      fullName: map['fullName'],
      userEmail: map['userEmail'],
      userPhone: map['userPhone'],
      userAvatarUrl: map['userAvatarUrl'],
      dateOfBirth: map['dateOfBirth'],
      userCreatedAt: (map['userCreatedAt'] as Timestamp).toDate(),
      userAddress: UserAddress.fromMap(map['userAddress']),
    );
  }
}

class UserAddress {
  final String province;
  final String district;
  final String ward;
  final String street;

  UserAddress({
    required this.province,
    required this.district,
    required this.ward,
    required this.street,
  });

  factory UserAddress.fromMap(Map<String, dynamic> map) {
    return UserAddress(
      province: map['province'],
      district: map['district'],
      ward: map['ward'],
      street: map['street'],
    );
  }
}
