import 'package:flutter/material.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/screens/set_location/select_address_from_map.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:geocoding/geocoding.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/category/pickup_and_drop.dart';
import 'package:iconly/iconly.dart';

class SetLocationScreen extends StatefulWidget {
  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  TextEditingController searchController = TextEditingController();
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
  String setLocationPageName = '';

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
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (PreferenceUtils.getString(PreferenceNames.checkManageLocationPath) ==
        "fromPickup") {
      setLocationPageName =
          getTranslated(this.context, setLocationForPickup).toString();
    } else if (PreferenceUtils.getBool(PreferenceNames.dropPathEnable) ==
        true) {
      setLocationPageName =
          getTranslated(this.context, setLocationForDelivery).toString();
    } else {
      setLocationPageName = getTranslated(this.context, setLocation).toString();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          setLocationPageName,
          style: TextStyle(
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: Container(
          margin: EdgeInsets.only(right: 10, left: 10),
          child: Column(
            children: [
              SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMapAddress(),
                      ));
                },
                icon: Icon(IconlyBold.location, color: colorOrange, size: 20.0,),
                label: Text(
                  getTranslated(context, selectLocationFromMap).toString(),
                  style: TextStyle(
                    fontFamily: 'Grold Regular',
                    color: colorBlue,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: width / 2.5,
                    color: colorDivider,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "OR",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: groldReg),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: width / 2.5,
                    color: colorDivider,
                  )
                ],
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, recentSearch).toString(),
                      style: TextStyle(
                          fontFamily: groldXBold,
                          color: colorBlack,
                          fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          PreferenceUtils.setStringList(
                              PreferenceNames.recentSearch, <String>[]);
                          recentData = PreferenceUtils.getStringList(
                              PreferenceNames.recentSearch);
                        });
                      },
                      child: Text(
                        getTranslated(context, clearAll).toString(),
                        style: TextStyle(
                            fontFamily: groldBold,
                            color: colorBlue,
                            fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
              recentData.isNotEmpty
                  ? ListView.builder(
                      itemCount: 5 <= recentData.length ? 5 : recentData.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            String holdAddress = "";
                            String holdAddressLandmark = "";
                            holdAddress = recentData[index];
                            holdAddressLandmark = recentDataLandmark[index];
                            searchController.text = recentData[index];
                            List<Location> locations =
                                await locationFromAddress(recentData[index]);
                            print(
                                "latitude ${locations[0].latitude.toString()}");
                            print(
                                "longitude ${locations[0].longitude.toString()}");
                            if (PreferenceUtils.getString(PreferenceNames
                                        .checkManageLocationPath) ==
                                    "fromPickup" ||
                                PreferenceUtils.getString(PreferenceNames
                                        .checkManageLocationPath) ==
                                    "fromDrop") {
                              if (PreferenceUtils.getString(PreferenceNames
                                      .checkManageLocationPath) ==
                                  "fromPickup") {
                                PreferenceUtils.setString(
                                    PreferenceNames.pickupAddress,
                                    recentData[index]);
                                PreferenceUtils.setDouble(
                                    PreferenceNames.pickupLat,
                                    double.parse(recentDataLat[index]));
                                PreferenceUtils.setDouble(
                                    PreferenceNames.pickupLong,
                                    double.parse(recentDataLong[index]));
                              } else if (PreferenceUtils.getString(
                                      PreferenceNames
                                          .checkManageLocationPath) ==
                                  "fromDrop") {
                                PreferenceUtils.setString(
                                    PreferenceNames.dropAddress,
                                    recentData[index]);
                                PreferenceUtils.setDouble(
                                    PreferenceNames.dropLat,
                                    double.parse(recentDataLat[index]));
                                PreferenceUtils.setDouble(
                                    PreferenceNames.dropLong,
                                    double.parse(recentDataLong[index]));
                              }
                            } else {
                              PreferenceUtils.setString(
                                  PreferenceNames.addressOfSetLocation,
                                  recentData[index]);
                              PreferenceUtils.setString(
                                  PreferenceNames.landMarkOfSetLocation,
                                  recentDataLandmark[index]);
                              PreferenceUtils.setDouble(
                                  PreferenceNames.latOfSetLocation,
                                  locations[0].latitude);
                              PreferenceUtils.setDouble(
                                  PreferenceNames.longOfSetLocation,
                                  locations[0].longitude);
                            }
                            for (int i = 0; i < recentData.length; i++) {
                              if (recentData[index] == recentData[i]) {
                                recentData.removeAt(index);
                              }
                            }

                            for (int i = 0;
                                i < recentDataLandmark.length;
                                i++) {
                              if (recentDataLandmark[index] ==
                                  recentDataLandmark[i]) {
                                recentDataLandmark.removeAt(index);
                              }
                            }

                            for (int i = 0; i < recentData.length; i++) {
                              addDataToLocal.add(recentData[i]);
                            }
                            for (int i = 0;
                                i < recentDataLandmark.length;
                                i++) {
                              addDataToLocalLandMark.add(recentDataLandmark[i]);
                            }
                            addDataToLocal.add(holdAddress);
                            addDataToLocalLandMark.add(holdAddressLandmark);
                            recentData.insert(0, holdAddress);
                            recentDataLandmark.insert(0, holdAddressLandmark);
                            PreferenceUtils.setStringList(
                                PreferenceNames.recentSearch, addDataToLocal);
                            PreferenceUtils.setStringList(
                                PreferenceNames.recentSearchLandMark,
                                addDataToLocalLandMark);

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
                            } else {
                              Navigator.pop(context);
                            }
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                right: 10, left: 10, top: height / 30),
                            // width: MediaQuery.of(context).size.width / 0.8,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: colorDivider,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  child: Text(
                                    recentData[index],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: colorDivider,
                                        fontFamily: groldReg,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
