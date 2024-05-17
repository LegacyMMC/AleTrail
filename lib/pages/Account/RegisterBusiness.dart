import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/AccountType.dart';
import '../../firebase_api_controller.dart';
import '../BusinessHome.dart';

class RegisterBusinessPage extends StatefulWidget {
  const RegisterBusinessPage({super.key, required this.title});
  final String title;

  @override
  State<RegisterBusinessPage> createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  // User Define Parameters
  String clientCompanyName = ''; // Define as instance variable
  String clientUserName = ''; // Define as instance variable
  String clientPassword = ''; // Define as instance variable
  String clientConfirmPassword = ''; // Define as instance variable

  bool passwordMatch = false;
  bool failedToRegister = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 110;
    final double aleTrailTitleTop = screenHeight * 0.2;
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
              right: screenWidth * 0.17,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AleTrailtitle.svg",
                semanticsLabel: 'AleTrail Title SVG',
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.57, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25, // Set the elevation here
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    onChanged: (value) {
                      clientCompanyName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Company Name',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                            color: primaryButton), // Orange border when focused
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(
                          10, 0, 10, 0), // Adjust height here
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.7, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25, // Set the elevation here
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    onChanged: (value) {
                      clientUserName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                            color: primaryButton), // Orange border when focused
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(
                          10, 0, 10, 0), // Adjust height here
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: registerButtonTop *
                  0.83, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Material(
                    elevation: 25, // Set the elevation here
                    borderRadius: BorderRadius.circular(50),
                    child: TextField(
                      onChanged: (value) {
                        clientPassword = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              color:
                                  secondaryButton), // Orange border when focused
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                            10, 0, 10, 0), // Adjust height here
                      ),
                    ),
                  )),
            ),
            Positioned(
              top: registerButtonTop *
                  0.95, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Material(
                    elevation: 25, // Set the elevation here
                    borderRadius: BorderRadius.circular(50),
                    child: TextField(
                      onChanged: (value) {
                        clientConfirmPassword = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              color:
                                  secondaryButton), // Orange border when focused
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                            10, 0, 10, 0), // Adjust height here
                      ),
                    ),
                  )),
            ),
            Positioned(
              top: registerButtonTop * 1.13,
              right: screenWidth * 0.11,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
                  // Handle sign-in button press

                  // Handle register button press
                  if (clientPassword.isNotEmpty &&
                      clientUserName.isNotEmpty &&
                      clientConfirmPassword.isNotEmpty) {
                    if (clientPassword == clientConfirmPassword) {
                      final UserCredential? signinResponseCode =
                          await registerWithEmailAndPassword(
                        clientUserName,
                        clientConfirmPassword,
                      );
                      if (signinResponseCode != null ||
                          signinResponseCode?.user != null) {
                        final userAccount = signinResponseCode?.user;
                        if (userAccount?.uid != null &&
                            userAccount?.email != null) {
                          // Register User Against Firestore
                          await addNewClientToUserTable(
                              userAccount!.uid,
                              userAccount.displayName.toString(),
                              userAccount.email,
                              AccountType().businessUser,
                              clientCompanyName: clientCompanyName);
                          // Navigate away from page
                          Navigator.of(context).pushReplacement (
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const BusinessHomePage(title: ""),
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
                        } else {
                          // HANDLE WHEN USER IS NOT REGISTERED
                          setState(() {
                            failedToRegister =
                                true; // Use assignment operator to set the value
                          });
                        }
                      } else {
                        // HANDLE GENERAL SIGN IN FAILURES
                        setState(() {
                          failedToRegister =
                              true; // Use assignment operator to set the value
                        });
                      }
                    } else {
                      // HANDLE WHEN THE PASSWORD AND CONFIRM PASSWORD DON'T MATCH
                      setState(() {
                        passwordMatch =
                            true; // Use assignment operator to set the value
                      });
                    }
                  } else {
                    // HANDLE WHEN THE PASSWORD AND CONFIRM PASSWORD DON'T MATCH
                    setState(() {
                      failedToRegister =
                          true; // Use assignment operator to set the value
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                  child: const Text(
                    "Create account",
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
