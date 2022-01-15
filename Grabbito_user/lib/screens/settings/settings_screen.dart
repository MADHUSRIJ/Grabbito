import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/setting_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/home/home_screen.dart';
import 'package:grabbito/screens/settings/comp/edit_profile_widget.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

final scaffoldState = GlobalKey<ScaffoldState>();

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? isOffline;
  bool? isService = true;
  bool _loading = false;

  String userName = "UserName",
      phoneNo = "123456789",
      emailAdd = "demo@gmail.com";

  @override
  void initState() {
    super.initState();

    if (PreferenceUtils.getString(PreferenceNames.loggedInUserName) != 'N/A') {
      userName = PreferenceUtils.getString(PreferenceNames.loggedInUserName);
    }
    if (PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber) !=
        'N/A') {
      phoneNo =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber);
    }
    if (PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber) !=
        'N/A') {
      emailAdd = PreferenceUtils.getString(PreferenceNames.loggedInUserEmailId);
    }
    CommonFunction.checkForPermission();
    settingData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldState,
        resizeToAvoidBottomInset: true,
        backgroundColor: colorWhite,
        appBar: AppBar(
          leadingWidth: 40,
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(IconlyBold.profile,size: 24.0,color: colorBlack,),
          ),

          backgroundColor: colorWhite,
          title: Text(
            getTranslated(context, profileTitle).toString(),
            style: TextStyle(
                fontFamily: groldReg, color: colorBlack, fontSize: 20,fontWeight: FontWeight.w400),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 0,
          progressIndicator: SpinKitFadingCircle(color: colorRed),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/profile.png"),fit: BoxFit.fill)
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            userName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '$phoneNo  |  $emailAdd',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                    IconlyBold.editSquare,
                    color: colorBlack,
                    size: 24,
                  ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, editProfile).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          if (PreferenceUtils.getBool(
                                  PreferenceNames.checkLogin) ==
                              true) {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => EditProfileWidget(),
                              isScrollControlled: true,
                            );
                          } else {
                            CommonFunction.toastMessage(
                                getTranslated(context, loginPlease).toString());
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.lock,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, changePassword).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, changePasswordRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.chat,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, changeLanguage).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, changeLanguageRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.location,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, manageLocation).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, manageLocationRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.notification,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, notificationCenter).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, notificationCenterRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.user_3,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, support).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, supportRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.info_square,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, about).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, aboutRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.ticket,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, privacyPolicy).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, privacyPolicyRoute);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.tick_square,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          getTranslated(context, termsAndConditions).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, termsAndConditionRoute);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          IconlyBold.logout,
                          color: colorBlack,
                          size: 24,
                        ),
                        trailing: Icon(
                          IconlyLight.arrow_right_2,
                          color: colorBlack,
                          size: 20,
                        ),
                        title: Text(
                          PreferenceUtils.getBool(PreferenceNames.checkLogin) ==
                                  false
                              ? getTranslated(context, login).toString()
                              : getTranslated(context, logout).toString(),
                          style: TextStyle(
                              fontFamily: groldReg,
                              color: colorBlack,
                              fontSize: 18),
                        ),
                        onTap: () {
                          if (PreferenceUtils.getBool(
                                  PreferenceNames.checkLogin) ==
                              true) {
                            PreferenceUtils.clear();
                            PreferenceUtils.setBool(
                                PreferenceNames.checkLogin, false);
                          }
                          Navigator.pushNamedAndRemoveUntil(
                              context, loginRoute, (route) => false);
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
                    getTranslated(context, versionText).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorDivider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(3),
          ),
        )) ??
        false;
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  Future<BaseModel<SettingModel>> settingData() async {
    SettingModel response;
    try {
      setState(() {
        _loading = true;
      });

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
