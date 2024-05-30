import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/AccountType.dart';
import '../../firebase_api_controller.dart';
import '../UserMap.dart';
import 'EstablishmentSecondStep.dart';

class EstablishmentOnePage extends StatefulWidget {
  const EstablishmentOnePage({super.key});

  @override
  State<EstablishmentOnePage> createState() => _EstablishmentOnePageState();
}

class _EstablishmentOnePageState extends State<EstablishmentOnePage> {
  // User parameters
  String EstablishmentName = "";
  String EstablishmentAddress = "";
  String EstablishmentDesc = "";

  final TextEditingController _addressController = TextEditingController();

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
              right: screenWidth * 0.125,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AleTrailNewVenue.svg",
                semanticsLabel: 'AleTrail New Venue',
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.45, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
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
                      null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        EstablishmentName = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Establishment Name',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.60, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
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
                      null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        EstablishmentAddress = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Establishment Postcode',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.75, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: Colors.grey, width: 2), // Outer border
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
                        EstablishmentDesc = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Establishment Description',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20,
                            15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop * 1.3,
              right: screenWidth * 0.11,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
                  // Check if name or address is empty
                  if (EstablishmentName != "" && EstablishmentAddress != "") {
                    // Register to backend
                    String stepCompleted = await addNewVenueToFirebase(
                        EstablishmentName, EstablishmentAddress);
                    if (stepCompleted != "") {
                      //Navigate to step two
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                EstablishmentTwoPage(docId: stepCompleted),
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
                            const Duration(milliseconds: 800)),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.24),
                  child: const Text(
                    "Continue",
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
