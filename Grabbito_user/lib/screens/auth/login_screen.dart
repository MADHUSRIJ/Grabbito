import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/constant/common_validations.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/setting_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/model/login_model.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _loading = false;
  bool _isHidden = true;
  bool _isChecked = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    settingData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 1.0,
      color: Colors.transparent.withOpacity(0.2),
      progressIndicator: SpinKitFadingCircle(color: colorRed),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: height / 2,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/login_back.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: Text(
                          "--  ${getTranslated(context, skip).toString()}",
                          style: TextStyle(
                              fontFamily: 'Grold Regular',
                              color: colorBlack),
                        ),
                        onTap: () => Navigator.pushNamed(context, homeRoute),
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
                            getTranslated(context, email).toString(),
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
                              hintText:
                                  getTranslated(context, emailHint).toString(),
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
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: Colors.grey,
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isChecked = !_isChecked;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () => print("Remember me"),
                              child: Text(
                                getTranslated(context, rememberMe).toString(),
                                style: TextStyle(
                                  color: colorBlack,
                                  fontSize: 14,
                                  fontFamily: groldReg,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            child: Text(
                              getTranslated(context, forgotPassword).toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: colorBlack,
                                fontSize: 14,
                                fontFamily: groldReg,
                              ),
                            ),
                            onTap: () => Navigator.pushNamed(
                                context, forgotPasswordRoute),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      height: 45,
                      minWidth: width * 0.9,
                      color: colorButton,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        getTranslated(context, loginOngrabbito).toString(),
                        style: TextStyle(
                            fontFamily: groldBold, fontSize: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _formKey.currentState!.save();
                            checkLogin(
                                emailController.text, passwordController.text);
                          });
                        }
                        FocusScope.of(context).unfocus();
                      },
                      splashColor: Colors.redAccent,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: Text(
                        getTranslated(context, doNotHaveAnAccount).toString(),
                        style: TextStyle(
                          color: colorBlack,
                          fontSize: 14,
                          fontFamily: groldReg,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(context, registerRoute),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Future<BaseModel<LoginModel>> checkLogin(
      String email, String password) async {
    LoginModel response;
    try {
      setState(() {
        _loading = true;
      });
      String deviceToken =
          PreferenceUtils.getString(PreferenceNames.onesignalPushToken);
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'device_token': deviceToken,
      };
      response = await ApiServices(ApiHeader().dioData()).login(body);
      if (response.success == true) {
        if (response.data!.verified == "1") {
          saveValueInPref(response);
          Navigator.pushReplacementNamed(context, homeRoute);
        } else {
          PreferenceUtils.setString(
              PreferenceNames.forgotPasswordWhere, "register");
          Navigator.pushReplacementNamed(context, otpVerificationRoute);
        }
      } else {
        CommonFunction.toastMessage(response.message.toString());
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

  Future<BaseModel<SettingModel>> settingData() async {
    SettingModel response;
    try {
      response = await ApiServices(ApiHeader().dioData()).settingApi();

      if (response.success == true) {
        PreferenceUtils.setString(
            PreferenceNames.appNameSetting, response.data!.name.toString());
        PreferenceUtils.setString(PreferenceNames.currencyCodeSetting,
            response.data!.currencyCode.toString());
        PreferenceUtils.setString(PreferenceNames.currencySymbolSetting,
            response.data!.currencySymbol.toString());
        PreferenceUtils.setString(PreferenceNames.aboutInfoSetting,
            response.data!.userAbout.toString());
        PreferenceUtils.setString(PreferenceNames.tAndCInfoSetting,
            response.data!.userTAndC.toString());
        PreferenceUtils.setString(PreferenceNames.privacyInfoSetting,
            response.data!.userPrivacy.toString());
        PreferenceUtils.setString(PreferenceNames.deliveryChargeBasedOnSetting,
            response.data!.deliveryChargeBasedOn.toString());
        PreferenceUtils.setString(PreferenceNames.deliveryChargeSetting,
            response.data!.deliveryCharges.toString());
        PreferenceUtils.setString(PreferenceNames.amountBaseOnSetting,
            response.data!.amountBasedOn.toString());
        PreferenceUtils.setString(
            PreferenceNames.amountSetting, response.data!.amount.toString());
        PreferenceUtils.setString(
            PreferenceNames.autoRefresh, response.data!.autoRefresh!);
        if (response.data!.paypal == "1") {
          PreferenceUtils.setString(PreferenceNames.paypalAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalAvailable, "0");
        }
        if (response.data!.razor == "1") {
          PreferenceUtils.setString(PreferenceNames.razorPayAvailable.toString(), "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.razorPayAvailable.toString(), "0");
        }
        if (response.data!.stripe == "1") {
          PreferenceUtils.setString(PreferenceNames.stripeAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.stripeAvailable, "0");
        }
        if (response.data!.cod == "1") {
          PreferenceUtils.setString(PreferenceNames.codAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.codAvailable, "0");
        }
        if (response.data!.razorKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.razorPayKey, response.data!.razorKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.razorPayKey, "");
        }
        if (response.data!.flutterwaveKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.flutterWaveKey, response.data!.flutterwaveKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.flutterWaveKey, "");
        }
        if (response.data!.paypalProductionKey != null) {
          PreferenceUtils.setString(PreferenceNames.paypalProductionKey,
              response.data!.paypalProductionKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalProductionKey, "");
        }
        if (response.data!.paypalEnviromentKey != null) {
          PreferenceUtils.setString(PreferenceNames.paypalEnvironmentKey,
              response.data!.paypalEnviromentKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalEnvironmentKey, "");
        }
        if (response.data!.paystackKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.payStackKey, response.data!.paystackKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.payStackKey, "");
        }
        if (response.data!.stripeSecretKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.stripeSecretKey, response.data!.stripeSecretKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.stripeSecretKey, "");
        }
        if (response.data!.stripePublicKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.stripePublicKey, response.data!.stripePublicKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.stripePublicKey, "");
        }
        if (response.data!.userAppId != null) {
          PreferenceUtils.setString(
              PreferenceNames.onesignalUserAppID, response.data!.userAppId!);
        } else {
          PreferenceUtils.setString(PreferenceNames.onesignalUserAppID, "");
        }
        if (PreferenceUtils.getString(PreferenceNames.onesignalPushToken)
                .isNotEmpty ||
            PreferenceUtils.getString(PreferenceNames.onesignalPushToken) !=
                'N/A') {
          getOneSingleToken(
              PreferenceUtils.getString(PreferenceNames.onesignalUserAppID));
        } else {
          CommonFunction.toastMessage('Error while get app setting data.');
        }
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSingleToken(String appId) async {
    // String push_token = '';
    String? userId = '';
    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none); // for onesignal debug
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await (OneSignal.shared.getDeviceState());
    // var pushtoken = await status.subscriptionStatus.pushToken;
    userId = status!.userId;
    print("pushtoken1:$userId");
    // print("pushtoken123456:$pushtoken");
    // push_token = pushtoken-;

    if (PreferenceUtils.getString(PreferenceNames.onesignalPushToken).isEmpty) {
    } else {
      PreferenceUtils.setString(PreferenceNames.onesignalPushToken, userId!);
    }
    print('ok =======5');
  }

  void saveValueInPref(LoginModel response) {
    PreferenceUtils.setBool(PreferenceNames.checkLogin, true);
    if (response.data!.id != null) {
      PreferenceUtils.setString(
          PreferenceNames.loggedInUserId, response.data!.id.toString());
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
    if (response.data!.token != null) {
      PreferenceUtils.setString(
          PreferenceNames.headerToken, response.data!.token.toString());
    } else {
      PreferenceUtils.setString(PreferenceNames.headerToken, '');
    }
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
