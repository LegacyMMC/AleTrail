import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../classes/SearchedItem.dart';
import '../constants/ThemeConstants.dart';
import '../firebase_api_controller.dart';
import 'UserEstablishmentViewPage.dart';
import 'package:image/image.dart' as img;

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key, required this.title});
  final String title;

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng _initialCameraPosition =
      const LatLng(0, 0); // Default initial position
  late StreamSubscription<Position> _positionStreamSubscription;
  double _offset = 0.0;

  late Set<Marker> _markers = {}; // Set to store markers
  Set<Marker> _copyMarkers =
      {}; // After first get store them so we can reload after searches

  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();
  double _previousExtent = 0.1;
  bool _isAtMinExtent = true;
  List<DocumentSnapshot<Object?>> nearbyEstablishments = [];
  bool mapTracker = true;
  late Timer _timer; // Declare a Timer variable
  bool _timerActive = false; // Flag to track if timer is active

  final TextEditingController _searchController = TextEditingController();
  List<SearchedItem> _searchResults = [];
  Timer? _debounce; // Debounce timer

  bool _setSearchText = false;
  bool _showSearchResults =
      false; // Boolean to track the visibility of the search results

  List<String> establishentDistances = [];

  @override
  void initState() {
    super.initState();
    _initUserLocation();

    // Add listener to searchController to perform search on text change with debouncing
    _searchController.addListener(() {
      final query = _searchController.text;
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (query.isNotEmpty) {
          _performSearch(query);
        } else {
          setState(() {
            _searchResults = [];
            _showSearchResults = false; // Hide the search results list
            _setSearchText = false; // Hide the search results list
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _searchController.dispose(); // Dispose the search controller
    _debounce?.cancel(); // Cancel the debounce timer if active
    super.dispose();
  }

  // Calculate distance in KM or meters between users location and establishments
  Future<String> calculateDistance(double lat2, double lon2) async {
    const double earthRadiusKm = 6371.0;

    // Users pos
    Position position = await _determinePosition();

    // Gather distance
    double dLat = _degreesToRadians(lat2 - position.latitude);
    double dLon = _degreesToRadians(lon2 - position.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(position.latitude)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceKm = earthRadiusKm * c;
    double distanceMeters = distanceKm * 1000;

    if (distanceMeters > 999) {
      return '${distanceKm.toStringAsFixed(2)} km';
    } else {
      return '${distanceMeters.toStringAsFixed(0)} meters';
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta.dy;
    });

    // Add your custom logic here
    if (details.delta.dy > 0) {
      _scrollableController.animateTo(
        0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    } else if (details.delta.dy < 0) {
      setState(() {
        _scrollableController.animateTo(
          1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<Uint8List> _resizeImage(Uint8List data, int width, int height) async {
    // Decode the image to a format suitable for manipulation
    img.Image? image = img.decodeImage(data);
    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // Resize the image
    img.Image resizedImage =
        img.copyResize(image, width: width, height: height);

    // Encode the resized image back to Uint8List
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<BitmapDescriptor> _createMarkerImageFromUrl(String imageUrl) async {
    final Uint8List bytes = await _getBytesFromUrl(imageUrl);
    final Uint8List resizedBytes =
        await _resizeImage(bytes, 200, 200); // Resize to desired size
    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  Future<Uint8List> _getBytesFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from $url');
    }
  }

  Future<void> _initUserLocation() async {
    try {
      Position position = await _determinePosition();
      _updateCameraPosition(position.latitude, position.longitude);
      var nearbyEstablishments =
          await getNearbyEstablishments(position.latitude, position.longitude);
      setState(() {
        this.nearbyEstablishments = nearbyEstablishments;
      });

      for (var establishment in nearbyEstablishments) {
        var data = establishment.data() as Map<String, dynamic>;
        double lat = data['Latitude'];
        double lon = data['Longitude'];
        String establishmentId = data['EstablishmentId'];
        String establishmentName = data['EstablishmentName'];
        String establishmentImage = data['Image'];

        // Add distance from user to establishment
        String distance = await calculateDistance(
            establishment['Latitude'], establishment['Longitude']);

        // Collection is used in the list builder for top 5 location menus
        establishentDistances.add(distance);

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
    if (mapTracker) {
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

  Future<void> _addMarker(String establishmentId, String establishmentName,
      double latitude, double longitude, String establishmentImage) async {
    // Generate Marker From Image
    final BitmapDescriptor customIcon =
        await _createMarkerImageFromUrl(establishmentImage);
    final marker = Marker(
        onTap: () => {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      UserEstablishmentViewPage(
                          pubId: establishmentId,
                          long: longitude,
                          latitude: latitude),
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
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              )
            },
        markerId: MarkerId(establishmentId),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: establishmentName,
        ),
        icon: customIcon);

    // Store copy of local markers
    _copyMarkers.add(marker);
    setState(() {
      _markers.add(marker);
    });
  }

  Future<BitmapDescriptor> createCustomMarkerBitmapWithText(String text) async {
    // Load the image

    final ByteData imageData = await DefaultAssetBundle.of(context)
        .load(r"lib/assets/images/png/PriceMarker.png");
    final Uint8List imageBytes = imageData.buffer.asUint8List();

    // Decode the image
    img.Image baseImage = img.decodeImage(imageBytes)!;

    // Draw the text over the image
    img.drawString(
        baseImage,
        font: img.arial48,
        x: 75,
        y: 25,
        text,
        color: img.ColorRgb8(255, 255, 255));

    // Encode the image to bytes
    final Uint8List markerImageBytes =
        Uint8List.fromList(img.encodePng(baseImage));

    // Convert the image to BitmapDescriptor
    final Completer<BitmapDescriptor> completer = Completer();
    ui.decodeImageFromList(markerImageBytes, (ui.Image img) async {
      final ByteData? byteData =
          await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
        completer.complete(BitmapDescriptor.fromBytes(resizedMarkerImageBytes));
      } else {
        completer.completeError('Failed to convert image to byte data');
      }
    });

    return completer.future;
  }

  Future<void> _addMarkerPrice(SearchedItem item) async {
    // Generate Marker From Image
    final BitmapDescriptor priceIcon =
        await createCustomMarkerBitmapWithText("\$${item.searchPrice}");

    final marker = Marker(
      onTap: () => {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UserEstablishmentViewPage(
                    pubId: item.searchEstablishment ?? "",
                    long: item.searchLon ?? 0.0,
                    latitude: item.searchLat ?? 0.0),
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
        )
      },
      icon: priceIcon,
      markerId: MarkerId(item.searchEstablishment ?? ""),
      position: LatLng(item.searchLat ?? 0.0, item.searchLon ?? 0.0),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  Future<void> _performSearch(String searchTerm) async {
    if (_setSearchText == false) {
      final searchTermLower = searchTerm.toLowerCase();

      // Query the search_indexes collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('SearchIndex')
          .where('Terms', arrayContains: searchTermLower)
          .get();

      // Fetch the document references and get the full documents
      List<SearchedItem> results = [];
      for (var doc in querySnapshot.docs) {
        // Form new searched item
        SearchedItem gatheredItem = SearchedItem(
            searchName: doc['ActualName'],
            searchType: doc['Type'],
            searchRef: doc['Ref']);
        if (gatheredItem.searchType == "Product") {
          gatheredItem.searchPrice = doc['Price'];
          gatheredItem.searchLat = doc['Latitude'];
          gatheredItem.searchLon = doc['Longitude'];
          gatheredItem.searchEstablishment = doc['EstablishmentRef'];
        }

        // Add to results
        results.add(gatheredItem);
      }

      setState(() {
        _searchResults = results;
        _showSearchResults = results
            .isNotEmpty; // Show the search results list if there are results
      });
    }
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            onTap: (argument) {
              setState(() {
                _searchController.text = '';
                _scrollableController.animateTo(
                  0.1,
                  duration: const Duration(milliseconds: 40),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _isAtMinExtent = true;
                  _showSearchResults = false; // Hide the search results list
                  _setSearchText = false; // Hide the search results list
                });
              });
            },
            buildingsEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            indoorViewEnabled: true,
            style: mapStyle,
            tiltGesturesEnabled: true,
            compassEnabled: false,
            trafficEnabled: false,
            fortyFiveDegreeImageryEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 10.0,
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 7,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _setSearchText = false;
                              });
                            },
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search bars, beers & businesses...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  // Clear the search field
                                  _searchController.clear();
                                  // Reset any additional states or actions
                                  setState(() {
                                    _showSearchResults = false;
                                    // Clear price markets
                                    _markers.clear();

                                    // Restore From Copy
                                    for (Marker storedMarker in _copyMarkers) {
                                      _markers.add(storedMarker);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: _showSearchResults
                        ? 300
                        : 0, // Animate the height of the container
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 7,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _showSearchResults
                        ? ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              var result = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.local_bar),
                                title: Text(result.searchName ?? 'Unnamed'),
                                subtitle: Text(result.searchType ??
                                    'No details available'),
                                onTap: () {
                                  setState(() {
                                    // Hide search drop down
                                    _showSearchResults = false;
                                    _setSearchText = true;

                                    // Set Search bar text to found item name
                                    _searchController.text = result.searchName;

                                    // Update map icons to price icons
                                    _markers.clear();
                                    for (SearchedItem searchedItem
                                        in _searchResults) {
                                      _addMarkerPrice(searchedItem);
                                    }
                                  });
                                },
                              );
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (mapTracker == false) {
                _scrollableController.animateTo(
                  0.05,
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
                    0.05,
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
              initialChildSize:
                  0.03, // Reduced initial size of the scrollable sheet
              minChildSize:
                  0.03, // Reduced minimum size to which the sheet can be dragged down
              maxChildSize: 0.7, // Keeping the maximum size as is
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  children: [
                    // Top part with orange color
                    GestureDetector(
                      onVerticalDragUpdate: _handleDragUpdate,
                      child: Container(
                        height: 20, // Adjust the height as needed
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: secondaryButton,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Rest of the draggable sheet
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: nearbyEstablishments.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return const Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Text(
                                        "Whats in your area",
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
                              var establishment =
                                  nearbyEstablishments[index - 1];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.local_bar,
                                    color:
                                        Colors.orange, // Change the icon color
                                  ),
                                  title: Text(
                                    establishment['EstablishmentName'] ??
                                        'Unnamed',
                                    style: const TextStyle(
                                      color:
                                          Colors.black, // Change the text color
                                      fontWeight: FontWeight
                                          .bold, // Optional: Make the text bold
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Aligns the texts to the start
                                    children: [
                                      Text(
                                        establishment['Tags'] ?? '',
                                        style: const TextStyle(
                                          color: Colors
                                              .grey, // Change the subtitle color
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              4), // Adds space between the texts
                                      Text(
                                        establishentDistances[index - 1] ?? "",
                                        style: const TextStyle(
                                          color: Colors
                                              .blueGrey, // Customize this color as needed
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Toggle Map Auto move
                                    setState(() {
                                      // Navigate to location on map
                                      _updateCameraPosition(
                                          establishment['Latitude'],
                                          establishment['Longitude']);
                                      mapTracker = false;
                                      // Start timer
                                      startTimer();
                                    });
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
