import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/constant/common_validations.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/register_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _isHidden = true;
  bool _isHidden2 = true;
  String _selectedCountryCode = '+91';
  List<String> countryCodes = ['+91', '+92'];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var countryDropDown = SizedBox(
      width: 30,
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              iconSize: 0.0,
              value: _selectedCountryCode,
              items: countryCodes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        fontFamily: 'Grold XBold',
                        color: colorBlack,
                        fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value.toString();
                });
              },
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1.5,
                  color: colorButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            getTranslated(context, createNewAccount).toString(),
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
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          right: 20, left: 20, top: height / 20),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 0.5, color: colorButton)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, fullName).toString(),
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 14),
                          ),
                          TextFormField(
                            controller: fullNameController,
                            validator: ValidationConstants.kValidateName,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, fullNameHint)
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
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
                            validator: ValidationConstants.kValidateEmail,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
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
                            getTranslated(context, contactNumber).toString(),
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 14),
                          ),
                          TextFormField(
                            controller: contactController,
                            validator: ValidationConstants.kValidateContactNo,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  getTranslated(context, contactNumberHint)
                                      .toString(),
                              prefixIcon: countryDropDown,
                            ),
                          ),
                        ],
                      ),
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
                            getTranslated(context, password).toString(),
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 14),
                          ),
                          TextFormField(
                            controller: passwordController,
                            validator: ValidationConstants.kValidatePassword,
                            keyboardType: TextInputType.text,
                            obscureText: _isHidden,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, passwordHint)
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
                            obscureText: _isHidden2,
                            style: TextStyle(
                                fontFamily: 'Grold Regular', fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  getTranslated(context, confirmPasswordHint)
                                      .toString(),
                              suffix: InkWell(
                                onTap: _togglePasswordViewCon,
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      child: Center(
                          child: Text.rich(TextSpan(
                              text:
                                  getTranslated(context, termsDesc).toString(),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
                              children: <TextSpan>[
                            TextSpan(
                                text: getTranslated(context, terms).toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // code to open / launch terms of service link here
                                  }),
                            TextSpan(
                                text:
                                    ' ${getTranslated(context, andText).toString()} ',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: getTranslated(context, privacy)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // code to open / launch privacy policy link here
                                        })
                                ])
                          ]))),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      height: 45,
                      minWidth: width * 0.8,
                      color: colorButton,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        getTranslated(context, createAccount).toString(),
                        style: TextStyle(
                            fontFamily: 'Grold Bold', fontSize: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _formKey.currentState!.save();
                            callApiRegister(
                                fullNameController.text,
                                emailController.text,
                                passwordController.text,
                                confirmPasswordController.text,
                                contactController.text,
                                _selectedCountryCode);
                          });
                        }
                      },
                      splashColor: Colors.redAccent,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Text(
                        getTranslated(context, alreadyHaveAnAccountLogin)
                            .toString(),
                        style: TextStyle(color: colorBlack, fontSize: 14),
                      ),
                      onTap: () => Navigator.pushNamed(context, loginRoute),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<BaseModel<RegisterModel>> callApiRegister(
      String name,
      String email,
      String password,
      String confirmPassword,
      String phone,
      String phoneCode) async {
    RegisterModel response;
    try {
      setState(() {
        _loading = true;
      });

      Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
        'phone_code': phoneCode,
      };
      response = await ApiServices(ApiHeader().dioData()).register(body);

      if (response.success == true) {
        PreferenceUtils.setString(
            PreferenceNames.forgotPasswordWhere, "register");
        if (response.data!.verified == 1) {
          saveValueInPref(response);
          Navigator.pushNamed(context, loginRoute);
        } else {
          saveValueInPref(response);
          Navigator.pushReplacementNamed(context, otpVerificationRoute);
        }
      } else {
        CommonFunction.toastMessage(response.msg.toString());
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

  void saveValueInPref(RegisterModel response) {
    // PreferenceUtils.setBool(PreferenceNames.checkLogin, true);
    if (response.data!.id != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserId, response.data!.id.toString());
      PreferenceUtils.setString(
          PreferenceNames.forgotPasswordUserId, response.data!.id.toString());
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserId, '');
    }
    if (response.data!.name != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserName, response.data!.name.toString());
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserName, '');
    }
    if (response.data!.image != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserImage, response.data!.image!.toString());
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserImage, '');
    }
    if (response.data!.email != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserEmailId, response.data!.email!);
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserEmailId, '');
    }
    if (response.data!.phone != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserPhoneNumber, response.data!.phone!);
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserPhoneNumber, '');
    }
    if (response.data!.phoneCode != null) {
      PreferenceUtils.setString(PreferenceNames.loggedInUserPhoneNumberCode,
          response.data!.phoneCode!);
    } else {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserPhoneNumberCode, '');
    }
    if (response.data!.verified != null) {
      PreferenceUtils.setString(PreferenceNames.loggedInUserVerified,
          response.data!.verified.toString());
    } else {
      PreferenceUtils.setString(PreferenceNames.loggedInUserVerified, '');
    }
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

  void _togglePasswordViewCon() {
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }
}
