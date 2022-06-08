import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/constant/common_validations.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

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
            getTranslated(context, forgotPasswordTitle).toString(),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 2,
                      child: Image.asset('assets/images/email.png'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          right: 20, left: 20, top: height / 30),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 0.5, color: colorButton)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, emailAddress).toString(),
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 14),
                          ),
                          TextFormField(
                            controller: emailController,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            validator: ValidationConstants.kValidateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, emailAddressHint)
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    MaterialButton(
                      height: 45,
                      minWidth: width * 0.85,
                      color: colorButton,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        getTranslated(context, verifyAccount).toString(),
                        style: TextStyle(
                            fontFamily: 'Grold Bold', fontSize: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _formKey.currentState!.save();
                            sendOtp(emailController.text, "forgot_password");
                          });
                        }
                      },
                      splashColor: Colors.redAccent,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      getTranslated(context, forgotMessage).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorBlack,
                        fontSize: 11,
                        fontFamily: 'Grold Regular',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<BaseModel<String>> sendOtp(String email, String where) async {
    String response;
    PreferenceUtils.setString(PreferenceNames.resendEmail, email);
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> bodyForAPi = {
        'email': email,
        'where': where,
      };
      response = await ApiServices(ApiHeader().dioData()).sendOtp(bodyForAPi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        int userId = body['data']["id"];
        print(userId);
        // if(userId.){
        PreferenceUtils.setInt(PreferenceNames.forgotPasswordUserId, userId);
        PreferenceUtils.setString(
            PreferenceNames.forgotPasswordWhere, "forgot_password");
        // }
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
