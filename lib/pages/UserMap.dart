import 'dart:async';
import 'package:AleTrail/constants/ThemeConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_api_controller.dart';
import 'PubPage.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key, required this.title});
  final String title;

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  late GoogleMapController mapController;
  LatLng _initialCameraPosition = const LatLng(0, 0); // Default initial position
  late StreamSubscription<Position> _positionStreamSubscription;
  bool _sideMenuVisible = false;
  final Set<Marker> _markers = {}; // Set to store markers
  final DraggableScrollableController _scrollableController = DraggableScrollableController();
  double _previousExtent = 0.1;
  bool _isAtMinExtent = true;
  List<DocumentSnapshot<Object?>> nearbyEstablishments = [];
  bool mapTracker = true;
  late Timer _timer; // Declare a Timer variable
  bool _timerActive = false; // Flag to track if timer is active

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _initUserLocation() async {
    try {
      Position position = await _determinePosition();
      _updateCameraPosition(position.latitude, position.longitude);
      // User location to gather nearby establishments
      print("GETTING MARKERS:");
      var nearbyEstablishments = await getNearbyEstablishments(position.latitude, position.longitude);
      setState(() {
        this.nearbyEstablishments = nearbyEstablishments;
      });

      for (var establishment in nearbyEstablishments) {
        var data = establishment.data() as Map<String, dynamic>;
        double lat = data['Latitude'];
        double lon = data['Longitude'];
        String establishmentId = data['EstablishmentId'];
        String establishmentName = data['EstablishmentName'];
        _addMarker(establishmentId, establishmentName, lat, lon);
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
    if (mapTracker){
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
  }

  void _addMarker(String establishmentId, String establishmentName,  double latitude, double longitude) {
    final marker = Marker(
      onTap: () => {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation,
                secondaryAnimation) => PubInfoPage(pubId: establishmentId),
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
        )
      },
      markerId: MarkerId(establishmentId),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: establishmentName,
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }


  void startTimer() {
    const duration = Duration(seconds: 3);
    _timer = Timer(duration, () {
      // Code to execute when timer completes
      setState(() {
        _timerActive = false; // Update timer active status
        mapTracker = true;
      });
    });

    setState(() {
      _timerActive = true; // Update timer active status
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            buildingsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            indoorViewEnabled: true,
            tiltGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 20.0,
            ),
            markers: _markers, // Set the markers on the map
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
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
                        borderRadius: BorderRadius.circular(20), // Adjust the radius to your preference
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 7,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
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
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if(mapTracker == false)
              {
                _scrollableController.animateTo(
                  0.1,
                  duration: const Duration(milliseconds: 40),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _isAtMinExtent = true;
                });
              }
              if (notification.extent > _previousExtent) {
                if (notification.extent >= 0.2) {
                  _scrollableController.animateTo(
                    0.7,
                    duration: const Duration(milliseconds: 40),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    _isAtMinExtent = false;
                  });
                }
              } else {
                if (notification.extent <= 0.6) {
                  _scrollableController.animateTo(
                    0.1,
                    duration: const Duration(milliseconds: 40),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    _isAtMinExtent = true;
                  });
                }
              }
              _previousExtent = notification.extent;
              return true;
            },
            child: DraggableScrollableSheet(
              controller: _scrollableController,
              initialChildSize: 0.1, // Initial size of the scrollable sheet
              minChildSize: 0.1, // Minimum size to which the sheet can be dragged down
              maxChildSize: 0.7, // Maximum size to which the sheet can be dragged up
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
                    itemCount: nearbyEstablishments.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 9, 10, 10),
                                child: Text(
                                  "Top 5 locations",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        var establishment = nearbyEstablishments[index - 1];
                        return ListTile(
                          leading: const Icon(Icons.local_bar),
                          title: Text(establishment['EstablishmentName'] ?? 'Unnamed'),
                          subtitle: Text(establishment['Tags'] ?? 'No details available'),
                          onTap: () {
                            // Toggle Map Auto move
                            setState(() {
                              // Navigate to location on map
                              _updateCameraPosition(establishment['Latitude'], establishment['Longitude']);
                              mapTracker = false;
                              // Start timer
                              startTimer();
                            });
                          },
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

