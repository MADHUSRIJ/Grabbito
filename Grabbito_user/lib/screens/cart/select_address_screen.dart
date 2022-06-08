import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/show_all_location_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/set_location/select_address_from_map.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/size_config.dart';

class SelectAddressScreen extends StatefulWidget {
  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  int? value = 1;
  bool _loading = false;
  List<ShowAllLocationData> location = [];
  late Map<String, dynamic> passPaymentData;
  String selectedAddress = '', selectedLandmark = '', selectedType = '';
  double selectedLat = 0.0, selectedLong = 0.0;
  int selectedId = 0;

  @override
  void initState() {
    super.initState();
    showAppLocationApi();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, selectAddress).toString(),
          style: TextStyle(
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent,
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                RadioListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: 1,
                  groupValue: value,
                  activeColor: colorPrimary,
                  onChanged: (dynamic val) {
                    setState(() {
                      value = val;
                    });
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: colorBlack,
                        size: 25,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        width: SizeConfig.screenWidth! / 1.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: SizeConfig.screenWidth! / 1.6,
                              child: Text(
                                getTranslated(context, yourCurrentLocation)
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: groldBold,
                                ),
                              ),
                            ),
                            Text(
                              PreferenceUtils.getString(
                                  PreferenceNames.addressOfSetLocation),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: groldReg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: SizeConfig.screenWidth! / 3,
                      color: colorDivider,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        getTranslated(context, orText).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Prozima Nova Reg'),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: SizeConfig.screenWidth! / 2.5,
                      color: colorDivider,
                    )
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  getTranslated(context, selectFromSavedLocation).toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: groldXBold,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: location.length,
                  padding: EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    return RadioListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: 2 + index,
                      groupValue: value,
                      activeColor: colorPrimary,
                      onChanged: (dynamic val) {
                        setState(() {
                          value = val;
                          selectedId = location[index].id!.toInt();
                          selectedAddress = location[index].address.toString();
                          selectedLandmark =
                              location[index].landmark.toString();
                          selectedType =
                              location[index].locationType.toString();
                          selectedLat =
                              double.parse(location[index].lat.toString());
                          selectedLong =
                              double.parse(location[index].lang.toString());
                        });
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: colorBlack,
                            size: 25,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            width: SizeConfig.screenWidth! / 1.7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: SizeConfig.screenWidth! / 1.6,
                                  child: Text(
                                    location[index].locationType.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: groldBold,
                                    ),
                                  ),
                                ),
                                Text(
                                  location[index].address.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: groldReg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: SizeConfig.screenWidth! / 3,
                      color: colorDivider,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        getTranslated(context, orText).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Prozima Nova Reg'),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: SizeConfig.screenWidth! / 2.5,
                      color: colorDivider,
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/ic_map.png'),
                      SizedBox(width: 10),
                      Text(
                        getTranslated(context, selectLocationFromMap)
                            .toString(),
                        style: TextStyle(
                            fontFamily: 'Grold Regular',
                            color: colorBlue,
                            fontSize: 16),
                      )
                    ],
                  ),
                  onTap: () {
                    PreferenceUtils.setString(
                        PreferenceNames.checkManageLocationPath,
                        "fromSelectAddress");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectMapAddress()));
                    setState(() {
                      showAppLocationApi();
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (value != null && value! > 0) {
            if (value! > 1) {
              PreferenceUtils.setInt(
                  PreferenceNames.idOfSetLocation, selectedId);
              PreferenceUtils.setString(
                  PreferenceNames.addressOfSetLocation, selectedAddress);
              PreferenceUtils.setString(
                  PreferenceNames.landMarkOfSetLocation, selectedLandmark);
              PreferenceUtils.setString(
                  PreferenceNames.locationTypeOfSetLocation, selectedType);
              PreferenceUtils.setDouble(
                  PreferenceNames.latOfSetLocation, selectedLat);
              PreferenceUtils.setDouble(
                  PreferenceNames.longOfSetLocation, selectedLong);
            }
            setState(() {});
            Navigator.pushReplacementNamed(context, cartScreenRoute);
          } else {
            CommonFunction.toastMessage("Please select address");
          }
        },
        child: Container(
          height: 60,
          width: SizeConfig.screenWidth,
          color: colorOrange,
          child: Center(
            child: Container(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                getTranslated(context, selectAddress).toString(),
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: groldReg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<ShowAllLocationModel>> showAppLocationApi() async {
    ShowAllLocationModel response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData()).showAllLocation();

      location.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          location.addAll(response.data!);
        }
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
