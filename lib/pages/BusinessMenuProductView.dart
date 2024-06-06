import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import '../firebase_api_controller.dart';
import 'Menu/EstablishmentNewProductFirstStep.dart';

class BusinessMenuProductView extends StatelessWidget {
  final String menuId;
  final String menuDesc;
  final String menuName;

  const BusinessMenuProductView(
      {super.key,
      required this.menuId,
      required this.menuDesc,
      required this.menuName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: getMenuProducts(menuId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header box
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryButton.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryButton,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          menuDesc,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                            height: 16), // Add space between text and buttons
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 15,
                                backgroundColor: primaryButton,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        EstablishmentProductOnePage(
                                            menuId: menuId),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return child;
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "New Product",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                                width: 16), // Add space between buttons
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 15,
                                backgroundColor: secondaryButton,
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Edit Menu",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          var products = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header box
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryButton.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuName ?? "Menu Name Missing",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryButton,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menuDesc,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Add space between text and buttons
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 15,
                              backgroundColor: primaryButton,
                            ),
                            onPressed: () {Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                    EstablishmentProductOnePage(
                                        menuId: menuId),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                              ),
                            );},
                            child: const Text(
                              "New Product",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                              width: 16), // Add space between buttons
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 15,
                              backgroundColor: secondaryButton,
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Edit Menu",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Product list
                for (var product in products)
                  _buildProductCard(
                    context,
                    product['ProductName'],
                    product['ProductDescription'],
                    product['ProductPrice'],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productName,
    String productDescription,
    dynamic productPrice,
  ) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(productDescription),
        trailing: Text(
          '£$productPrice',
          style: const TextStyle(fontSize: 15),
        ),
        onTap: () {
          _showProductDetails(
              context, productName, productDescription, productPrice);
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, String productName,
      String productDescription, double productPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(productName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productDescription),
              const SizedBox(height: 16),
              Text(
                'Price: £$productPrice',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
