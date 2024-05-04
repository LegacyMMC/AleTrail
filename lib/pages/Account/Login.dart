import 'package:AleTrail/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:AleTrail/pages/UserMap.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 100;
    final double aleTrailTitleTop = screenHeight * 0.25;
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
                  0.65, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25, // Set the elevation here
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Username',
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
                  0.8, // Adjust this value according to your layout
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25, // Set the elevation here
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                          color: secondaryButton), // Orange border when focused
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
              top: registerButtonTop * 1,
              right: screenWidth * 0.09,
              child: ElevatedButton(
                style: const ButtonStyle(elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () {
                  // Handle sign-in button press
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const UserMapPage(title: ""),
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
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.25),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 25, color: Colors.white),
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
