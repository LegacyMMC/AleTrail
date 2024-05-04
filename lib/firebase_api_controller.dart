import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// FIRE BASE AUTHENTICATION FUNCTIONS
Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  } catch (e) {
    // Handle sign-in errors
    if (kDebugMode) {
      print('Error signing in: $e');
    }
    return null; // Or throw an exception if you prefer
  }
}

Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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