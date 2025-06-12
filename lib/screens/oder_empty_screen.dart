import 'package:flutter/material.dart';
import 'package:ahtshopdongho/widgets/order_list_view.dart';
// import 'package:ahtshopdongho/widgets/home_drawer_widget.dart';
// import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';

class OrderEmptyScreen extends StatefulWidget {
  final int initialTabIndex;

  const OrderEmptyScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OrderEmptyScreen> createState() => _OrderEmptyScreenState();
}

class _OrderEmptyScreenState extends State<OrderEmptyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    _tabController.addListener(() {
      setState(() {}); // Cập nhật lại UI khi tab thay đổi
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onOrderItemTap(int index) {
    _tabController.animateTo(index);
  }

  Widget _buildOrderItem(IconData icon, String label, int tabIndex) {
    final isSelected = _tabController.index == tabIndex;

    return GestureDetector(
      onTap: () => _onOrderItemTap(tabIndex),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: isSelected ? Colors.green : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.green : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Đã giao'),
            Tab(text: 'Đã trả'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderItem(Icons.list_alt, 'Tất cả', 0),
                _buildOrderItem(Icons.local_shipping, 'Đang giao', 1),
                _buildOrderItem(Icons.check_circle_outline, 'Đã giao', 2),
                _buildOrderItem(Icons.replay_circle_filled, 'Đã trả', 3),
                _buildOrderItem(Icons.cancel_outlined, 'Đã hủy', 4),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                OrderListView(),
                OrderListView(status: 'Đang giao'),
                OrderListView(status: 'Đã giao'),
                OrderListView(status: 'Đã trả'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class OrderEmptyScreen extends StatelessWidget {
//   final int initialTabIndex;

//   const OrderEmptyScreen({super.key, this.initialTabIndex = 0});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 5,
//       initialIndex: initialTabIndex.clamp(0, 4),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text('Đơn hàng', style: TextStyle(color: Colors.black)),
//           centerTitle: true,
//           actions: const [
//             Icon(Icons.notifications_none, color: Colors.black),
//             SizedBox(width: 12),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(90),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Tìm kiếm sản phẩm hoặc đơn hàng đã mua...',
//                       hintStyle: const TextStyle(fontSize: 13),
//                       prefixIcon: const Icon(Icons.search),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                       filled: true,
//                       fillColor: Colors.grey.shade200,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 TabBar(
//                   isScrollable: true,
//                   labelColor: Colors.green,
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: Colors.green,
//                   indicatorWeight: 3,
//                   labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//                   tabs: const [
//                     Tab(text: 'Tất cả'),
//                     Tab(text: 'Đang giao'),
//                     Tab(text: 'Đã giao'),
//                     Tab(text: 'Đã trả'),
//                     Tab(text: 'Đã hủy'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             OrderListView(),
//             OrderListView(status: 'Đang giao'),
//             OrderListView(status: 'Đã giao'),
//             OrderListView(status: 'Đã trả'),
//             OrderListView(status: 'Đã hủy'),
//           ],
//         ),
//       ),
//     );
//   }
// }
