import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../firebase_api_controller.dart';

class EstablishmentCreateMenuPage extends StatefulWidget {
  final String pubId;

  const EstablishmentCreateMenuPage({super.key, required this.pubId});

  @override
  State<EstablishmentCreateMenuPage> createState() =>
      _EstablishmentCreateMenuState();
}

class _EstablishmentCreateMenuState extends State<EstablishmentCreateMenuPage> {
  // User parameters
  String menuName = "";
  String menuDesc = "";

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 110;
    final double aleTrailTitleTop = screenHeight * 0.15;
    final double registerButtonTop = screenHeight * 0.65;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when keyboard appears
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: orangeCornerBottom,
              left: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/orangeCorner.svg",
                colorFilter:
                    const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                semanticsLabel: 'Orange Corner SVG',
              ),
            ),
            Positioned(
              top: aleTrailTitleTop,
              right: screenWidth * 0.15,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AleTrailNewMenu.svg",
                semanticsLabel: 'AleTrail New Venue',
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.5, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, width: 1), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 50, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines:
                          1, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        setState(() {
                          menuName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Menu Name',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: registerButtonTop *
                    0.70, // Adjust this value according to your layout
                right: screenWidth * 0.085,
                child: const Text(
                  "This will be visible as your menus tagline for users",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                )),
            Positioned(
              top: registerButtonTop *
                  0.76, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, width: 1), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height:
                        200, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines:
                          null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        setState(() {
                          menuDesc = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop * 1.25,
              right: screenWidth * 0.06,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
                  // Validate inputs
                  if (menuName.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Menu name must be at least 3 characters long!'),
                      ),
                    );
                    return;
                  }

                  if (menuDesc.split(' ').length > 15) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Description must not exceed 15 words!'),
                      ),
                    );
                    return;
                  }

                  // Call firebase function
                  var response = await createNewMenuInEstablishment(
                      widget.pubId, menuName, menuDesc);

                  if (response == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Failed to add menu to establishment!')),
                    );
                  } else {
                    // Navigate back
                    Navigator.of(context).pop(true);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.24),
                  child: const Text(
                    "Create Menu",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/yellowCorner.svg",
                semanticsLabel: 'Yellow Corner SVG',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
