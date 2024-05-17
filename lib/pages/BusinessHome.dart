import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../classes/UserData.dart';
import '../constants/ThemeConstants.dart';
import '../widgets/BusinessListedWidget.dart';
import 'package:provider/provider.dart';

class BusinessHomePage extends StatefulWidget {
  const BusinessHomePage({super.key, required this.title});
  final String title;

  @override
  State<BusinessHomePage> createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHomePage> {
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
              top: 15,
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
                            contentPadding: EdgeInsets.all(8),
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
                        const CircleAvatar(
                          radius: 70,
                          backgroundImage: AssetImage(
                              'assets/avatar_image.jpg'), // Replace this with your image asset
                        ),
                        const SizedBox(
                            width:
                                10), // Adding space between CircleAvatar and Container
                        Container(
                          height: 80,
                          width: screenWidth * 0.56,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey, // Example background color
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))),
            Positioned(
                top: 260,
                left: 15,
                child: Container(
                  height: 120,
                  width: 360,
                  color: Colors.grey,
                )),
            const Positioned(
                left: 15,
                top: 400,
                child: (Text(
                  "Establishments",
                  style: TextStyle(fontSize: 24),
                ))),
            Container(
              margin: EdgeInsets.fromLTRB(0, screenHeight * 0.53, 0, 0),
              child: ListView.builder(
                itemCount: 5, //dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  // Generate a widget based on the data
                  return const CustomCard(
                    imageUrl:
                        "https://th.bing.com/th/id/OIP.KoKk_vYZW-dFP-YSdRSOZwHaEo?rs=1&pid=ImgDetMain",
                    title: "The Swan Inn",
                    tags: "Craft Beer | Ales | Food | Music",
                    popularity: 'As busy as it gets',
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
