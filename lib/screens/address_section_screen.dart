import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ahtshopdongho/models/shipping_address_model.dart';
import 'package:ahtshopdongho/models/provinces.open-api.dart';

class AddressScreen extends StatefulWidget {
  final String userId;
  final ShippingAddress? initialAddress;

  const AddressScreen({super.key, required this.userId, this.initialAddress});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? selectedProvinceName;
  String? selectedDistrictName;
  String? selectedWardName;

  int? selectedProvinceCode;
  int? selectedDistrictCode;

  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  final TextEditingController streetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse('https://provinces.open-api.vn/api/p/'),
    );
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      ;
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
      ;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ nhận hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
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
                  final selected = districts.firstWhere((d) => d.name == value);
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
            TextField(
              controller: streetController,
              decoration: const InputDecoration(labelText: 'Số nhà, Tên đường'),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedProvinceName != null &&
                      selectedDistrictName != null &&
                      selectedWardName != null &&
                      streetController.text.isNotEmpty) {
                    final fullAddress = ShippingAddress(
                      province: selectedProvinceName!,
                      district: selectedDistrictName!,
                      ward: selectedWardName!,
                      street: streetController.text,
                    );

                    Navigator.pop(context, fullAddress);
                  }
                },
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
