import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/ThemeConstants.dart';
import '../classes/MenuItem.dart';
import '../firebase_api_controller.dart';
import '../widgets/BusinessMenuCategories.dart';
import '../widgets/MenuCategories.dart';
import 'BusinessMenuProductView.dart';
import 'Menu/CreateMenu.dart';
import 'MenuProductView.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EstablishmentViewPage extends StatefulWidget {
  final String pubId;

  const EstablishmentViewPage({super.key, required this.pubId});

  @override
  EstablishmentViewState createState() => EstablishmentViewState();
}

class EstablishmentViewState extends State<EstablishmentViewPage> {
  bool isEditing = false;
  TextEditingController pubNameController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    // Initialize pubNameController here if necessary
  }

  @override
  void dispose() {
    pubNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double orangeCornerBottom = screenWidth * 0.6;

    return Scaffold(
        resizeToAvoidBottomInset:
            false, // Prevents resizing when keyboard appears
        body: Stack(children: [
          Positioned(
            left: orangeCornerBottom,
            bottom: screenHeight - 175,
            child: SvgPicture.asset(
              "lib/assets/images/svg/TopRightOrange.svg",
              semanticsLabel: 'Orange Corner SVG',
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('EstablishmentDetailed')
                .doc(widget.pubId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Pub not found'));
              }

              var pubData = snapshot.data!.data() as Map<String, dynamic>;
              var pubName = pubData['EstablishmentName'] ?? "";
              var pubImage = pubData['Image'] ?? "";
              var pubDescription = pubData['Description'] ?? '';
              var pubTags = pubData['Tags'] ?? '';
              var pubDistance = pubData['distance'] ?? '<150M';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildPubBusinessCard(pubImage, pubName, pubDescription,
                      pubTags, pubDistance, context, widget.pubId),
                  const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text('Menu',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildMenuSection(context, widget.pubId),
                    ),
                  ),
                ],
              );
            },
          ),
        ]));
  }

  Widget _buildPubBusinessCard(
    String pubImage,
    String pubName,
    String pubDescription,
    String pubTags,
    String pubDistance,
    BuildContext context,
    String pubId,
  ) {
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
                  isEditing
                      ? TextField(
                          controller: pubNameController,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          pubName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 8),
                  Text(pubDescription,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            backgroundColor: primaryButton,
                          ),
                          onPressed: () async {
                            var response = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        EstablishmentCreateMenuPage(
                                  pubId: pubId,
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

                            // refresh if new menu added
                            if (response == true) {
                              // refresh
                              setState(() {});
                            }
                          },
                          child: const Text(
                            "New Menu",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            backgroundColor: secondaryButton,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isEditing == true) {
                                isEditing = false;
                              } else {
                                isEditing = true;
                                pubNameController.text = pubName;
                              }
                            });
                          },
                          child: Text(
                            isEditing ? "Save" : "Edit",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
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
      future: getEstablishmentMenus(pubId),
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
                    var menuName = menuItems
                        .firstWhere((item) => item.name == category)
                        .name;
                    var menuDesc = menuItems
                        .firstWhere((item) => item.name == category)
                        .description;
                    // Ensure the correct MenuId is passed to MenuProductView
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            BusinessMenuProductView(
                                menuId: menuId,
                                menuDesc: menuDesc,
                                menuName: menuName, establishmentRef: pubId,),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ),
                    );
                  },
                  child: BusinessMenuCategoryWidget(
                    edit: isEditing,
                    establishmentId: widget.pubId,
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
