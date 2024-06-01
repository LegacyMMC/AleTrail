import 'dart:async';
import 'dart:ui' as ui;
import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_api_controller.dart';
import 'PubPage.dart';
import 'package:http/http.dart' as http;

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key, required this.title});
  final String title;

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  late GoogleMapController mapController;
  LatLng _initialCameraPosition =
      const LatLng(0, 0); // Default initial position
  late StreamSubscription<Position> _positionStreamSubscription;
  final Set<Marker> _markers = {}; // Set to store markers
  List<DocumentSnapshot<Object?>> nearbyEstablishments = [];

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    try {
      Position position = await _determinePosition();
      _updateCameraPosition(position.latitude, position.longitude);
      // User location to gather nearby establishments
      print("GETTING MARKERS:");
      nearbyEstablishments =
          await getNearbyEstablishments(position.latitude, position.longitude);
      for (var establishment in nearbyEstablishments) {
        var data = establishment.data() as Map<String, dynamic>;
        double lat = data['Latitude'];
        double lon = data['Longitude'];
        String establishmentId = data['EstablishmentId'];
        String establishmentName = data['EstablishmentName'];
        String establishmentImage = data['Image'];
        _addMarker(
            establishmentId, establishmentName, lat, lon, establishmentImage);
      }

      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        _updateCameraPosition(position.latitude, position.longitude);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    return await Geolocator.getCurrentPosition();
  }

  void _updateCameraPosition(double latitude, double longitude) {
    setState(() {
      _initialCameraPosition = LatLng(latitude, longitude);
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 20.0,
        ),
      ),
    );
  }

  Future<Uint8List> _getBytesFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromUrl(String url) async {
    final Uint8List imageData = await _getBytesFromUrl(url);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    final ui.Image image = await completer.future;

    const int imageWidth = 200;
    const int imageHeight = 200;
    const int boxWidth = 220;
    const int boxHeight = 270; // including tail
    const int tailHeight = 50;

    // Create a canvas to draw the marker
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // Draw the orange box
    final RRect boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          0, 0, boxWidth.toDouble(), boxHeight.toDouble() - tailHeight),
      Radius.circular(8),
    );
    canvas.drawRRect(boxRect, paint);

    // Draw the tail
    final Path tailPath = Path()
      ..moveTo(boxWidth / 2 - 10, boxHeight.toDouble() - tailHeight)
      ..lineTo(boxWidth / 2 + 10, boxHeight.toDouble() - tailHeight)
      ..lineTo(boxWidth / 2, boxHeight.toDouble())
      ..close();
    canvas.drawPath(tailPath, paint);

    // Resize and draw the image inside the box
    final Rect imageRect = Rect.fromLTWH(
      (boxWidth - imageWidth) / 2,
      (boxHeight - tailHeight - imageHeight) / 2,
      imageWidth.toDouble(),
      imageHeight.toDouble(),
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imageRect,
      Paint(),
    );

    final ui.Image markerImage =
        await recorder.endRecording().toImage(boxWidth, boxHeight);
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List markerImageData = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(markerImageData);
  }

  void _addMarker(String establishmentId, String establishmentName,
      double latitude, double longitude, String imageUrl) async {
    final BitmapDescriptor icon = await _bitmapDescriptorFromUrl(imageUrl);

    final marker = Marker(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PubInfoPage(pubId: establishmentId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(10.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
      markerId: MarkerId(establishmentId),
      position: LatLng(latitude, longitude),
      icon: icon,
      infoWindow: InfoWindow(
        title: establishmentName,
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _loadMarkers() {
    for (var establishment in nearbyEstablishments) {
      _addMarker(
        establishment['id'],
        establishment['name'],
        establishment['latitude'],
        establishment['longitude'],
        establishment[
            'imageUrl'], // Assuming each establishment has an 'imageUrl' field
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            buildingsEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            indoorViewEnabled: true,
            tiltGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: -10.0,
            ),
            markers: _markers, // Set the markers on the map
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            cloudMapId: "341f3f57546abed8",
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
                          hintText: 'Search bars, beers & business',
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
          DraggableScrollableSheet(
            initialChildSize: 0.1, // Initial size of the scrollable sheet
            minChildSize:
                0.1, // Minimum size to which the sheet can be dragged down
            maxChildSize:
                0.7, // Maximum size to which the sheet can be dragged up
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: nearbyEstablishments.length,
                  itemBuilder: (BuildContext context, int index) {
                    var establishment = nearbyEstablishments[index];
                    return ListTile(
                      leading: const Icon(Icons.local_bar),
                      title:
                          Text(establishment['EstablishmentName'] ?? 'Unnamed'),
                      subtitle:
                          Text(establishment['Tags'] ?? 'No details available'),
                      onTap: () {
                        // Handle list item tap
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
