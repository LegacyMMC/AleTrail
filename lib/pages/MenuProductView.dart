import 'package:flutter/material.dart';
import '../firebase_api_controller.dart';

class MenuProductView extends StatelessWidget {
  final String menuId;

  const MenuProductView({Key? key, required this.menuId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildSearchBar(),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: getMenuProducts(menuId), // Call getMenuProducts function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          var products = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Build products list
                for (var product in products)
                  _buildProductCard(product['ProductName'],
                      product['ProductDescription'], product['ProductPrice']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
      String productName, String productDescription, double productPrice) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(productName),
        subtitle: Text(productDescription),
        trailing: Text(
          '£$productPrice',
          style: const TextStyle(fontSize: 15),
        ), // Assuming product price is in double
      ),
    );
  }

  Widget _buildSearchBar() {
    // Implement your search bar widget here
    return Container();
  }
}
