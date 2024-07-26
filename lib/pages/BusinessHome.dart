import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../classes/BusinessEstablishment.dart';
import '../constants/ThemeConstants.dart';
import '../firebase_api_controller.dart';
import '../widgets/BusinessEstablishmentWidget.dart';
import 'BusinessAllMenusView.dart';
import 'CreateEstablishments/EstablishmentFirstStep.dart';
import 'package:image_picker/image_picker.dart';

// Init Global
double screenWidth = 0.0;
double screenHeight = 0.0;
List<BusinessEstablishment> establishmentList = [];
bool pubInfoGet = false;
String compId = "";

// INIT GLOBAL PARAMS
File? _imageFile;
bool imageRefresh = false;

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({
    super.key,
  });

  @override
  _BusinessHomeV2State createState() => _BusinessHomeV2State();
}

class _BusinessHomeV2State extends State<BusinessHomePage> {
  String? selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCompId();
    _fetchEstablishments();
  }

  Future<void> _getCompId() async {
    try {
      compId = (getterCompId())!;
    } catch (e) {
      setState(() {
        // If we can't get this information then the page wont load so just show this for now
        _isLoading = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _fetchEstablishments() async {
    try {
      List<Map<String, dynamic>>? data = await getBusinessEstablishments();

      if (data != null && data.isNotEmpty) {
        establishmentList = data
            .map((data) => BusinessEstablishment(
                  establishmentName: data['EstablishmentName'] ?? '',
                  establishmentDesc: data['Tags'] ?? '',
                  establishmentImage: data['Image'] ?? '',
                  establishmentRef: data['EstablishmentId'] ?? '',
                ))
            .toList();
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching menu items: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          CompInfoWidget(
            compId: compId,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, screenHeight * 0.4, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : establishmentList.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 2.0,
                                  mainAxisSpacing: 0.0,
                                ),
                                itemCount: establishmentList.length,
                                itemBuilder: (context, index) {
                                  return BuisnessEstablishmentWidget(
                                    establishmentName: establishmentList[index]
                                        .establishmentName,
                                    establishmentDesc: establishmentList[index]
                                        .establishmentDesc,
                                    establishmentImage: establishmentList[index]
                                        .establishmentImage,
                                    establishmentId: establishmentList[index]
                                        .establishmentRef,
                                  );
                                },
                              )
                            : const Center(
                                child: Text(
                                  "No venues are setup. Please create one...",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompInfoWidget extends StatelessWidget {
  final String compId;

  const CompInfoWidget({required this.compId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('AleTrailUsers')
          .doc(compId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Pub not found'));
        }

        var compData = snapshot.data!.data() as Map<String, dynamic>;
        var compName = compData['CompanyName'] ?? "";
        var compImage = compData['ProfileImage'] ?? "";

        return Stack(children: [
          Positioned(
            child: Container(
              height: screenHeight,
              color: Colors.white,
            ),
          ),
          Positioned(
            child: Container(
              height: 210,
              width: screenWidth,
              color: primaryButton,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    compName,
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "A place for amazing stuff",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 150,
              height: 160,
              width: 400,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * 0.13), // Adjust padding here
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    backgroundColor: primaryButton,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const EstablishmentOnePage(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = const Offset(10.0, 0.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 800),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "New Venue",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    backgroundColor: secondaryButton,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const BusinessAllMenusView(pubId: "" ,),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return child;
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Menus",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      )))),
          Positioned(
            top: screenHeight * 0.16,
            left: screenWidth * 0.345,
            child: GestureDetector(
                onTap: () async {
                  final pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    _imageFile = File(pickedImage.path);

                    // Upload
                    updateProfileImage(_imageFile);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'New image uploaded. This will show on your next login!')),
                    );
                  }
                },
                child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider<Object>
                        : (compImage != null
                            ? NetworkImage(compImage) as ImageProvider<Object>
                            : null))),
          ),
        ]);
      },
    );
  }
}
