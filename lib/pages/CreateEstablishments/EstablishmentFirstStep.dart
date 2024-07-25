import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../firebase_api_controller.dart';
import 'EstablishmentSecondStep.dart';

class EstablishmentOnePage extends StatefulWidget {
  const EstablishmentOnePage({super.key});

  @override
  State<EstablishmentOnePage> createState() => _EstablishmentOnePageState();
}

class _EstablishmentOnePageState extends State<EstablishmentOnePage> {
  // User parameters
  String establishmentName = "";
  String establishmentAddress = "";
  String establishmentDesc = "";

  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));
    _addressFocusNode.addListener(() => setState(() {}));
    _descFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    _descFocusNode.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 110;
    final double aleTrailTitleTop = screenHeight * 0.135;
    final double registerButtonTop = screenHeight * 0.65;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard appears
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: orangeCornerBottom,
              left: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/orangeCorner.svg",
                colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
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
              top: registerButtonTop * 0.43, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(color: _nameFocusNode.hasFocus ? primaryButton : Colors.grey, width: 1), // Outer border
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
                      focusNode: _nameFocusNode,
                      keyboardType: TextInputType.name,
                      maxLines: null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        establishmentName = value;
                      },
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: 'Registered Display Name',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 20, 15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop * 0.57, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(color: _addressFocusNode.hasFocus ? primaryButton : Colors.grey, width: 1), // Outer border
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
                      focusNode: _addressFocusNode,
                      controller: _addressController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        establishmentAddress = value;
                      },
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: 'Establishment Postcode',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 20, 15), // Adjust padding for multi-line support
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: registerButtonTop * 0.73, // Adjust this value according to your layout
                right: screenWidth * 0.055,
                child: const Text(
                  "This will be visible to users when selecting the venue",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                )
            ),
            Positioned(
              top: registerButtonTop * 0.79, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(color: _descFocusNode.hasFocus ? primaryButton : Colors.grey, width: 1), // Outer border
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  elevation: 35, // Set the elevation here
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 220, // Set the desired height for multi-line support
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      focusNode: _descFocusNode,
                      keyboardType: TextInputType.multiline,
                      maxLines: null, // Allows the TextField to support multiple lines
                      onChanged: (value) {
                        establishmentDesc = value;
                      },
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        hintText: 'Description',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.fromLTRB(15, 15, 20, 15), // Adjust padding for multi-line support
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
                  // Validation checks
                  final postcodeRegExp = RegExp(r'^[A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}$', caseSensitive: false);
                  final descriptionWordCount = establishmentDesc.split(RegExp(r'\s+')).length;

                  if (establishmentName.length <= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registered Display Name must be longer than 5 characters.')),
                    );
                    return;
                  }

                  if (!postcodeRegExp.hasMatch(establishmentAddress)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid postcode.')),
                    );
                    return;
                  }

                  if (descriptionWordCount > 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Description must be less than 10 words.')),
                    );
                    return;
                  }

                  // Proceed if all validations pass
                  String stepCompleted = await addNewVenueToFirebase(establishmentName, establishmentAddress);
                  if (stepCompleted != "") {
                    // Navigate to step two
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            EstablishmentTwoPage(docId: stepCompleted),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(10.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
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
