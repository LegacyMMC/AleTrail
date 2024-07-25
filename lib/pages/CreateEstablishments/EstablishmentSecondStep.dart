import 'dart:io';

import 'package:AleTrail/pages/BusinessHome[LEGACY].dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/ThemeConstants.dart';
import '../../firebase_api_controller.dart';
import '../BusinessHome.dart';

class EstablishmentTwoPage extends StatefulWidget {
  final String docId;
  const EstablishmentTwoPage({super.key, required this.docId});

  @override
  State<EstablishmentTwoPage> createState() => _EstablishmentTwoPageState();
}

class _EstablishmentTwoPageState extends State<EstablishmentTwoPage> {
  File? _imageFile;
  String EstablishmentTagline = "";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final double orangeCornerBottom = screenHeight * 0.0000001 - 110;
    final double aleTrailTitleTop = screenHeight * 0.15;
    final double registerButtonTop = screenHeight * 0.65;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              top: registerButtonTop * 0.4,
              right: screenWidth * 0.085,
              child: GestureDetector(
                onTap: () async {
                  final pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _imageFile = File(pickedImage.path);
                    });
                  }
                },
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenWidth * 0.65,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryButton, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  1, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: Container(
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: secondaryButton, width: 2), // Outer border
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
                        EstablishmentTagline = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Establishment Tagline',
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
              right: screenWidth * 0.09,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
                  if (_imageFile != null) {
                    await updateNewVenueImage(
                        widget.docId, EstablishmentTagline, _imageFile);
                  } else if (EstablishmentTagline.isNotEmpty) {
                    await updateNewVenueImage(
                        widget.docId, EstablishmentTagline, null);
                  }

                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const BusinessHomePage(),
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
                        transitionDuration: const Duration(milliseconds: 800)),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.24),
                  child: const Text(
                    "Complete",
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
