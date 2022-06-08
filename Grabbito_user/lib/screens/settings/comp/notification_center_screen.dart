import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class NotificationCenterScreen extends StatefulWidget {
  @override
  _NotificationCenterScreenState createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  bool _loading = false;
  bool muteNotification = false;

  @override
  void initState() {
    super.initState();
    getUserProfileApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, notificationCenter).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent,
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setState(() {
                    muteNotification = !muteNotification;
                  });
                  if (muteNotification == true) {
                    updateProfileApi("1");
                  } else {
                    updateProfileApi("0");
                  }
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, muteNotificationName).toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: groldReg,
                        color: colorBlack,
                      ),
                    ),
                    FlutterSwitch(
                      height: 25,
                      width: 45,
                      borderRadius: 30,
                      padding: 5.5,
                      duration: Duration(milliseconds: 400),
                      activeColor: colorOrange,
                      inactiveColor: colorDivider,
                      activeToggleColor: colorWhite,
                      inactiveToggleColor: colorWhite,
                      toggleSize: 15,
                      value: muteNotification,
                      onToggle: (val) {
                        setState(() {
                          muteNotification = !muteNotification;
                        });
                        if (muteNotification == true) {
                          updateProfileApi("1");
                        } else {
                          updateProfileApi("0");
                        }
                      },
                    ),
                  ],
                ),
                subtitle: Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                      getTranslated(context, muteNotificationDesc).toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorDivider,
                        fontFamily: groldReg,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<String>> getUserProfileApi() async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData()).userProfile();

      final body = json.decode(response);

      setState(() {
        PreferenceUtils.setString(
            PreferenceNames.loggedInUserName, body['name']);
        PreferenceUtils.setString(
            PreferenceNames.loggedInUserPhoneNumberCode, body['phone_code']);
        PreferenceUtils.setString(
            PreferenceNames.loggedInUserPhoneNumber, body['phone']);
        if (body['notification'] == 0) {
          muteNotification = false;
        } else {
          muteNotification = true;
        }
      });

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

  Future<BaseModel<String>> updateProfileApi(String notificationData) async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData())
          .updateProfileForNotification(notificationData);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
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
