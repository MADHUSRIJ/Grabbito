import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
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
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class ManageLocationScreen extends StatefulWidget {
  @override
  _ManageLocationScreenState createState() => _ManageLocationScreenState();
}

class _ManageLocationScreenState extends State<ManageLocationScreen> {
  bool _loading = false;
  List<ShowAllLocationData> location = [];

  @override
  void initState() {
    super.initState();
    showAppLocationApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, manageLocation).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton.icon(
                onPressed: () {
                  PreferenceUtils.setString(
                      PreferenceNames.checkManageLocationPath,
                      'fromManageLocation');
                  Navigator.pushReplacementNamed(context, setLocationRoute);
                },
                icon: Icon(
                  Icons.add,
                  color: colorPurple,
                  size: 16,
                ),
                label: Text(
                  getTranslated(context, addButtonText).toString(),
                  style: TextStyle(
                      color: colorDivider,
                      fontSize: 14,
                      fontFamily: groldBold),
                )),
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent,
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: ListView.separated(
            itemCount: location.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  PreferenceUtils.setInt(
                      PreferenceNames.idOfSetLocation, location[index].id!);
                  PreferenceUtils.setString(
                      PreferenceNames.addressOfSetLocation,
                      location[index].address!);
                  PreferenceUtils.setString(
                      PreferenceNames.landMarkOfSetLocation,
                      location[index].landmark!);
                  PreferenceUtils.setString(
                      PreferenceNames.locationTypeOfSetLocation,
                      location[index].locationType!);
                  PreferenceUtils.setDouble(PreferenceNames.latOfSetLocation,
                      double.parse(location[index].lat!));
                  PreferenceUtils.setDouble(PreferenceNames.longOfSetLocation,
                      double.parse(location[index].lang!));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Row(
                             children: [
                               Icon(
                                 IconlyBold.location,
                                 color: colorOrange,
                                 size: 16,
                               ),
                               SizedBox(
                                 width: 10,
                               ),
                               Text(
                                 location[index].locationType.toString(),
                                 style: TextStyle(
                                   fontSize: 20,
                                   fontFamily: groldReg,
                                   fontWeight: FontWeight.w400,
                                   color: colorBlack,
                                 ),
                               ),
                             ],
                           ),
                            SizedBox(height: 12),
                            Text(
                              location[index].address.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: groldReg,
                                color: colorDivider,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              List<String> passDataForEditLocation = [];
                              passDataForEditLocation
                                  .add(location[index].id.toString());
                              passDataForEditLocation
                                  .add(location[index].userId.toString());
                              passDataForEditLocation
                                  .add(location[index].address.toString());
                              passDataForEditLocation
                                  .add(location[index].lat.toString());
                              passDataForEditLocation
                                  .add(location[index].lang.toString());
                              passDataForEditLocation
                                  .add(location[index].landmark.toString());
                              passDataForEditLocation
                                  .add(location[index].locationType.toString());
                              PreferenceUtils.setStringList(
                                  PreferenceNames.editLocationData,
                                  passDataForEditLocation);
                              PreferenceUtils.setBool(
                                  PreferenceNames
                                      .editLocationFromManageLocation,
                                  true);
                              Navigator.pushReplacementNamed(
                                  context, selectLocationScreenRoute);
                            },
                            child: Text(
                              getTranslated(context, editLocation).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorBlue,
                                fontFamily: groldReg,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            child: Text(
                              getTranslated(context, removeThisAddress)
                                  .toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorRed,
                                fontFamily: groldReg,
                              ),
                            ),
                            onPressed: () {
                              deleteLocationApi(
                                  location[index].id!.toInt(), index);
                            },
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              );
            },
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
        } else {}
      } else {}
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

  Future<BaseModel<String>> deleteLocationApi(int id, int index) async {
    String response;
    try {
      response = await ApiServices(ApiHeader().dioData()).deleteLocation(id);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        setState(() {
          location.removeAt(index);
        });
      } else {
        showAppLocationApi();
        CommonFunction.toastMessage("Error while delete the map address");
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
