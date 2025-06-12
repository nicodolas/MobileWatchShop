import 'package:flutter/material.dart';
import 'package:ahtshopdongho/screens/men_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/women_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/smart_watch_list_screen.dart';
import 'package:ahtshopdongho/models/user_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final AppUser user;

  const FilterBottomSheet({super.key, required this.user});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory = 'smartwatch';

  final Map<String, String> _categoryDisplayNames = {
    'smartwatch': 'Đồng hồ thông minh',
    'female': 'Đồng hồ nữ',
    'male': 'Đồng hồ nam',
  };

  // Danh sách các thương hiệu đã chọn
  final Map<String, bool> _selectedBrands = {
    'Rolex': false,
    'Garmin': false,
    'Gedi': false,
    'Lige': false,
  };

  RangeValues _selectedPriceRange = const RangeValues(0, 200000);

  void _applyFilter() {
    String categoryName = _selectedCategory ?? 'smartwatch';
    String displayName =
        _categoryDisplayNames[_selectedCategory] ?? 'Đồng hồ thông minh';

    // Lọc danh sách thương hiệu đã chọn
    List<String> selectedBrands =
        _selectedBrands.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    num minPrice = _selectedPriceRange.start;
    num maxPrice = _selectedPriceRange.end;

    Widget screen;
    if (_selectedCategory == 'male') {
      screen = MenWatchListScreen(
        categoryName: displayName,
        selectedBrands: selectedBrands,
        selectedPriceRange: _selectedPriceRange,
        user: widget.user,
      );
    } else if (_selectedCategory == 'female') {
      screen = WomenWatchListScreen(
        categoryName: displayName,
        selectedBrands: selectedBrands,
        selectedPriceRange: _selectedPriceRange,
        user: widget.user,
      );
    } else {
      screen = SmartWatchListScreen(
        categoryName: displayName,
        selectedBrands: selectedBrands,
        selectedPriceRange: _selectedPriceRange,
        user: widget.user,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bộ lọc sản phẩm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSection("Danh mục sản phẩm", [
                _buildCategoryRadio("smartwatch", "Đồng hồ thông minh"),
                _buildCategoryRadio("female", "Đồng hồ nữ"),
                _buildCategoryRadio("male", "Đồng hồ nam"),
              ]),
              const SizedBox(height: 16),
              _buildSection("Thương hiệu", [
                _buildBrandCheckbox("Rolex"),
                _buildBrandCheckbox("Garmin"),
                _buildBrandCheckbox("Gedi"),
                _buildBrandCheckbox("Lige"),
              ]),
              _buildSection("Giá", [_buildPriceRangeSelector()]),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _applyFilter,
                      child: const Text("Lọc"),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedBrands.updateAll((key, value) => false);
                          setState(() {
                            _selectedPriceRange = const RangeValues(0, 200000);
                          });
                        });
                      },
                      child: const Text("Đặt lại"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRadio(String value, String text) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedCategory,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      title: Text(text),
    );
  }

  Widget _buildBrandCheckbox(String brand) {
    return CheckboxListTile(
      value: _selectedBrands[brand] ?? false,
      onChanged: (bool? checked) {
        setState(() {
          _selectedBrands[brand] = checked ?? false;
          debugPrint('Danh sách thương hiệu đã chọn: $_selectedBrands');
        });
      },
      title: Text(brand),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFFEDEDED),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              //const Icon(Icons.add),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildPriceRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          RangeSlider(
            min: 0,
            max: 200000,
            divisions: 20,
            labels: RangeLabels(
              '${_selectedPriceRange.start.toStringAsFixed(0)}đ',
              '${_selectedPriceRange.end.toStringAsFixed(0)}đ',
            ),
            values: _selectedPriceRange,
            onChanged: (RangeValues values) {
              setState(() {
                _selectedPriceRange = values;
              });
            },
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     SizedBox(
          //       width: 100,
          //       child: TextField(
          //         decoration: const InputDecoration(labelText: "Giá thấp nhất"),
          //         keyboardType: TextInputType.number,
          //         onChanged: (value) {
          //           setState(() {
          //             _selectedPriceRange = RangeValues(
          //               double.tryParse(value) ?? _selectedPriceRange.start,
          //               _selectedPriceRange.end,
          //             );
          //           });
          //         },
          //       ),
          //     ),
          Text(
            'Từ ${_selectedPriceRange.start.toStringAsFixed(0)}đ đến ${_selectedPriceRange.end.toStringAsFixed(0)}đ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          //     SizedBox(
          //       width: 100,
          //       child: TextField(
          //         decoration: const InputDecoration(labelText: "Giá cao nhất"),
          //         keyboardType: TextInputType.number,
          //         onChanged: (value) {
          //           setState(() {
          //             _selectedPriceRange = RangeValues(
          //               _selectedPriceRange.start,
          //               double.tryParse(value) ?? _selectedPriceRange.end,
          //             );
          //           });
          //         },
          //       ),
          //     ),
          //   ],
          //),
        ],
      ),
    );
  }
}
