import 'dart:convert';
import 'dart:io' as io; // Import the IO library explicitly
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AleTrail/classes/UserData.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'classes/MenuProduct.dart';

/// GETTER FUNCTIONS FOR GLOBAL VARS

/// FIRE BASE AUTHENTICATION FUNCTIONS
String? getterCompId() {
  if (FirebaseAuth.instance.currentUser != null &&
      FirebaseAuth.instance.currentUser?.uid != null) {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}

// SignIn New User With Email and Password To Firebase Authentication
Future<UserData?> signInWithEmailAndPassword(
    String email, String password) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get UserData And Store Globally
    UserData? userData = await getUserDataFromFirestore();

    if (kDebugMode) {
      print('User Successfully SignedIn');
    }
    return userData;
  } catch (e) {
    // Handle sign-in errors
    if (kDebugMode) {
      print('Error signing in: $e');
    }
    return null; // Or throw an exception if you prefer
  }
}

Future<UserData?> signInWithUserToken(
    String accessToken, String idToken) async {
  try {
    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Get UserData And Store Globally
    UserData? userData = await getUserDataFromFirestore();

    if (kDebugMode) {
      print('User Successfully SignedIn');
    }
    if (userData?.userId != null) {
      // Cache Login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', credential.accessToken ?? "");
      await prefs.setString('id_token', credential.idToken ?? "");
      if (kDebugMode) {
        print('User Login Cached');
      }
    }
    return userData;
  } catch (e) {
    // Handle sign-in errors
    if (kDebugMode) {
      print('Error signing in: $e');
    }
    return null; // Or throw an exception if you prefer
  }
}

// Register New User With Email and Password To Firebase Authentication
Future<UserCredential?> registerWithEmailAndPassword(
    String email, String password) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  } catch (e) {
    // Handle registration errors
    if (kDebugMode) {
      print('Error registering user: $e');
    }
    return null; // Or throw an exception if you prefer
  }
}

// Sign in with google account
Future<UserData?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if user already sign in before (to add to user table)

    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('AletrailUsers');

    // Check if the document exists
    DocumentSnapshot userDoc =
        await usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();

    // Create document
    if (userDoc.exists == false) {
      await addNewClientToUserTable(
          FirebaseAuth.instance.currentUser!.uid,
          FirebaseAuth.instance.currentUser?.displayName ?? "",
          FirebaseAuth.instance.currentUser?.email,
          "General");
    }

    // Gather User Data
    UserData? userData = await getUserDataFromFirestore();

    // Cache Login
    if (userData?.userId != null) {
      // Cache Login
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', credential.accessToken ?? "");
      await prefs.setString('id_token', credential.idToken ?? "");
      if (kDebugMode) {
        print('User Login Cached');
      }
    }

    if (kDebugMode) {
      print('User Successfully SignedIn');
    }
    return userData;
  } catch (error) {
    if (kDebugMode) {
      print('Error signing in with Google: $error');
    }
  }
  return null;
}

/// Firebase Firestore Database Updates
Future<bool?> addNewClientToUserTable(
    String userID, String username, String? emailAddress, String accountType,
    {String? clientCompanyName}) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    // Create a new document reference with an auto-generated ID
    DocumentReference documentReference =
        firestoreInst.collection('AleTrailUsers').doc(userID);

    if (accountType == "General") {
      // Set the data of the document
      await documentReference.set({
        'UserID': userID,
        'Username': username,
        'EmailAddress': emailAddress,
        'AccountType': accountType
      });
    } else {
      // Set the data of the document
      await documentReference.set({
        'UserID': userID,
        'Username': username,
        'EmailAddress': emailAddress,
        'AccountType': accountType,
        'CompanyName': clientCompanyName,
        'ProfileImage': '',
      });
    }
    if (kDebugMode) {
      print('New user added to Firestore with ID: ${documentReference.id}');
    }

    return true; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding user to Firestore: $e');
    }
    return false; // Operation failed
  }
}

/// Firestore Get User Information
Future<UserData?> getUserDataFromFirestore() async {
  try {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection("AleTrailUsers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> userData = documentSnapshot.data()!;

      // If Business Get Company Name
      if (userData['AccountType'] == "Business") {
        UserData user = UserData(
          userId: userData['UserID'],
          userName: userData['Username'],
          accountType: userData['AccountType'],
          companyName: userData['CompanyName'],
          profileImage: userData['ProfileImage'],
        );

        UserProvider().setUser(user);
        return user;
      } else {
        UserData user = UserData(
            userId: userData['UserID'],
            userName: userData['Username'],
            accountType: userData['AccountType'],
            companyName: '');

        UserProvider().setUser(user);
        return user;
      }
    } else {
      if (kDebugMode) {
        print('Document does not exist');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error getting document from Firestore: $e");
    }
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getBusinessEstablishments() async {
  try {
    // Fetch the user document
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection("AleTrailUsers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (documentSnapshot.exists) {
      var userData = documentSnapshot.data();
      // Ensure the Establishments field is a List<dynamic>
      List<dynamic>? establishments =
          userData?['Establishments'] as List<dynamic>?;

      if (establishments != null) {
        List<Map<String, dynamic>> establishmentsInfo = [];

        // Loop through each establishment ID
        for (var establishmentId in establishments) {
          if (establishmentId is String) {
            // Fetch data from "EstablishmentSimple" collection using establishment ID
            DocumentSnapshot<Map<String, dynamic>> establishmentSnapshot =
                await FirebaseFirestore.instance
                    .collection("EstablishmentSimple")
                    .doc(establishmentId)
                    .get();

            if (establishmentSnapshot.exists) {
              Map<String, dynamic>? establishmentData =
                  establishmentSnapshot.data();
              if (establishmentData != null) {
                establishmentsInfo.add(establishmentData);
              }
            } else {
              // Handle if establishment document does not exist
              if (kDebugMode) {
                print(
                    'Establishment document does not exist for ID: $establishmentId');
              }
            }
          } else {
            // Handle the case where establishmentId is not a String
            if (kDebugMode) {
              print('Invalid establishment ID type: $establishmentId');
            }
          }
        }

        return establishmentsInfo;
      } else {
        // If Establishments is null or not found, return null or handle as appropriate
        if (kDebugMode) {
          print('Establishments field is null or not a list');
        }
        return null;
      }
    } else {
      // Document does not exist
      if (kDebugMode) {
        print('Document does not exist');
      }
      return null;
    }
  } catch (e) {
    // Error handling
    if (kDebugMode) {
      print("Error getting document from Firestore: $e");
    }
    // Throw an exception so that callers can handle errors
    throw e;
  }
}

Future<List<Map<String, dynamic>>?> getEstablishmentMenus(String pubId) async {
  try {
    if (pubId.isEmpty) {
      if (kDebugMode) {
        print('Pub ID is empty');
      }
      return null;
    }

    List<Map<String, dynamic>> menuInfo = [];

    // Fetch data from "EstablishmentDetailed" collection using establishment ID
    DocumentSnapshot<Map<String, dynamic>> establishmentSnapshot =
        await FirebaseFirestore.instance
            .collection("EstablishmentDetailed")
            .doc(pubId)
            .get();

    if (establishmentSnapshot.exists) {
      Map<String, dynamic>? establishmentData = establishmentSnapshot.data();
      List<dynamic>? establishmentMenus =
          establishmentData?['EstablishmentMenus'] as List<dynamic>?;

      if (establishmentMenus != null) {
        for (var menuId in establishmentMenus) {
          if (menuId is String) {
            // Fetch data from "EstablishmentMenus" collection using menu ID
            DocumentSnapshot<Map<String, dynamic>> menuSnapshot =
                await FirebaseFirestore.instance
                    .collection("EstablishmentMenus")
                    .doc(menuId)
                    .get();
            if (menuSnapshot.exists) {
              Map<String, dynamic>? menuData = menuSnapshot.data();
              if (menuData != null) {
                menuInfo.add(menuData);
              }
            } else {
              // Handle if menu document does not exist
              if (kDebugMode) {
                print('Menu document does not exist for ID: $menuId');
              }
            }
          } else {
            // Handle the case where menuId is not a String
            if (kDebugMode) {
              print('Invalid menu ID type: $menuId');
            }
          }
        }
      } else {
        // If Establishments is null or not found, return null or handle as appropriate
        if (kDebugMode) {
          print('EstablishmentMenus field is null or not a list');
        }
        return null;
      }
    } else {
      // Handle if establishment document does not exist
      if (kDebugMode) {
        print('Establishment document does not exist for ID: $pubId');
      }
      return null;
    }

    return menuInfo;
  } catch (e) {
    // Error handling
    if (kDebugMode) {
      print("Error getting document from Firestore: $e");
    }
    // Throw an exception so that callers can handle errors
    throw e;
  }
}

Future<List<Map<String, dynamic>>?> getMenuProducts(String menuId) async {
  try {
    // Fetch the user document
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection("EstablishmentMenus")
            .doc(menuId)
            .get();

    if (documentSnapshot.exists) {
      var menuData = documentSnapshot.data();
      // Ensure the Establishments field is a List<dynamic>
      List<dynamic>? products = menuData?['Products'] as List<dynamic>?;

      if (products != null) {
        List<Map<String, dynamic>> productInfo = [];

        // Loop through each establishment ID
        for (var productId in products) {
          if (productId is String) {
            // Fetch data from "EstablishmentDetailed" collection using establishment ID
            DocumentSnapshot<Map<String, dynamic>> productSnapshot =
                await FirebaseFirestore.instance
                    .collection("EstablishmentProducts")
                    .doc(productId)
                    .get();

            if (productSnapshot.exists) {
              Map<String, dynamic>? productData = productSnapshot.data();
              if (productData != null) {
                productInfo.add(productData);
              }
            }
          }
        }

        return productInfo;
      } else {
        // If Establishments is null or not found, return null or handle as appropriate
        if (kDebugMode) {
          print('Establishments field is null or not a list');
        }
        return null;
      }
    } else {
      // Document does not exist
      if (kDebugMode) {
        print('Document does not exist');
      }
      return null;
    }
  } catch (e) {
    // Error handling
    if (kDebugMode) {
      print("Error getting document from Firestore: $e");
    }
    // Throw an exception so that callers can handle errors
    throw e;
  }
}

Future<Map<String, dynamic>> fetchAddressSuggestions(String input) async {
  const String apiKey = 'AIzaSyBDu4XIweu_KQN5py0J7U_p-qQkcj2mPkc';
  const String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  final String requestUrl = '$baseUrl?address=$input&key=$apiKey';

  final response = await http.get(Uri.parse(requestUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'];
    if (results.isNotEmpty) {
      final location = results[0]['geometry']['location'];
      final formattedAddress = results[0]['formatted_address'];
      final lat = location['lat'];
      final lng = location['lng'];

      String? city;
      for (var component in results[0]['address_components']) {
        if (component['types'].contains('locality')) {
          city = component['long_name'];
          break;
        }
      }

      return {
        'address': formattedAddress,
        'lat': lat,
        'lng': lng,
        'city': city,
      };
    } else {
      throw Exception('No results found');
    }
  } else {
    throw Exception('Failed to load suggestions');
  }
}

/// REGISTER NEW VENUE TO FIREBASE
Future<String> addNewVenueToFirebase(
    String establishmentName, String establishmentAddress,
    {String? establishmentDesc}) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    // Gather LAT and LON from PostCode
    var coords = await fetchAddressSuggestions(establishmentAddress);

    // Define the data you want to add
    Map<String, Object> data = {
      'EstablishmentName': establishmentName,
      'EstablishmentAddress': coords['address'] ?? '',
      'EstablishmentCity': coords['city'] ?? '',
      'Image': '',
      'Popularity': '',
      'Latitude': coords['lat'],
      'Longitude': coords['lng'],
    };

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef =
        await firestoreInst.collection('EstablishmentSimple').add(data);

    // Update the document with its own ID
    await docRef.update({
      'EstablishmentId': docRef.id,
    });

    // Add EstablishmentDetailed
    // Add the data to the specified collection and get the document reference
    DocumentReference docRefDet =
        firestoreInst.collection('EstablishmentDetailed').doc(docRef.id);

    //Empty array
    Map<String, String> dataDetailed = {
      'EstablishmentName': establishmentName,
      'Description': establishmentAddress ?? '',
      'Image': '',
      'Popularity': '',
    };

    await docRefDet.set(dataDetailed);

    // Create a new document reference with an auto-generated ID
    DocumentReference documentReference = firestoreInst
        .collection('AleTrailUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    await documentReference.set({
      'Establishments': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    if (kDebugMode) {
      print('New user added to Firestore with ID: ${documentReference.id}');
    }

    return docRef.id; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding user to Firestore: $e');
    }
    return ""; // Operation failed
  }
}

Future<bool?> updateNewVenueImage(
    String docId, String establishmentTagline, io.File? imageFile) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    String imageUrl = "";
    // Upload image to Firebase Storage
    if (imageFile != null) {
      imageUrl = await uploadImageToStorage(imageFile);
    }

    // Get the document reference for EstablishmentSimple
    DocumentReference docRef =
        firestoreInst.collection('EstablishmentSimple').doc(docId);

    // Update the document with new fields
    await docRef.update({
      'Image': imageUrl, // Update the image URL
      'Tags': establishmentTagline, // Update the tags
    });

    // Get the document reference for EstablishmentDetailed
    DocumentReference docRefDet =
        firestoreInst.collection('EstablishmentDetailed').doc(docRef.id);

    // Update the detailed document with new fields
    await docRefDet.update({
      'Image': imageUrl, // Update the image URL
      'Tags': establishmentTagline, // Update the tags
    });

    return true; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding image to Firestore: $e');
    }
    return false; // Operation failed
  }
}

Future<String> uploadImageToStorage(io.File imageFile) async {
  try {
    // Get a reference to the Firebase Storage instance
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage
        .ref("Users/${FirebaseAuth.instance.currentUser!.uid}")
        .child('Establishments/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image to Firebase Storage
    UploadTask uploadTask = ref.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    String imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  } catch (e) {
    // Handle error
    throw Exception('Failed to upload image: $e');
  }
}

Future<String> uploadImageToStorageProduct(
    io.File imageFile, String productId) async {
  try {
    // Get a reference to the Firebase Storage instance
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage
        .ref("Users/${FirebaseAuth.instance.currentUser!.uid}")
        .child('Products/$productId.jpg');

    // Upload the image to Firebase Storage
    UploadTask uploadTask = ref.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    String imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  } catch (e) {
    // Handle error
    throw Exception('Failed to upload image: $e');
  }
}

// Upload image to storage for users profile photo
Future<String> uploadProfileImageToStorage(io.File imageFile) async {
  try {
    // Get a reference to the Firebase Storage instance
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage
        .ref("Users/${FirebaseAuth.instance.currentUser!.uid}")
        .child('ProfilePhoto/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image to Firebase Storage
    UploadTask uploadTask = ref.putFile(imageFile);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    String imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  } catch (e) {
    // Handle error
    throw Exception('Failed to upload image: $e');
  }
}

// Update Firebase database with user profile photo
Future<bool?> updateProfileImage(io.File? imageFile) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    String imageUrl = "";
    // Upload image to Firebase Storage
    if (imageFile != null) {
      imageUrl = await uploadImageToStorage(imageFile);
    }

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef = firestoreInst
        .collection('AleTrailUsers')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    // Update the document with its own ID
    await docRef.update({
      'ProfileImage': imageUrl, // Add the image URL
    });

    return true; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding image to Firestore: $e');
    }
    return false; // Operation failed
  }
}

// Update Firebase database with user profile photo
Future<bool?> uploadNewProductImage(io.File? imageFile) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    String imageUrl = "";
    // Upload image to Firebase Storage
    if (imageFile != null) {
      imageUrl = await uploadImageToStorage(imageFile);
    }

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef = firestoreInst
        .collection('AleTrailUsers')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    // Update the document with its own ID
    await docRef.update({
      'ProfileImage': imageUrl, // Add the image URL
    });

    return true; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding image to Firestore: $e');
    }
    return false; // Operation failed
  }
}

/// CREATE NEW MENU IN ESTABLISHMENT
Future<bool> createNewMenuInEstablishment(
    String pubId, String menuName, String menuDesc) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    // Define the data you want to add
    Map<String, String> data = {
      'MenuName': menuName,
      'MenuDescription': menuDesc ?? '',
    };

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef =
        await firestoreInst.collection('EstablishmentMenus').add(data);

    // Update the document with its own ID
    await docRef.update({
      'MenuId': docRef.id,
    });

    // Update Establishment Detailed
    DocumentReference documentReference =
        firestoreInst.collection('EstablishmentDetailed').doc(pubId);

    await documentReference.set({
      'EstablishmentMenus': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    return true;
  } catch (e) {
    // Handle error
    throw Exception('Failed to upload image: $e');
  }
  return false;
}

// Function to calculate the bounding box
Map<String, double> calculateBoundingBox(
    double lat, double lon, double distanceInKm) {
  const double earthRadius = 6378.1; // Earth's radius in km

  // Calculate the bounding box
  double minLat = lat - (distanceInKm / earthRadius) * (180 / pi);
  double maxLat = lat + (distanceInKm / earthRadius) * (180 / pi);
  double minLon =
      lon - (distanceInKm / earthRadius) * (180 / pi) / cos(lat * pi / 180);
  double maxLon =
      lon + (distanceInKm / earthRadius) * (180 / pi) / cos(lat * pi / 180);

  return {
    'minLat': minLat,
    'maxLat': maxLat,
    'minLon': minLon,
    'maxLon': maxLon,
  };
}

// Function to fetch documents within the bounding box
Future<List<DocumentSnapshot>> fetchNearbyEstablishments(
    double userLat, double userLon, double radiusInKm) async {
  // Calculate the bounding box
  Map<String, double> boundingBox =
      calculateBoundingBox(userLat, userLon, radiusInKm);

  // Query Firestore
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("EstablishmentSimple")
      .where("Latitude", isGreaterThanOrEqualTo: boundingBox['minLat'])
      .where("Latitude", isLessThanOrEqualTo: boundingBox['maxLat'])
      .where("Longitude", isGreaterThanOrEqualTo: boundingBox['minLon'])
      .where("Longitude", isLessThanOrEqualTo: boundingBox['maxLon'])
      .get();

  // Filter the documents to check the actual distance
  List<DocumentSnapshot> nearbyDocuments = [];
  for (DocumentSnapshot document in querySnapshot.docs) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    double lat = data['Latitude'];
    double lon = data['Longitude'];

    // Calculate the distance
    double distance = Geolocator.distanceBetween(userLat, userLon, lat, lon) /
        1000; // Convert to km
    if (distance <= radiusInKm) {
      nearbyDocuments.add(document);
    }
  }

  return nearbyDocuments;
}

// Usage example
Future<List<DocumentSnapshot<Object?>>> getNearbyEstablishments(
    double userLat, double userLon) async {
  double radiusInKm = 5.0; // Radius of 5km
  List<DocumentSnapshot> nearbyEstablishments =
      await fetchNearbyEstablishments(userLat, userLon, radiusInKm);

  return nearbyEstablishments;
}

/// CREATE NEW PRODUCT IN MENU
Future<String> addNewProductToFirebase(
    String menuId,
    String productName,
    String productPrice,
    String? productDescription,
    String selectedProductType,
    String establishmentRef,
    io.File? imageFile) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    double? setPrice = double.tryParse(productPrice);

    // Define the data you want to add
    Map<String, Object> data = {
      'ProductName': productName,
      'ProductDescription': productDescription ?? '',
      'ProductPrice': setPrice ?? "00.00",
      'ProductType': selectedProductType
    };

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef =
        await firestoreInst.collection('EstablishmentProducts').add(data);

    // Update the document with its own ID
    await docRef.update({
      'ProductId': docRef.id,
    });

    // Add New Product To Menu
    // Add the data to the specified collection and get the document reference
    DocumentReference documentReference =
        firestoreInst.collection('EstablishmentMenus').doc(menuId);

    await documentReference.set({
      'Products': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    // Upload Product Image To Database
    String imageURL = await uploadImageToStorageProduct(imageFile!, docRef.id);

    // Update the document with the image url
    await docRef.update({
      'ProductImage': imageURL,
    });

    if (establishmentRef != null || establishmentRef != "") {
      // Get Coords from pub doc
      // Specify the document reference
      DocumentReference docRef = firestoreInst
          .collection('EstablishmentSimple')
          .doc(
              establishmentRef); // Replace 'establishmentRef' with your document ID

      // Get the document
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Extract Latitude and Longitude fields
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          double? latitude = data['Latitude'];
          double? longitude = data['Longitude'];

          if (latitude != null && longitude != null) {
            if (kDebugMode) {
              print('Latitude: $latitude, Longitude: $longitude');
            }
            // Add to search index
            await addNewProductToSearchIndex(
                productName,
                productDescription!,
                selectedProductType,
                docRef.id,
                establishmentRef,
                productPrice,
                longitude,
                latitude);
          } else {
            if (kDebugMode) {
              print('Latitude or Longitude field is missing.');
            }
          }
        } else {
          if (kDebugMode) {
            print('No data found in the document.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Document does not exist.');
        }
      }
    }
    if (kDebugMode) {
      print('New product added to Firestore with ID: ${documentReference.id}');
    }

    return docRef.id; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding product to Firestore: $e');
    }
    return ""; // Operation failed
  }
}

/// DELETE MENU FROM FIRESTORE
Future<void> deleteMenuFromEstablishment(
    String establishmentId, String menuId) async {
  try {
    // Remove from menus
    await FirebaseFirestore.instance
        .collection("EstablishmentMenus")
        .doc(establishmentId)
        .delete();

    // Remove from Establishment
    await FirebaseFirestore.instance
        .collection("EstablishmentDetailed")
        .doc(establishmentId)
        .update({
      "EstablishmentMenus": FieldValue.arrayRemove([menuId])
    });
    if (kDebugMode) {
      print("Document successfully deleted!");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error deleting document: $e");
    }
  }
}

// Grab products based on id list
Future<List<Menuproduct>> getProductsBasedOnId(List<String> ids) async {
  if (ids.isEmpty) {
    return []; // No IDs to fetch
  }

  // Split the IDs into smaller batches if necessary, Firestore has a limit of 10 IDs per 'in' query.
  const int batchSize = 10;
  List<List<String>> batches = [];
  for (int i = 0; i < ids.length; i += batchSize) {
    batches.add(ids.sublist(
        i, i + batchSize > ids.length ? ids.length : i + batchSize));
  }

  List<Menuproduct> products = [];
  for (List<String> batch in batches) {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('EstablishmentProducts')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (DocumentSnapshot doc in querySnapshot.docs) {
        // Extract data from each document
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // gather list of products
        Menuproduct newProduct = Menuproduct(
            productName: data['ProductName'],
            productDescription: data['ProductDescription'],
            productPrice: data['ProductPrice']);
        products.add(
            newProduct); // or add productData if you extract specific fields
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching documents: $e');
      }
      // Optionally: handle the error or retry
    }
  }

  return products;
}

/// DELETE MENU FROM FIRESTORE
Future<void> deleteProductFromMenu(String menuId, String productId) async {
  try {
    // Remove from menus
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("EstablishmentMenus").doc(menuId);

    // Update the document by removing the item from the array
    await docRef.update({
      'Products': FieldValue.arrayRemove([productId])
    });

    if (kDebugMode) {
      print("Document successfully deleted!");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error deleting document: $e");
    }
  }
}

/// Push To SearchIndex
Future<String> addNewProductToSearchIndex(
    String productName,
    String productDescription,
    String productType,
    String productRef,
    String establishmentRef,
    String productPrice,
    double longitude,
    double latitude) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    double? setPrice = double.tryParse(productPrice);

    // Determine Search Terms
    List<String> searchTerms = [];

    // Function to split terms into individual words and add them if they don't exist
    void addSplitTerms(String term) {
      if (!searchTerms.contains(term)) {
        searchTerms.add(term);
        term.split(' ').forEach((word) {
          if (word.isNotEmpty && !searchTerms.contains(word)) {
            searchTerms.add(word);
          }
        });
      }
    }

    addSplitTerms(productName);
    addSplitTerms(productDescription);
    addSplitTerms(productType);
    addSplitTerms(productName.toLowerCase());
    addSplitTerms(productDescription.toLowerCase());
    addSplitTerms(productType.toLowerCase());

    // Define the data you want to add
    Map<String, Object> data = {
      'ActualName': productName,
      'Latitude': latitude,
      'Longitude': longitude,
      'ProductType': productType,
      'EstablishmentRef': establishmentRef,
      'Ref': productRef,
      'Price': setPrice ?? 0.0,
      'Terms': searchTerms,
      'Type': 'Product'
    };

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef =
        await firestoreInst.collection('SearchIndex').add(data);

    // Update the document with its own ID
    await docRef.update({
      'searchRef': docRef.id,
    });

    if (kDebugMode) {
      print('New product added to Firestore with ID: ${docRef.id}');
    }

    return docRef.id; // Operation successful
  } catch (e) {
    if (kDebugMode) {
      print('Error adding product to search index: $e');
    }
    return ""; // Operation failed
  }
}

/// Gather All Users Menus
Future<List<Map<String, dynamic>>?> getAllMenusForBusinessUser() async {
  try {
    // List Of Menu Ids To Get
    List<dynamic> menuIds = [];

    // Fetch the user document
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection("AleTrailUsers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (documentSnapshot.exists) {
      var userData = documentSnapshot.data();
      // Ensure the Establishments field is a List<dynamic>
      List<dynamic>? establishments =
          userData?['Establishments'] as List<dynamic>?;

      if (establishments != null) {
        // Loop through each establishment ID
        for (var establishmentId in establishments) {
          if (establishmentId is String) {
            // Fetch data from "EstablishmentDetailed" collection using establishment ID
            DocumentSnapshot<Map<String, dynamic>> establishmentSnapshot =
                await FirebaseFirestore.instance
                    .collection("EstablishmentDetailed")
                    .doc(establishmentId)
                    .get();

            if (establishmentSnapshot.exists) {
              var establishmentData = establishmentSnapshot.data();
              if (establishmentData != null &&
                  establishmentData.containsKey('EstablishmentMenus')) {
                // Ensure MenuIds is a list
                List<dynamic>? establishmentMenuIds =
                    establishmentData['EstablishmentMenus'] as List<dynamic>?;
                if (establishmentMenuIds != null) {
                  menuIds.addAll(establishmentMenuIds);
                }
              }
            }
          }
        }

        // Now menuIds contains all menus from all EstablishmentDetailed records
        // Declare a list to hold all establishment menus
        List<Map<String, dynamic>> allMenus = [];
        for (var menuId in menuIds) {
          if (menuId is String) {
            DocumentSnapshot<Map<String, dynamic>> menuSnapshot =
                await FirebaseFirestore.instance
                    .collection("EstablishmentMenus")
                    .doc(menuId)
                    .get();
            if (menuSnapshot.exists) {
              allMenus.add(menuSnapshot.data()!);
            }
          }
        }
        return allMenus;
      } else {
        // If Establishments is null or not found, return null or handle as appropriate
        if (kDebugMode) {
          print('Establishments field is null or not a list');
        }
        return null;
      }
    } else {
      // Document does not exist
      if (kDebugMode) {
        print('Document does not exist');
      }
      return null;
    }
  } catch (e) {
    // Error handling
    if (kDebugMode) {
      print("Error getting document from Firestore: $e");
    }
    // Throw an exception so that callers can handle errors
    throw e;
  }
}
