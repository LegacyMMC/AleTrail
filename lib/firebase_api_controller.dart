import 'dart:io' as io; // Import the IO library explicitly
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AleTrail/classes/UserData.dart';

/// FIRE BASE AUTHENTICATION FUNCTIONS

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
      List<dynamic>? establishments = userData?['Establishments'] as List<dynamic>?;

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
              Map<String, dynamic>? establishmentData = establishmentSnapshot.data();
              if (establishmentData != null) {
                establishmentsInfo.add(establishmentData);
              }
            } else {
              // Handle if establishment document does not exist
              if (kDebugMode) {
                print('Establishment document does not exist for ID: $establishmentId');
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

Future<List<Map<String, dynamic>>?> getEstablishmentMenus() async {
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
        List<Map<String, dynamic>> menuInfo = [];

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
              Map<String, dynamic>? establishmentData =
              establishmentSnapshot.data();
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
                    }
                  }
                }
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

        return menuInfo;
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
      List<dynamic>? products =
      menuData?['Products'] as List<dynamic>?;

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
              Map<String, dynamic>? productData =
              productSnapshot.data();
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

/// REGISTER NEW VENUE TO FIREBASE
Future<String> addNewVenueToFirebase(
    String establishmentName, String establishmentAddress,
    {String? establishmentDesc}) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    // Define the data you want to add
    Map<String, String> data = {
      'EstablishmentName': establishmentName,
      'EstablishmentAddress': establishmentAddress ?? '',
      'Image':  '',
      'Popularity':  ''
    };

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef = await firestoreInst.collection('EstablishmentSimple').add(data);

    // Update the document with its own ID
    await docRef.update({
      'EstablishmentId': docRef.id,
    });

    // Add EstablishmentDetailed
    // Add the data to the specified collection and get the document reference
    DocumentReference docRefDet = await firestoreInst.collection('EstablishmentDetailed').doc(docRef.id);

    //Empty array
    Map<String, String> dataDetailed = {
      'EstablishmentName': establishmentName,
      'Description': establishmentAddress ?? '',
      'Image':  '',
      'Popularity':  '',
    };


    await docRefDet.set(dataDetailed);

    // Create a new document reference with an auto-generated ID
    DocumentReference documentReference =
    firestoreInst.collection('AleTrailUsers').doc(FirebaseAuth.instance.currentUser!.uid);

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
    String docId, String establishmentTagline,
io.File? imageFile
    ) async {
  try {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;

    String imageUrl = "";
    // Upload image to Firebase Storage
    if(imageFile != null)
      {
         imageUrl = await uploadImageToStorage(imageFile);
      }

    // Add the data to the specified collection and get the document reference
    DocumentReference docRef = await firestoreInst.collection('EstablishmentSimple').doc(docId);

    // Update the document with its own ID
    await docRef.update({
      'Image': imageUrl, // Add the image URL
      'Tags': establishmentTagline, // Add the image URL
    });

    // Add EstablishmentDetailed
    // Add the data to the specified collection and get the document reference
    DocumentReference docRefDet = await firestoreInst.collection('EstablishmentDetailed').doc(docRef.id);

    Map<String, dynamic> dataDetailed = {
      'Image': imageUrl,
      'Tags': establishmentTagline,
    };

    await docRefDet.set(dataDetailed);

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

    Reference ref = storage.ref("Users/${FirebaseAuth.instance.currentUser!.uid}").child('Establishments/${DateTime.now().millisecondsSinceEpoch}.jpg');

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