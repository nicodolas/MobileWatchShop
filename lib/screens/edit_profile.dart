import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/services/user_service.dart';
import 'package:ahtshopdongho/models/provinces.open-api.dart';
import 'package:ahtshopdongho/models/shipping_address_model.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  AppUser? _user;

  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _streetController = TextEditingController();

  bool _isLoading = true;

  String? selectedProvinceName;
  String? selectedDistrictName;
  String? selectedWardName;

  int? selectedProvinceCode;
  int? selectedDistrictCode;

  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchProvinces();
  }

  Future<void> _loadUserData() async {
    final data = await UserService().getUserData(widget.userId);
    if (data != null) {
      final user = AppUser.fromMap(widget.userId, data);
      setState(() {
        _user = user;
        _fullNameController.text = user.fullName;
        _userNameController.text = user.userName;
        _phoneController.text = user.userPhone;
        _dobController.text = user.dateOfBirth;
        _provinceController.text = user.userAddress.province;
        _districtController.text = user.userAddress.district;
        _wardController.text = user.userAddress.ward;
        _streetController.text = user.userAddress.street;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'fullName': _fullNameController.text,
        'userName': _userNameController.text,
        'userPhone': _phoneController.text,
        'dateOfBirth': _dobController.text,
        'userAddress': {
          'province': _provinceController.text,
          'district': _districtController.text,
          'ward': _wardController.text,
          'street': _streetController.text,
        },
      };

      await UserService().updateUserData(widget.userId, updatedData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thành công!')));
    }
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse('https://provinces.open-api.vn/api/p/'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        provinces = data.map((e) => Province.fromJson(e)).toList();
      });
    }
  }

  Future<void> fetchDistricts(int provinceCode) async {
    final response = await http.get(
      Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        districts =
            (data['districts'] as List)
                .map((e) => District.fromJson(e))
                .toList();
      });
    }
  }

  Future<void> fetchWards(int districtCode) async {
    final response = await http.get(
      Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print(data);
      setState(() {
        wards = (data['wards'] as List).map((e) => Ward.fromJson(e)).toList();
      });
    } else {
      print('Failed to load wards for $districtCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Sửa thông tin")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sửa thông tin")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Họ và tên'),
                validator:
                    (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'Tên người dùng'),
                validator:
                    (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                initialValue: _user?.userEmail,
                enabled: false,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Ngày sinh (dd/MM/yyyy)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(_dobController.text) ??
                        DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final formattedDate =
                        "${pickedDate.year.toString().padLeft(4, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";
                    setState(() {
                      _dobController.text = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text("Địa chỉ", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: selectedProvinceName,
                decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
                items:
                    provinces
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.name,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  final selected = provinces.firstWhere((p) => p.name == value);
                  setState(() {
                    selectedProvinceName = value;
                    selectedProvinceCode = selected.code;
                    selectedDistrictName = null;
                    selectedWardName = null;
                    districts = [];
                    wards = [];
                  });
                  fetchDistricts(selected.code);
                },
              ),

              if (districts.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedDistrictName,
                  decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                  items:
                      districts
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    final selected = districts.firstWhere(
                      (d) => d.name == value,
                    );
                    setState(() {
                      selectedDistrictName = value;
                      selectedDistrictCode = selected.code;
                      selectedWardName = null;
                      wards = [];
                    });
                    fetchWards(selected.code);
                  },
                ),

              if (wards.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedWardName,
                  decoration: const InputDecoration(labelText: 'Phường/Xã'),
                  items:
                      wards
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      wards.isEmpty
                          ? null
                          : (value) {
                            setState(() {
                              selectedWardName = value;
                            });
                          },
                ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Số nhà, Tên đường',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
              ),

              const SizedBox(height: 24),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       if (selectedProvinceName != null &&
              //           selectedDistrictName != null &&
              //           selectedWardName != null &&
              //           streetController.text.isNotEmpty) {
              //         final fullAddress = ShippingAddress(
              //           province: selectedProvinceName!,
              //           district: selectedDistrictName!,
              //           ward: selectedWardName!,
              //           street: streetController.text,
              //         );

              //         Navigator.pop(context, fullAddress);
              //       }
              //     },
              //     child: const Text('Xác nhận'),
              //   ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedData = {
                      'fullName': _fullNameController.text,
                      'userName': _userNameController.text,
                      'userPhone': _phoneController.text,
                      'dateOfBirth': _dobController.text,
                      'userAddress': {
                        'province':
                            selectedProvinceName ?? _provinceController.text,
                        'district':
                            selectedDistrictName ?? _districtController.text,
                        'ward': selectedWardName ?? _wardController.text,
                        'street': _streetController.text,
                      },
                    };

                    await UserService().updateUserData(
                      widget.userId,
                      updatedData,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật thành công!')),
                    );
                  }
                },
                child: Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
