import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

import 'language_localization.dart';

String? getTranslated(BuildContext context, String key) {
  return LanguageLocalization.of(context)!.getTranslateValue(key);
}

const String english = "en";
const String spanish = "es";
const String arabic = "ar";

Future<Locale> setLocale(String languageCode) async {
  PreferenceUtils.setString(PreferenceNames.currentLanguageCode, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case english:
      _temp = Locale(languageCode, 'US');
      break;
    case spanish:
      _temp = Locale(languageCode, 'ES');
      break;
    case arabic:
      _temp = Locale(languageCode, 'AE');
      break;
    default:
      _temp = Locale(english, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  String languageCode =
      PreferenceUtils.getString(PreferenceNames.currentLanguageCode);
  return _locale(languageCode);
}
