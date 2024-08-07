import 'package:AleTrail/pages/BusinessMenuProductView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../classes/MenuItem.dart';
import '../firebase_api_controller.dart';
import '../widgets/MenuCategories.dart';
import 'MenuProductView.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BusinessAllMenusView extends StatelessWidget {
  final String pubId;
  const BusinessAllMenusView({super.key, required this.pubId});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double orangeCornerBottom = screenWidth * 0.6;

    return Scaffold(
        body: Stack(children: [
      Positioned(
        left: orangeCornerBottom,
        bottom: screenHeight - 175,
        child: SvgPicture.asset(
          "lib/assets/images/svg/TopRightOrange.svg",
          semanticsLabel: 'Orange Corner SVG',
        ),
      ),
      const Positioned(
        top: 30,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            // Wrap TextField and Icon in a Row
            children: [],
          ),
        ),
      ),
      Positioned(
        top: 100,
        right: screenWidth * 0.27,
        child: SvgPicture.asset(
          "lib/assets/images/svg/AletrailMenus.svg",
          semanticsLabel: 'AleTrail Menus',
        ),
      ),
      Positioned(
          top: screenHeight * 0.3,
          left: 0,
          right: 0,
          child: FutureBuilder<List<Map<String, dynamic>>?>(
            future: getAllMenusForBusinessUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No menu items found'));
              }

              List<MenuItem> menuItems = [];
              for (var data in snapshot.data!) {
                menuItems.add(MenuItem(
                  name: data['MenuName'] ?? '',
                  description: data['MenuDescription'] ?? '',
                  menuId: data['MenuId'] ??
                      '', // Ensure MenuId is correctly assigned
                ));
              }

              // Extract distinct categories from menu items
              Set<String> categories =
                  menuItems.map((item) => item.name).toSet();

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build menu categories dynamically
                    for (var category in categories)
                      GestureDetector(
                        onTap: () {
                          var menuId = menuItems
                              .firstWhere((item) => item.name == category)
                              .menuId;
                          var menuDesc = menuItems
                              .firstWhere((item) => item.name == category)
                              .description;

                          var menuName = menuItems
                              .firstWhere((item) => item.name == category)
                              .name;
                          // Ensure the correct MenuId is passed to MenuProductView
                          if (kDebugMode) {
                            print("Selected MenuId: $menuId");
                          }
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      BusinessMenuProductView(
                                menuId: menuId,
                                menuDesc: menuDesc,
                                menuName: menuName, establishmentRef: pubId,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var begin = const Offset(10.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: MenuCategoryWidget(
                          edit: false,
                          category: category,
                          items: menuItems
                              .where((item) => item.name == category)
                              .toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ))
    ]));
  }

  Widget _buildPubCard(String pubImage, String pubName, String pubDescription,
      String pubTags, String pubDistance) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pubImage.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(pubImage,
                    fit: BoxFit.cover, width: double.infinity, height: 150),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pubName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(pubDescription,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(pubTags,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(pubDistance,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String pubId) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: getAllMenusForBusinessUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No menu items found'));
        }

        List<MenuItem> menuItems = [];
        for (var data in snapshot.data!) {
          menuItems.add(MenuItem(
            name: data['MenuName'] ?? '',
            description: data['MenuDescription'] ?? '',
            menuId: data['MenuId'] ?? '', // Ensure MenuId is correctly assigned
          ));
        }

        // Extract distinct categories from menu items
        Set<String> categories = menuItems.map((item) => item.name).toSet();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Build menu categories dynamically
              for (var category in categories)
                GestureDetector(
                  onTap: () {
                    var menuId = menuItems
                        .firstWhere((item) => item.name == category)
                        .menuId;
                    var menuDesc = menuItems
                        .firstWhere((item) => item.name == category)
                        .description;
                    // Ensure the correct MenuId is passed to MenuProductView
                    if (kDebugMode) {
                      print("Selected MenuId: $menuId");
                    }
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MenuProductView(menuId: menuId, menuDesc: menuDesc),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(10.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  child: MenuCategoryWidget(
                    edit: false,
                    category: category,
                    items: menuItems
                        .where((item) => item.name == category)
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
