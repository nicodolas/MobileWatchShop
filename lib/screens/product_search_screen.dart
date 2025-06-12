import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahtshopdongho/models/user_model.dart';
import 'package:ahtshopdongho/screens/home_screen.dart';
import 'package:ahtshopdongho/screens/cart_screen.dart';
import 'package:ahtshopdongho/screens/profile_screen.dart';
import 'package:ahtshopdongho/widgets/home_appbar_widget.dart';
import 'package:ahtshopdongho/widgets/home_bottom_navigation_bar_widget.dart';
import 'package:ahtshopdongho/utils/currency_formatter.dart';

class ProductSearchScreen extends StatefulWidget {
  final AppUser user;
  final String categoryName;

  const ProductSearchScreen({
    super.key,
    required this.user,
    required this.categoryName,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  String _searchQuery = "";
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomeScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductSearchScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CartScreen(
                  categoryName: widget.categoryName,
                  user: widget.user,
                ),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
                  user: widget.user,
                  categoryName: widget.categoryName,
                ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Tìm sản phẩm...',
            border: InputBorder.none,
          ),
          autofocus: true,
          style: const TextStyle(
            color: Color.fromARGB(255, 23, 23, 23),
            fontSize: 16,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final results =
              snapshot.data!.docs.where((doc) {
                final name =
                    (doc['productName'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

          if (results.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final data = results[index].data() as Map<String, dynamic>;
              return _buildProductCard(data);
            },
          );
        },
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              data['productImageUrl'] ?? '',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['productName'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatCurrency(data['productPrice'] ?? 0),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
