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
