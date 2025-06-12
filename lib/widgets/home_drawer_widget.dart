import 'package:flutter/material.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/smart_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/women_watch_list_screen.dart';
import 'package:ahtshopdongho/screens/men_watch_list_screen.dart';

class HomeDrawerWidget extends StatelessWidget {
  final String categoryName;
  final dynamic
  user; // Thay dynamic bằng kiểu cụ thể nếu bạn có, ví dụ UserModel

  const HomeDrawerWidget({
    Key? key,
    required this.categoryName,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Trang chủ'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => HomeScreen(categoryName: categoryName, user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.watch_outlined),
            title: const Text('Đồng hồ thông minh'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SmartWatchListScreen(
                        categoryName: "Đồng hồ thông minh",
                        selectedBrands: [],
                        selectedPriceRange: const RangeValues(0, 200000),
                        user: user,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.male_outlined),
            title: const Text('Đồng hồ nam'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MenWatchListScreen(
                        categoryName: "Đồng hồ nam",
                        selectedBrands: [],
                        selectedPriceRange: const RangeValues(0, 200000),
                        user: user,
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.female_outlined),
            title: const Text('Đồng hồ nữ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => WomenWatchListScreen(
                        categoryName: "Đồng hồ nữ",
                        selectedBrands: [],
                        selectedPriceRange: const RangeValues(0, 200000),
                        user: user,
                      ),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Cài đặt'),
          ),
        ],
      ),
    );
  }
}
