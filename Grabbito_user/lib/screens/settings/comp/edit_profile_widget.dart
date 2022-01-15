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
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class EditProfileWidget extends StatefulWidget {
  @override
  _EditProfileWidgetState createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _selectedCountryCode = '+94';
  List<String> countryCodes = ['+91', '+1' , '+94'];

  @override
  void initState() {
    super.initState();
    if (PreferenceUtils.getString(PreferenceNames.loggedInUserName) != 'N/A') {
      fullNameController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserName);
    }

    if (PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber) !=
        'N/A') {
      contactController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber);
    }

    if (PreferenceUtils.getString(PreferenceNames.loggedInUserEmailId) !=
        'N/A') {
      emailController.text =
          PreferenceUtils.getString(PreferenceNames.loggedInUserEmailId);
    }

    if (PreferenceUtils.getString(
            PreferenceNames.loggedInUserPhoneNumberCode) !=
        'N/A') {
      _selectedCountryCode = PreferenceUtils.getString(
          PreferenceNames.loggedInUserPhoneNumberCode);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      fontFamily: groldReg,
                      color: colorBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w400
                    ),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent.withOpacity(0.2),
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Wrap(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              child: Text(
                getTranslated(context, editProfile).toString(),
                style: TextStyle(
                    fontFamily: groldReg,
                    color: colorOrange,
                    fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 20, left: 20, top: 10),
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
                                fontFamily: groldReg, fontSize: 16),
                          ),
                          TextFormField(
                            controller: fullNameController,
                            validator: ValidationConstants.kValidateName,
                            style: TextStyle(
                              fontFamily: groldReg,
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
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
                          right: 20,
                          left: 20,
                          top: SizeConfig.screenHeight! / 30),
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
                                fontFamily: 'Grold Regular', fontSize: 16),
                          ),
                          TextFormField(
                            controller: emailController,
                            readOnly: true,
                            validator: ValidationConstants.kValidateEmail,
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 18, fontWeight: FontWeight.w400),
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
                          right: 20,
                          left: 20,
                          top: SizeConfig.screenHeight! / 30),
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
                                fontFamily: 'Grold Regular', fontSize: 16),
                          ),
                          TextFormField(
                            controller: contactController,
                            validator: ValidationConstants.kValidateContactNo,
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 18 , fontWeight: FontWeight.w400),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: contactNumberHint,
                              prefixIcon: countryDropDown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          height: 45,
                          minWidth: SizeConfig.screenWidth! * 0.4,
                          color: colorDivider,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            getTranslated(context, cancel).toString(),
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 18,fontWeight: FontWeight.w400),
                          ),
                          onPressed: () => Navigator.pop(context),
                          splashColor: Colors.redAccent,
                        ),
                        MaterialButton(
                          height: 45,
                          minWidth: SizeConfig.screenWidth! * 0.4,
                          color: colorButton,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            getTranslated(context, editProfile).toString(),
                            style: TextStyle(
                                fontFamily: groldReg, fontSize: 18,fontWeight: FontWeight.w400),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              updateProfileApi(fullNameController.text,
                                  contactController.text, _selectedCountryCode);
                            }
                          },
                          splashColor: Colors.redAccent,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<BaseModel<String>> updateProfileApi(
      String name, String phone, String phoneCode) async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      Map<String, dynamic> bodyForApi = {
        'phone_code': phoneCode,
        'phone': phone,
        'name': name,
      };

      response =
          await ApiServices(ApiHeader().dioData()).updateProfile(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        Navigator.pop(context);
        PreferenceUtils.setString(PreferenceNames.loggedInUserName, name);
        PreferenceUtils.setString(
            PreferenceNames.loggedInUserPhoneNumberCode, phoneCode);
        PreferenceUtils.setString(
            PreferenceNames.loggedInUserPhoneNumber, phone);
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
