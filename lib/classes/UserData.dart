import 'package:flutter/cupertino.dart';

class UserData {
  final String userId;
  final String userName;
  final String companyName;
  final String accountType;
  final String profileImage;

  UserData({
    required this.userId,
    required this.userName,
    required this.companyName,
    required this.accountType,
    this.profileImage = '',
  });
}

class UserProvider with ChangeNotifier {
  UserData? _user;

  UserData? get user => _user;

  void setUser(UserData user) {
    _user = user;
    notifyListeners();
  }
}
