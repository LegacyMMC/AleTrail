import 'package:AleTrail/widgets/MenuButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/MenuProduct.dart';
import '../constants/ThemeConstants.dart';
import '../classes/MenuItem.dart';
import '../firebase_api_controller.dart';
import '../widgets/MenuProductWidget.dart';

// Init Global
double screenWidth = 0.0;
double screenHeight = 0.0;
List<MenuItem> menuItems = [];
bool pubInfoGet = false;

class UserEstablishmentViewPage extends StatefulWidget {
  final String pubId;
  final double long;
  final double latitude;

  const UserEstablishmentViewPage({
    super.key,
    required this.pubId,
    required this.long,
    required this.latitude,
  });

  @override
  _UserEstablishmentViewPageState createState() =>
      _UserEstablishmentViewPageState();
}

class _UserEstablishmentViewPageState extends State<UserEstablishmentViewPage> {
  String? selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      List<Map<String, dynamic>>? data =
          await getEstablishmentMenus(widget.pubId);
      if (data != null && data.isNotEmpty) {
        menuItems = data
            .map((data) => MenuItem(
                  menuProducts: [],
                  name: data['MenuName'] ?? '',
                  productIds: data['Products'],
                  description: data['MenuDescription'] ?? '',
                  menuId: data['MenuId'] ??
                      '', // Ensure MenuId is correctly assigned
                ))
            .toList();

        // Extract Products From That Menu
        await _extractProductsFromMenu(menuItems);

        setState(() {
          if (menuItems.isNotEmpty) {
            selectedCategory = menuItems.first.name;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _extractProductsFromMenu(List<MenuItem> menuItems) async {
    for (MenuItem menu in menuItems) {
      if (menu.productIds != null && menu.productIds!.isNotEmpty) {
        try {
          // Call getProductsBasedOnId and await the result
          List<Menuproduct> productDocs = await getProductsBasedOnId(
              menu.productIds!.map((e) => e.toString()).toList());
          // Assign products to menu item
          menu.menuProducts?.addAll(productDocs);
        } catch (e) {
          print('Error fetching products: $e');
        }
      }
    }
  }

  int getMenuItemCount(List<MenuItem> menuItems, String? selectedCategory) {
    if (selectedCategory == null) {
      return 0;
    } else {
      // Find the first matching menu item
      MenuItem? matchingItem =
          menuItems.firstWhere((item) => item.name == selectedCategory);
      return matchingItem?.menuProducts?.length ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          PubInfoWidget(pubId: widget.pubId),
          Padding(
            padding: EdgeInsets.fromLTRB(0, screenHeight * 0.4, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: _buildMenuSection(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 0.0,
                            ),
                            itemCount:
                                getMenuItemCount(menuItems, selectedCategory),
                            itemBuilder: (context, index) {
                              MenuItem? matchingItem = menuItems.firstWhere(
                                  (item) => item.name == selectedCategory);

                              if (matchingItem?.menuProducts != null) {
                                Menuproduct product =
                                    matchingItem!.menuProducts![index];
                                return MenuProductWidget(
                                  productName: product.productName,
                                  productPrice: '£${product.productPrice}',
                                  productDesc: product.productDescription,
                                  productImage:
                                      'Item $index', // Use actual image URL or placeholder
                                );
                              } else {
                                return const Center(
                                    child: Text('No products available.'));
                              }
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    Set<String> categories = menuItems.map((item) => item.name).toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Build menu categories dynamically
            for (var category in categories)
              GestureDetector(
                onTap: () {
                  if (category != selectedCategory) {
                    setState(() {
                      selectedCategory = category;
                    });
                  }
                },
                child: MenuButtonWidget(
                  edit: false,
                  category: category,
                  items:
                      menuItems.where((item) => item.name == category).toList(),
                  isSelected: selectedCategory == category,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PubInfoWidget extends StatelessWidget {
  final String pubId;

  const PubInfoWidget({required this.pubId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('EstablishmentDetailed')
          .doc(pubId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Pub not found'));
        }
        print("THEY KEY: " + pubId);
        var pubData = snapshot.data!.data() as Map<String, dynamic>;
        var pubName = pubData['EstablishmentName'] ?? "";
        var pubImage = pubData['Image'] ?? "";
        var pubCity = pubData['EstablishmentCity'] ?? '';
        var promotion = pubData['Promotion'] ?? false;

        return Stack(
          children: [
            Positioned(
              child: Container(
                height: screenHeight,
                color: Colors.white,
              ),
            ),
            Positioned(
              child: Container(
                height: 210,
                width: screenWidth,
                color: primaryButton,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.07),
                    Text(
                      pubName,
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5),
                    ),
                    Text(
                      pubCity,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 5),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 150,
              height:
                  150, // screenHeight - screenHeight + 130 simplifies to 130
              width: 400, // screenWidth - screenWidth + 400 simplifies to 400
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          promotion
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Container(
                                    width: screenWidth * 0.2,
                                    decoration: BoxDecoration(
                                      color: redAccentButton,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      // Center widget to center the child
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          "Promo",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                ), // Needed something here or else error
                        ],
                      ),
                      promotion
                          ? Row(
                              children: [
                                Stack(
                                  children: [
                                    Positioned(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 20, 0, 0),
                                        child: Container(
                                          width: screenWidth * 0.6,
                                          height: 25,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 62, 0, 0),
                                        child: Container(
                                          width: screenWidth * 0.4,
                                          height: 25,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 0, 0, 0),
                                        child: Text(
                                          "Buy One Get \nOne Free",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    pubImage ?? '',
                                    height: screenHeight * 0.181,
                                    width: screenWidth *
                                        0.89, // Match the height of the container
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
