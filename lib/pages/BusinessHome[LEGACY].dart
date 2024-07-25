// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../classes/UserData.dart';
// import '../constants/ThemeConstants.dart';
// import '../firebase_api_controller.dart';
// import '../widgets/BusinessListedWidget.dart';
// import 'package:provider/provider.dart';
// import 'BusinessAllMenusView.dart';
// import 'CreateEstablishments/EstablishmentFirstStep.dart';
// import 'package:image_picker/image_picker.dart';
//
// class BusinessHomePage extends StatefulWidget {
//   const BusinessHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<BusinessHomePage> createState() => _BusinessHomeState();
// }
//
// class _BusinessHomeState extends State<BusinessHomePage> {
//   late List<Map<String, dynamic>> dataList;
//
//   File? _imageFile;
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     final double screenWidth = screenSize.width;
//     final double screenHeight = screenSize.height;
//     final double orangeCornerBottom = screenWidth * 0.6;
//
//     UserData? clientProfileData = Provider.of<UserProvider>(context).user;
//
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           false, // Prevents resizing when keyboard appears
//       body: Container(
//         color: Colors.white,
//         child: Stack(
//           children: [
//             Positioned(
//               left: orangeCornerBottom,
//               bottom: screenHeight - 175,
//               child: SvgPicture.asset(
//                 "lib/assets/images/svg/TopRightOrange.svg",
//                 semanticsLabel: 'Orange Corner SVG',
//               ),
//             ),
//             Positioned(
//                 top: 40,
//                 left: 10,
//                 child: SizedBox(
//                   height: 200,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       GestureDetector(
//                           onTap: () async {
//                             final pickedImage = await ImagePicker()
//                                 .pickImage(source: ImageSource.gallery);
//                             if (pickedImage != null) {
//                               setState(() {
//                                 // Set file
//                                 _imageFile = File(pickedImage.path);
//
//                                 // Upload
//                                 updateProfileImage(_imageFile);
//                               });
//                             }
//                           },
//                           child: CircleAvatar(
//                               radius: 70,
//                               backgroundImage: _imageFile != null
//                                   ? FileImage(_imageFile!)
//                                       as ImageProvider<Object>
//                                   : (clientProfileData != null
//                                       ? NetworkImage(
//                                               clientProfileData.profileImage)
//                                           as ImageProvider<Object>
//                                       : null))),
//                       const SizedBox(width: 10),
//                       Material(
//                         elevation: 15.0, // Add elevation here
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           height: 60,
//                           width: screenWidth * 0.56,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white, // Example background color
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: <Widget>[
//                               Text(
//                                 clientProfileData != null
//                                     ? clientProfileData.companyName
//                                     : 'Your Account',
//                                 style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: primaryButton,
//                                     letterSpacing: 2.75),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//             Positioned(
//               top: 240,
//               left: 15,
//               child: Material(
//                 elevation: 20.0,
//                 borderRadius: BorderRadius.circular(
//                     15.0), // To match the Container's borderRadius
//                 child: Container(
//                   height: 180, // Increased height to accommodate new elements
//                   width: 360,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(
//                         10.0), // Add padding around the container
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Row(
//                           children: [
//                             Icon(
//                               Icons.business, // Add a business icon
//                               color: Colors.orange, // Set icon color
//                               size: 30,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               "Business Account", // Add a title
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Manage your venues and menus easily. Create a new venue or update your existing menus with just a few clicks.",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         const Spacer(), // Push the buttons to the bottom
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(
//                               width: 150,
//                               height: 40,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   elevation: 1,
//                                   backgroundColor: primaryButton,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).push(
//                                     PageRouteBuilder(
//                                       pageBuilder: (context, animation,
//                                               secondaryAnimation) =>
//                                           const EstablishmentOnePage(),
//                                       transitionsBuilder: (context, animation,
//                                           secondaryAnimation, child) {
//                                         var begin = const Offset(10.0, 0.0);
//                                         var end = Offset.zero;
//                                         var curve = Curves.ease;
//
//                                         var tween = Tween(
//                                                 begin: begin, end: end)
//                                             .chain(CurveTween(curve: curve));
//
//                                         return SlideTransition(
//                                           position: animation.drive(tween),
//                                           child: child,
//                                         );
//                                       },
//                                       transitionDuration:
//                                           const Duration(milliseconds: 800),
//                                     ),
//                                   );
//                                 },
//                                 child: const Text(
//                                   "New Venue",
//                                   style: TextStyle(
//                                       fontSize: 20, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 150,
//                               height: 40,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   elevation: 1,
//                                   backgroundColor: secondaryButton,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).push(
//                                     PageRouteBuilder(
//                                       pageBuilder: (context, animation,
//                                               secondaryAnimation) =>
//                                           const BusinessAllMenusView(),
//                                       transitionDuration: Duration.zero,
//                                       reverseTransitionDuration: Duration.zero,
//                                       transitionsBuilder: (context, animation,
//                                           secondaryAnimation, child) {
//                                         return child;
//                                       },
//                                     ),
//                                   );
//                                 },
//                                 child: const Text(
//                                   "Menus",
//                                   style: TextStyle(
//                                       fontSize: 20, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 left: 15,
//                 top: screenHeight * 0.58,
//                 child: (const Text(
//                   "Establishments",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ))),
//             Positioned(
//               top: screenHeight * 0.65,
//               right: 0,
//               left: 0,
//               child: Container(
//                 height:
//                     screenHeight * 0.4, // Set a fixed height for the container
//                 margin: EdgeInsets.zero,
//                 child: FutureBuilder<List<Map<String, dynamic>>?>(
//                   future: getBusinessEstablishments(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       // Show loading indicator while data is being fetched
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (snapshot.hasError) {
//                       // Show error message if there's an error
//                       return Center(
//                         child: Text('Error: ${snapshot.error}'),
//                       );
//                     } else if (snapshot.hasData) {
//                       // Build ListView based on the data received
//                       dataList = snapshot.data!;
//                       return ListView.builder(
//                         padding: EdgeInsets.zero,
//                         itemCount: dataList.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           Map<String, dynamic> data = dataList[index];
//                           // Generate a widget based on the data
//                           return BusinessCard(
//                             imageUrl: data['Image'] ?? '',
//                             title: data['EstablishmentName'] ?? '',
//                             tags: data['Tags'] ?? '',
//                             popularity: data['Popularity'] ?? '',
//                             pubId: data['EstablishmentId'] ?? '',
//                           );
//                         },
//                       );
//                     } else {
//                       // Show a message if there's no data
//                       return const Center(
//                         child: Text('No data available'),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
