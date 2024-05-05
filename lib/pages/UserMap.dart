import 'dart:async';

import 'package:AleTrail/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  late GoogleMapController mapController;
  LatLng _initialCameraPosition =
      const LatLng(0, 0); // Default initial position
  late StreamSubscription<Position> _positionStreamSubscription;
  bool _sideMenuVisible = false;

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
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        _updateCameraPosition(position.latitude, position.longitude);
        if (kDebugMode) {
          print(position.longitude);
        }
        if (kDebugMode) {
          print(position.latitude);
        }
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
              zoom: 55.0,
            ),
            cloudMapId: "341f3f57546abed8",
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
                  Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0, 0, 5, 0), // Add padding between TextField and Icon
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _sideMenuVisible = true;
                          });
                        },
                      )),
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
          Visibility(
              visible: _sideMenuVisible,
              child: Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 200, // Adjust the width as needed
                  color: primaryButton, // Adjust the color as needed
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _sideMenuVisible = false;
                                    });
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.xmark_circle,
                                    size: 35,
                                    color: Colors.black87,
                                  ),
                                )
                              ],
                            )),
                        ListTile(
                          title: const Text(
                            'Settings',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Handle menu item 1 press
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Profile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Handle menu item 1 press
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Recent Updates',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Handle menu item 1 press
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Report Issue',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Handle menu item 1 press
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Handle menu item 1 press
                          },
                        ),
                      ]),
                ),
              )),
        ],
      ),
    );
  }
}
