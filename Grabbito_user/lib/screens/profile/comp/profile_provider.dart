import 'package:flutter/material.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class ProfileScreenProvider extends ChangeNotifier {
  String _loginUsername = '';
  String get loginUserName => _loginUsername;

  checkName() {
    if (PreferenceUtils.getString(PreferenceNames.loggedInUserName) != 'N/A') {
      _loginUsername =
          PreferenceUtils.getString(PreferenceNames.loggedInUserName);
    } else {
      _loginUsername = "abc";
    }
    notifyListeners();
  }
}
