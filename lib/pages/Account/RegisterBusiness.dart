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
  // Controllers for text fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordMatch = false;
  bool _failedToRegister = false;

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
              bottom: screenHeight * 0.0000001 - 110,
              left: 0,
              child: SvgPicture.asset(
                "lib/assets/images/svg/orangeCorner.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.orange,
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'Orange Corner SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.2,
              right: screenWidth * 0.17,
              child: SvgPicture.asset(
                "lib/assets/images/svg/AleTrailtitle.svg",
                semanticsLabel: 'AleTrail Title SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.4,
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25,
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                      hintText: 'Company Name',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: primaryButton),
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
              top: screenHeight * 0.5,
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25,
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: primaryButton),
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
              top: screenHeight * 0.6,
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
              top: screenHeight * 0.7,
              right: screenWidth * 0.085,
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Material(
                  elevation: 25,
                  borderRadius: BorderRadius.circular(50),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
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
              top: screenHeight * 0.9,
              right: screenWidth * 0.11,
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  backgroundColor: MaterialStateProperty.all(secondaryButton),
                ),
                onPressed: () async {
                  String companyName = _companyNameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  String confirmPassword = _confirmPasswordController.text.trim();

                  if (companyName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Company name cannot be empty.')),
                    );
                    return;
                  }
                  if (email.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid email address.')),
                    );
                    return;
                  }
                  if (password.isEmpty || !_isPasswordSecure(password)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password must be at least 7 characters long and include an uppercase letter and a special character.')),
                    );
                    return;
                  }
                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match!')),
                    );
                    return;
                  }

                  if (_isPasswordSecure(password)) {
                    final UserCredential? signInResponseCode =
                    await registerWithEmailAndPassword(email, password);
                    if (signInResponseCode != null && signInResponseCode.user != null) {
                      final userAccount = signInResponseCode.user;
                      if (userAccount?.uid != null && userAccount?.email != null) {
                        await addNewClientToUserTable(
                          userAccount!.uid,
                          userAccount.displayName ?? '',
                          userAccount.email!,
                          AccountType().businessUser,
                          clientCompanyName: companyName,
                        );
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const BusinessHomePage(title: ""),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              final begin = const Offset(10.0, 0.0);
                              final end = Offset.zero;
                              final curve = Curves.easeInOutCubic;
                              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 800),
                          ),
                        );
                      } else {
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sorry! Account failed to register. This account might already been registered')),
                          );
                        });
                      }
                    } else {
                      setState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sorry! Account failed to register. This account might already been registered')),
                        );
                      });
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                  child: const Text(
                    "Create Account",
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

  bool _isPasswordSecure(String password) {
    if (password.length < 7) return false;

    bool hasUppercase = false;
    bool hasSpecialChar = false;

    for (int i = 0; i < password.length; i++) {
      final char = password[i];
      if (char.toUpperCase() != char) hasUppercase = true;
      if (!_isAlphaNumeric(char)) hasSpecialChar = true;
    }

    return hasUppercase && hasSpecialChar;
  }

  bool _isAlphaNumeric(String char) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(char);
  }
}
