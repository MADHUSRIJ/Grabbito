import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/cart/select_address_screen.dart';
import 'package:grabbito/screens/category/pickup_and_drop.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class SelectMapAddress extends StatefulWidget {
  const SelectMapAddress({Key? key}) : super(key: key);

  @override
  _SelectMapAddressState createState() => _SelectMapAddressState();
}

class _SelectMapAddressState extends State<SelectMapAddress> {
  late String mapKey;
  List<String> recentData = [];
  List<String> recentDataLat = [];
  List<String> recentDataLong = [];
  List<String> recentDataLandmark = [];
  List<String> tempRecentData = [];
  List<String> tempRecentDataLat = [];
  List<String> tempRecentDataLong = [];
  List<String> tempRecentDataLandmark = [];
  List<String> addDataToLocal = [];
  List<String> addDataToLocalLat = [];
  List<String> addDataToLocalLong = [];
  List<String> addDataToLocalLandMark = [];
  late Position currentLocation;
  late LatLng _center;
  bool _loading = false;
  TextEditingController addAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (PreferenceUtils.getStringList(PreferenceNames.recentSearch)
        .isNotEmpty) {
      tempRecentData =
          PreferenceUtils.getStringList(PreferenceNames.recentSearch);
    } else {
      tempRecentData = [];
    }
    if (PreferenceUtils.getStringList(PreferenceNames.recentSearchLandMark)
        .isNotEmpty) {
      tempRecentDataLandmark =
          PreferenceUtils.getStringList(PreferenceNames.recentSearchLandMark);
    } else {
      tempRecentDataLandmark = [];
    }
    if (PreferenceUtils.getStringList(PreferenceNames.recentSearchLat)
        .isNotEmpty) {
      tempRecentDataLat =
          PreferenceUtils.getStringList(PreferenceNames.recentSearchLat);
    } else {
      tempRecentDataLat = [];
    }
    if (PreferenceUtils.getStringList(PreferenceNames.recentSearchLong)
        .isNotEmpty) {
      tempRecentDataLong =
          PreferenceUtils.getStringList(PreferenceNames.recentSearchLong);
    } else {
      tempRecentDataLong = [];
    }
    recentData = tempRecentData.reversed.toList();
    recentDataLandmark = tempRecentDataLandmark.reversed.toList();
    recentDataLat = tempRecentDataLat.reversed.toList();
    recentDataLong = tempRecentDataLong.reversed.toList();
    _center = LatLng(22.3039, 70.8022);
    getUserLocation();
    if (Platform.isIOS) {
      mapKey = iosKey;
    } else {
      mapKey = androidKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 1.0,
      color: Colors.transparent.withOpacity(0.2),
      progressIndicator: SpinKitFadingCircle(color: colorRed),
      child: Scaffold(
        body: PlacePicker(
          apiKey: mapKey,
          initialPosition: _center,
          hintText: "Find a place ...",
          searchingText: "Please wait ...",
          selectText: "Select place",
          outsideOfPickAreaText: "Place not in area",
          useCurrentLocation: true,
          selectInitialPosition: true,
          usePinPointingSearch: true,
          usePlaceDetailSearch: true,
          forceSearchOnZoomChanged: true,
          onPlacePicked: (result) {
            print('the result is ${result.formattedAddress}');
            // This will change the text displayed in the TextField
            if (result.formattedAddress!.isNotEmpty) {
              setState(() {
                for (int i = 0; i < recentData.length; i++) {
                  addDataToLocal.add(recentData[i]);
                  addDataToLocalLandMark.add(recentDataLandmark[i]);
                  addDataToLocalLat.add(recentDataLat[i]);
                  addDataToLocalLong.add(recentDataLong[i]);
                }
                String address = result.formattedAddress.toString();
                String landmark = result.name.toString();
                double lat = result.geometry!.location.lat;
                double long = result.geometry!.location.lng;
                // if (placeDetails.street != null) address = address + placeDetails.street! + ' ';
                // if (placeDetails.city != null) address = address + placeDetails.city!;
                addDataToLocal.add(address);
                addDataToLocalLandMark.add(landmark);
                addDataToLocalLat.add(lat.toString());
                addDataToLocalLong.add(long.toString());
                PreferenceUtils.setStringList(
                    PreferenceNames.recentSearch, addDataToLocal);
                PreferenceUtils.setStringList(
                    PreferenceNames.recentSearchLandMark,
                    addDataToLocalLandMark);
                PreferenceUtils.setStringList(
                    PreferenceNames.recentSearchLat, addDataToLocalLat);
                PreferenceUtils.setStringList(
                    PreferenceNames.recentSearchLong, addDataToLocalLong);
                if (PreferenceUtils.getString(
                            PreferenceNames.checkManageLocationPath) ==
                        "fromPickup" ||
                    PreferenceUtils.getString(
                            PreferenceNames.checkManageLocationPath) ==
                        "fromDrop") {
                  if (PreferenceUtils.getString(
                          PreferenceNames.checkManageLocationPath) ==
                      "fromPickup") {
                    PreferenceUtils.setString(
                        PreferenceNames.pickupAddress, address);
                    PreferenceUtils.setDouble(PreferenceNames.pickupLat, lat);
                    PreferenceUtils.setDouble(PreferenceNames.pickupLong, long);
                  } else if (PreferenceUtils.getString(
                          PreferenceNames.checkManageLocationPath) ==
                      "fromDrop") {
                    PreferenceUtils.setString(
                        PreferenceNames.dropAddress, address);
                    PreferenceUtils.setDouble(PreferenceNames.dropLat, lat);
                    PreferenceUtils.setDouble(PreferenceNames.dropLong, long);
                  }
                } else {
                  //if without login
                  if (PreferenceUtils.getBool(PreferenceNames.checkLogin) ==
                      false) {
                    PreferenceUtils.setBool(
                        PreferenceNames.storeWithoutLogin, true);
                    PreferenceUtils.setString(
                        PreferenceNames.addressOfSetLocationWithoutLogin,
                        address);
                    PreferenceUtils.setString(
                        PreferenceNames.landMarkOfSetLocationWithoutLogin,
                        landmark.substring(0, 10));
                    PreferenceUtils.setString(
                        PreferenceNames.locationTypeOfSetLocationWithoutLogin,
                        landmark);
                    PreferenceUtils.setDouble(
                        PreferenceNames.latOfSetLocationWithoutLogin, lat);
                    PreferenceUtils.setDouble(
                        PreferenceNames.longOfSetLocationWithoutLogin, long);
                  }

                  PreferenceUtils.setString(
                      PreferenceNames.addressOfSetLocation, address);
                  PreferenceUtils.setString(
                      PreferenceNames.landMarkOfSetLocation, landmark);
                  if (landmark.length > 9) {
                    PreferenceUtils.setString(
                        PreferenceNames.locationTypeOfSetLocation,
                        landmark.substring(0, 10));
                  } else {
                    PreferenceUtils.setString(
                        PreferenceNames.locationTypeOfSetLocation, landmark);
                  }
                  PreferenceUtils.setDouble(
                      PreferenceNames.latOfSetLocation, lat);
                  PreferenceUtils.setDouble(
                      PreferenceNames.longOfSetLocation, long);
                }
                if (PreferenceUtils.getString(
                        PreferenceNames.checkManageLocationPath) ==
                    "fromManageLocation") {
                  Navigator.pushReplacementNamed(
                      context, selectLocationScreenRoute);
                } else if (PreferenceUtils.getString(
                        PreferenceNames.checkManageLocationPath) ==
                    "fromEditSelectLocation") {
                  Navigator.pushReplacementNamed(
                      context, selectLocationScreenRoute);
                } else if (PreferenceUtils.getString(
                        PreferenceNames.checkManageLocationPath) ==
                    "fromPickup") {
                  PreferenceUtils.remove(
                      PreferenceNames.checkManageLocationPath);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickupAndDrop(),
                      ));
                } else if (PreferenceUtils.getString(
                        PreferenceNames.checkManageLocationPath) ==
                    "fromDrop") {
                  PreferenceUtils.remove(
                      PreferenceNames.checkManageLocationPath);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickupAndDrop(),
                      ));
                } else if (PreferenceUtils.getString(
                        PreferenceNames.checkManageLocationPath) ==
                    "fromSelectAddress") {
                  buildShowDialog(context);
                } else {
                  buildShowDialog(context);
                }
              });
            }
          },
        ),
      ),
    );
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (mounted) {
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getTranslated(context, addAddressName).toString()),
        content: TextFormField(
          controller: addAddressController,
          style: TextStyle(
              color: colorDivider, fontSize: 14, fontFamily: groldBold),
          // validator: ValidationConstants.kValidateName,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: getTranslated(context, addAddressLabelHint).toString(),
          ),
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              addAddress();
            },
            child: Text('Add'),
          )
        ],
      ),
    );
  }

  Future<BaseModel<String>> addAddress() async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      String address = '',
          landmark = '',
          locationType = '',
          lat = "",
          long = "";
      assert(PreferenceUtils.getString(PreferenceNames.addressOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getString(PreferenceNames.locationTypeOfSetLocation)
              .isNotEmpty &&
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation) > 0.0 &&
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation) > 0.0);
      address = PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);
      landmark =
          PreferenceUtils.getString(PreferenceNames.landMarkOfSetLocation);
      locationType = PreferenceUtils.getString(
                  PreferenceNames.locationTypeOfSetLocation) !=
              'N/A'
          ? addAddressController.text
          : PreferenceUtils.getString(
              PreferenceNames.locationTypeOfSetLocation);
      lat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
          .toString();
      long = PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
          .toString();

      Map<String, dynamic> bodyForApi = {
        'address': address,
        'landmark': landmark,
        'location_type': locationType,
        'lat': lat,
        'lang': long,
      };

      response =
          await ApiServices(ApiHeader().dioData()).addLocation(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        PreferenceUtils.setInt(
            PreferenceNames.idOfSetLocation, body['location']['id']);
        if (PreferenceUtils.getString(
                PreferenceNames.checkManageLocationPath) ==
            "fromSelectAddress") {
          PreferenceUtils.remove(PreferenceNames.checkManageLocationPath);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SelectAddressScreen(),
              ));
          addAddressController.clear();
        } else {
          Navigator.pushReplacementNamed(context, homeRoute);
        }
      } else {
        CommonFunction.toastMessage(body["message"]);
      }

      setState(() {
        _loading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
