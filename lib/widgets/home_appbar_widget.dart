import 'package:flutter/material.dart';
import 'package:ahtshopdongho/screens/product_search_screen.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "AHT Shop",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            leading: Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>?;

                  if (args != null &&
                      args.containsKey('user') &&
                      args.containsKey('categoryName')) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/productSearch',
                      arguments: {
                        'user': args['user'],
                        'categoryName': args['categoryName'],
                      },
                    );
                  } else {
                    print("Lỗi: Không tìm thấy thông tin user và categoryName");
                  }
                },
                icon: const Icon(Icons.search_outlined, color: Colors.black),
              ),
            ],
          ),

          // Thanh tìm kiếm có hiệu ứng mượt
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 300),
          //   switchInCurve: Curves.easeInOut,
          //   switchOutCurve: Curves.easeInOut,
          //   child:
          //       _showSearch
          //           ? Container(
          //             key: const ValueKey("SearchBar"),
          //             color: Colors.white,
          //             padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.grey[200],
          //                 borderRadius: BorderRadius.circular(24),
          //               ),
          //               child: Row(
          //                 children: [
          //                   const SizedBox(width: 12),
          //                   Expanded(
          //                     child: TextField(
          //                       controller: _searchController,
          //                       decoration: const InputDecoration(
          //                         hintText: "Tìm kiếm...",
          //                         border: InputBorder.none,
          //                       ),
          //                     ),
          //                   ),
          //                   IconButton(
          //                     icon: const Icon(Icons.arrow_forward),
          //                     onPressed: () {
          //                       print("Search: ${_searchController.text}");
          //                     },
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           )
          //           : const SizedBox(key: ValueKey("Empty"), height: 0),
          // ),
        ],
      ),
    );
  }
}
