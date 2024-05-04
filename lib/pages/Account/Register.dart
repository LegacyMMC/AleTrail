import 'package:AleTrail/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_api_controller.dart';
import '../UserMap.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});
  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // User Define Parameters
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
                      clientUserName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email address',
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
                      obscureText: true,
                      onChanged: (value) {
                        clientPassword = value;
                      },
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
                  0.83, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Material(
                    elevation: 25, // Set the elevation here
                    borderRadius: BorderRadius.circular(50),
                    child: TextField(
                      obscureText: true,
                      onChanged: (value) {
                        clientConfirmPassword = value;
                      },
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
                top: registerButtonTop *
                    0.94, // Adjust this value according to your layout
                right: screenWidth * 0.52,
                child: Visibility(
                    visible: passwordMatch,
                    child: const Text(
                      "Passwords don't match!",
                      style: TextStyle(
                          color: failureText, fontWeight: FontWeight.bold),
                    ))),
            Positioned(
                top: registerButtonTop *
                    0.94, // Adjust this value according to your layout
                right: screenWidth * 0.52,
                child: Visibility(
                    visible: passwordMatch,
                    child: const Text(
                      "Failed to register account!",
                      style: TextStyle(
                          color: failureText, fontWeight: FontWeight.bold),
                    ))),
            Positioned(
              top: registerButtonTop * 1,
              right: screenWidth * 0.11,
              child: ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () async {
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
                        final userId = signinResponseCode?.user!.uid;
                        if (userId!.isNotEmpty) {
                          // Navigate away from page
                          Navigator.of(context).push(
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const UserMapPage(title: ""),
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
                          // HANDLE WHEN USER IS NOT FOUND
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
              top: registerButtonTop * 1.18, // Adjusted position for icons
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Evenly distribute icons
                children: [
                  SvgPicture.asset(
                    height: 35,
                    "lib/assets/images/svg/GoogleIcon.svg",
                    semanticsLabel: 'Yellow Corner SVG',
                  ),
                  SvgPicture.asset(
                    height: 35,
                    "lib/assets/images/svg/InstaLogo.svg",
                    semanticsLabel: 'Yellow Corner SVG',
                  ),
                  SvgPicture.asset(
                    height: 35,
                    "lib/assets/images/svg/TwitterIcon.svg",
                    semanticsLabel: 'Yellow Corner SVG',
                  ),
                ],
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
