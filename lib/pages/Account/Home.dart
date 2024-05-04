import 'package:AleTrail/constants/constants.dart';
import 'package:AleTrail/pages/Account/Login.dart';
import 'package:AleTrail/pages/Account/Register.dart';
import 'package:AleTrail/pages/Account/RegisterBusiness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Define relative positions and sizes based on screen dimensions
    final double orangeCornerBottom = screenHeight * 0.0000001 - 100;
    final double aleTrailTitleTop = screenHeight * 0.25;
    final double signInButtonTop = screenHeight * 0.55;
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
              top: signInButtonTop,
              right: screenWidth * 0.09,
              child: ElevatedButton(
                style: const ButtonStyle(elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(primaryButton),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        LoginPage(),
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
                        transitionDuration: const Duration(milliseconds: 500)),
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
              top: registerButtonTop,
              right: screenWidth * 0.07,
              child: ElevatedButton(
                style: const ButtonStyle(elevation: MaterialStatePropertyAll(15),
                  backgroundColor: MaterialStatePropertyAll(secondaryButton),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const RegisterPage(title: ""),
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
                    "Register",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/yellowCorner.svg",
                semanticsLabel: 'Yellow Corner SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.93,
              right: screenWidth * 0.31,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                        const RegisterBusinessPage(title: ""),
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
                child: const Text(
                    style: TextStyle(
                        color: secondaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                    'I am a business'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
