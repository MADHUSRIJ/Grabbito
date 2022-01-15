import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
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

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isHidden = true;
  bool _loading = false;
  bool _isHidden2 = true;
  bool _isHidden3 = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            getTranslated(context, changePassword).toString(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
                fontFamily: groldReg, color: colorBlack, fontSize: 18),
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
                    SizedBox(height: 10),
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
                            getTranslated(context, oldPassword).toString(),
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 16),
                          ),
                          TextFormField(
                            controller: oldPasswordController,
                            validator: ValidationConstants.kValidatePassword,
                            keyboardType: TextInputType.text,
                            obscureText: _isHidden,
                            style: TextStyle(
                                fontFamily: groldReg,
                                fontSize: 20,
                                color: colorBlack),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, oldPasswordHint)
                                  .toString(),
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                  _isHidden
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
                    Container(
                      margin: EdgeInsets.only(
                          right: 20, left: 20, top: height / 25),
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
                                fontFamily: groldReg,
                                fontSize: 16,
                                color: colorBlack),
                          ),
                          TextFormField(
                            controller: passwordController,
                            validator: ValidationConstants.kValidatePassword,
                            keyboardType: TextInputType.text,
                            obscureText: _isHidden2,
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 20),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, newPasswordHint)
                                  .toString(),
                              suffix: InkWell(
                                onTap: _togglePasswordView2,
                                child: Icon(
                                  _isHidden2
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
                    Container(
                      margin: EdgeInsets.only(
                          right: 20, left: 20, top: height / 25),
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
                                  fontFamily: groldReg,
                                  fontSize: 16,
                                  color: colorBlack),
                            ),
                            alignment: Alignment.bottomLeft,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            validator: validateConfPassword,
                            keyboardType: TextInputType.text,
                            obscureText: _isHidden3,
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 20),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  getTranslated(context, confirmPasswordHint)
                                      .toString(),
                              suffix: InkWell(
                                onTap: _togglePasswordView3,
                                child: Icon(
                                  _isHidden3
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
                    SizedBox(height: 30),
                    MaterialButton(
                      height: 45,
                      minWidth: width * 0.8,
                      color: colorButton,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        getTranslated(context, changePassword).toString(),
                        style: TextStyle(
                          fontFamily: groldReg,
                          fontSize: 20,
                          color: colorWhite,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          changePasswordApi(
                              oldPasswordController.text,
                              passwordController.text,
                              confirmPasswordController.text);
                        }
                      },
                      splashColor: Colors.redAccent,
                    ),
                    SizedBox(height: 30),
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

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _togglePasswordView2() {
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }

  void _togglePasswordView3() {
    setState(() {
      _isHidden3 = !_isHidden3;
    });
  }

  Future<BaseModel<String>> changePasswordApi(
    String oldPassword,
    String password,
    String passwordConfirmation,
  ) async {
    String response;
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> bodyForAPi = {
        'old_password': oldPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      response =
          await ApiServices(ApiHeader().dioData()).changePassword(bodyForAPi);
      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        Navigator.of(context).pop();
        CommonFunction.toastMessage(body['data'].toString());
      } else {
        CommonFunction.toastMessage(body['data'].toString());
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
