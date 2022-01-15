import 'package:dio/dio.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class ApiHeader {
  Dio dioData() {
    final dio = Dio();
    dio.options.headers["Authorization"] = "Bearer " +
        PreferenceUtils.getString(
            PreferenceNames.headerToken); // config your dio headers globally
    dio.options.headers["Accept"] =
        "application/json"; // config your dio headers globally
    dio.options.headers["Content-Type"] = "application/x-www-form-urlencoded";
    dio.options.followRedirects = false;

    return dio;
  }
}
