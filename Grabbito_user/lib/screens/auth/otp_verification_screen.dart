import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class OtpVerificationScreen extends StatefulWidget {
  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();
  bool _loading = false;
  String fullOtp = "";
  String fromWhere = "register";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            getTranslated(context, otpVerification).toString(),
            style: TextStyle(
                fontFamily: 'Grold Black',
                color: colorBlack,
                fontSize: 18),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 1.0,
          color: Colors.transparent.withOpacity(0.2),
          progressIndicator: SpinKitFadingCircle(color: colorRed),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: height / 2,
                    child: Image.asset('assets/images/otp_icon.png'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        child: TextField(
                          controller: otp1Controller,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              counterText: ''),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: colorButton),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        child: TextField(
                          controller: otp2Controller,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              counterText: ''),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: colorButton),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        child: TextField(
                          controller: otp3Controller,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              counterText: ''),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: colorButton),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                        alignment: Alignment.center,
                        height: 50,
                        width: 50,
                        child: TextField(
                          controller: otp4Controller,
                          onChanged: (value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              counterText: ''),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: colorButton),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    height: 45,
                    minWidth: width * 0.8,
                    color: colorButton,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      getTranslated(context, verifyOtp).toString(),
                      style: TextStyle(
                          fontFamily: 'Grold Bold', fontSize: 16),
                    ),
                    onPressed: () {
                      if (otp1Controller.text.isNotEmpty &&
                          otp2Controller.text.isNotEmpty &&
                          otp3Controller.text.isNotEmpty &&
                          otp4Controller.text.isNotEmpty) {
                        fullOtp = otp1Controller.text +
                            otp2Controller.text +
                            otp3Controller.text +
                            otp4Controller.text;
                        checkOtp();
                      } else {
                        CommonFunction.toastMessage(
                            "Please fill the otp field");
                      }
                    },
                    splashColor: Colors.redAccent,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      resendOtp();
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        getTranslated(context, resendOtpVar).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorBlack, fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      getTranslated(context, otpMessage).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorBlack, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<BaseModel<String>> checkOtp() async {
    String response;
    int userId = int.parse(
        PreferenceUtils.getString(PreferenceNames.forgotPasswordUserId));
    fromWhere = PreferenceUtils.getString(PreferenceNames.forgotPasswordWhere);
    print(userId.toString() + fromWhere.toString());
    try {
      setState(() {
        _loading = true;
      });
      Map<String, dynamic> bodyForApi = {
        'user_id': userId.toString(),
        'otp': fullOtp,
        'where': fromWhere,
      };
      response = await ApiServices(ApiHeader().dioData()).checkOtp(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        if (fromWhere == "register") {
          Navigator.pushReplacementNamed(context, login);
        } else {
          Navigator.pushNamed(context, newPasswordRoute);
        }
      } else {
        CommonFunction.toastMessage(body["data"]);
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

  Future<BaseModel<String>> resendOtp() async {
    String response;
    String email = PreferenceUtils.getString(PreferenceNames.resendEmail);

    if (PreferenceUtils.getString(PreferenceNames.forgotPasswordWhere)
        .isNotEmpty) {
      fromWhere =
          PreferenceUtils.getString(PreferenceNames.forgotPasswordWhere);
    }
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> bodyForAPi = {'email': email, 'where': fromWhere};
      response = await ApiServices(ApiHeader().dioData()).sendOtp(bodyForAPi);

      final body = json.decode(response);
      bool? success = body['success'];

      int userId = body['data']["id"];
      print(userId);
      PreferenceUtils.setInt(PreferenceNames.forgotPasswordUserId, userId);
      if (success == true) {
        Navigator.pushNamed(context, otpVerificationRoute);
      } else {
        CommonFunction.toastMessage(body["msg"].toString());
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
