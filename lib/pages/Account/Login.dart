import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../classes/UserData.dart';
import '../../firebase_api_controller.dart';
import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:AleTrail/pages/BusinessHome[LEGACY].dart';
import 'package:AleTrail/pages/UserMap.dart';

import '../BusinessHome.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: screenHeight * 0.0000001 - 100,
              left: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/orangeCorner.svg",
                colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                semanticsLabel: 'Orange Corner SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.25,
              right: screenWidth * 0.17,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AleTrailtitle.svg",
                semanticsLabel: 'AleTrail Title SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.65 * 0.65,
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25,
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: primaryButton),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.65 * 0.8,
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25,
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: secondaryButton),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.65 * 1,
              right: screenWidth * 0.09,
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  backgroundColor: MaterialStateProperty.all(secondaryButton),
                ),
                onPressed: () async {
                  String username = _usernameController.text.trim();
                  String password = _passwordController.text.trim();

                  if (username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username cannot be empty.')),
                    );
                    return;
                  }
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(username)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid email address.')),
                    );
                    return;
                  }
                  if (password.isEmpty || password.length < 7) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password must be at least 7 characters long.')),
                    );
                    return;
                  }

                  final UserData? signinResponseCode = await signInWithEmailAndPassword(username, password);

                  if (signinResponseCode != null && signinResponseCode.userId != null) {
                    final userId = signinResponseCode.userId;
                    if (userId.isNotEmpty) {
                      Provider.of<UserProvider>(context, listen: false).setUser(signinResponseCode);
                      if (signinResponseCode.accountType == "Business") {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const BusinessHomePage(),
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
                      if (signinResponseCode.accountType == "General") {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const UserMapPage(title: ""),
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
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid username or password.')),
                    );
                  }
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
              top: screenHeight * 0.65 * 1.18,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      UserData? userData = await signInWithGoogle();
                      if (userData?.userId != null) {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const UserMapPage(title: ""),
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
                    child: SvgPicture.asset(
                      height: 35,
                      "lib/assets/images/svg/GoogleIcon.svg",
                      semanticsLabel: 'Google Icon',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Instagram Icon clicked');
                    },
                    child: SvgPicture.asset(
                      height: 35,
                      "lib/assets/images/svg/InstaLogo.svg",
                      semanticsLabel: 'Instagram Icon',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Twitter Icon clicked');
                    },
                    child: SvgPicture.asset(
                      height: 35,
                      "lib/assets/images/svg/TwitterIcon.svg",
                      semanticsLabel: 'Twitter Icon',
                    ),
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
