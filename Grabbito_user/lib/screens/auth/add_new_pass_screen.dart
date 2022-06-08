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

class NewPasswordScreen extends StatefulWidget {
  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool newPasswordHidden = true;
  bool confirmPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

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
            getTranslated(context, addNewPassword).toString(),
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 2.5,
                      child: Image.asset('assets/images/new_pass.png'),
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
                            getTranslated(context, newPassword).toString(),
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 14),
                          ),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            obscureText: newPasswordHidden,
                            validator: ValidationConstants.kValidatePassword,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, newPasswordHint)
                                  .toString(),
                              suffix: InkWell(
                                onTap: _toggleNewPasswordView,
                                child: Icon(
                                  newPasswordHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //confirm password
                    Container(
                      margin: EdgeInsets.only(
                          right: 20, left: 20, top: height / 30),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 0.5, color: colorButton)),
                      ),
                      child: Column(
                        children: [
                          Align(
                            child: Text(
                              getTranslated(context, confirmPassword)
                                  .toString(),
                              style: TextStyle(
                                  fontFamily: 'Grold Regular', fontSize: 14),
                            ),
                            alignment: Alignment.bottomLeft,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            validator: validateConfPassword,
                            keyboardType: TextInputType.text,
                            obscureText: confirmPasswordHidden,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  getTranslated(context, confirmPasswordHint)
                                      .toString(),
                              suffix: InkWell(
                                onTap: _toggleConPasswordView,
                                child: Icon(
                                  confirmPasswordHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 30),
                    MaterialButton(
                      height: 45,
                      minWidth: width * 0.85,
                      color: colorButton,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        getTranslated(context, changePassword).toString(),
                        style: TextStyle(
                            fontFamily: 'Grold Bold', fontSize: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _formKey.currentState!.save();
                            forgotPassword();
                          });
                        }
                      },
                      splashColor: Colors.redAccent,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      child: Text(
                        getTranslated(context, forgotMessage).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorBlack, fontSize: 11),
                      ),
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _formKey.currentState!.save();
                            // Navigator.pushNamed(context, loginRoute);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  String? validateConfPassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return "Confirm Password is Required";
    } else if (value.length < 6) {
      return "Confirm Password must be at least 6 characters";
    } else if (passwordController.text != confirmPasswordController.text) {
      return 'Password and Confirm Password does not match.';
    } else if (!regex.hasMatch(value)) {
      return 'Confirm Password required';
    } else {
      return null;
    }
  }

  Future<BaseModel<String>> forgotPassword() async {
    String response;
    int userId = PreferenceUtils.getInt(PreferenceNames.forgotPasswordUserId);
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> bodyForApi = {
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
        'user_id': userId.toString(),
      };

      response =
          await ApiServices(ApiHeader().dioData()).forgotPassword(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        Navigator.pushNamed(context, loginRoute);
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

  void _toggleNewPasswordView() {
    setState(() {
      newPasswordHidden = !newPasswordHidden;
    });
  }

  void _toggleConPasswordView() {
    setState(() {
      confirmPasswordHidden = !confirmPasswordHidden;
    });
  }
}
