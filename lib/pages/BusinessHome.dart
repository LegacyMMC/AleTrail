import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../classes/UserData.dart';
import '../constants/ThemeConstants.dart';
import '../firebase_api_controller.dart';
import '../widgets/BusinessListedWidget.dart';
import 'package:provider/provider.dart';
import 'CreateEstablishments/EstablishmentFirstStep.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key, required this.title});
  final String title;

  @override
  State<BusinessHomePage> createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHomePage> {
  late List<Map<String, dynamic>> dataList;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double orangeCornerBottom = screenWidth * 0.6;

    UserData? clientProfileData = Provider.of<UserProvider>(context).user;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when keyboard appears
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: orangeCornerBottom,
              bottom: screenHeight - 175,
              child: SvgPicture.asset(
                "lib/assets/images/svg/TopRightOrange.svg",
                semanticsLabel: 'Orange Corner SVG',
              ),
            ),
            Positioned(
              top: screenHeight * 0.04,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  // Wrap TextField and Icon in a Row
                  children: [
                    Expanded(
                      // Use Expanded to make TextField take remaining space
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              20), // Adjust the radius to your preference
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 7,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            focusColor: mainBackground,
                            hintText: 'Locations & products...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: 10,
              child: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: clientProfileData != null
                          ? NetworkImage(clientProfileData.profileImage)
                          : const NetworkImage(
                              'https://th.bing.com/th/id/R.89b03ac4a277e619f490764482e65b96?rik=zGIq7bmU6dsPBg&pid=ImgRaw&r=0'),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      elevation: 15.0, // Add elevation here
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 80,
                        width: screenWidth * 0.56,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, // Example background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              clientProfileData != null
                                  ? clientProfileData.companyName
                                  : 'N/A',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryButton,
                                  letterSpacing: 2.75),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 260,
              left: 15,
              child: Material(
                elevation: 20.0,
                borderRadius: BorderRadius.circular(
                    15.0), // To match the Container's borderRadius
                child: Container(
                  height: 180, // Increased height to accommodate new elements
                  width: 360,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        10.0), // Add padding around the container
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.business, // Add a business icon
                              color: Colors.orange, // Set icon color
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Business Account", // Add a title
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Manage your venues and menus easily. Create a new venue or update your existing menus with just a few clicks.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(), // Push the buttons to the bottom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 15,
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
                                  elevation: 15,
                                  backgroundColor: secondaryButton,
                                ),
                                onPressed: () {
                                  // Add your onPressed logic here
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                left: 15,
                top: screenHeight * 0.58,
                child: (const Text(
                  "Establishments",
                  style: TextStyle(fontSize: 24),
                ))),
            Positioned(
              top: screenHeight * 0.63,
              right: 0,
              left: 0,
              child: Container(
                height:
                    screenHeight * 0.4, // Set a fixed height for the container
                margin: EdgeInsets.zero,
                child: FutureBuilder<List<Map<String, dynamic>>?>(
                  future: getBusinessEstablishments(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading indicator while data is being fetched
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      // Show error message if there's an error
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      // Build ListView based on the data received
                      dataList = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: dataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> data = dataList[index];
                          // Generate a widget based on the data
                          return BusinessCard(
                            imageUrl: data['Image'] ?? '',
                            title: data['EstablishmentName'] ?? '',
                            tags: data['Tags'] ?? '',
                            popularity: data['Popularity'] ?? '',
                            pubId: data['EstablishmentId'] ?? '',
                          );
                        },
                      );
                    } else {
                      // Show a message if there's no data
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
