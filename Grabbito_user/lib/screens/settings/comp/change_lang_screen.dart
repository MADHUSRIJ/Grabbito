import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/main.dart';
import 'package:grabbito/model/languages_model.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:iconly/iconly.dart';

class ChangeLanguageScreen extends StatefulWidget {
  @override
  _ChangeLanguageScreenState createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  int? value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        elevation: 1,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, changeLanguage).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: ListView.separated(
          itemCount: Language.languageList().length,
          padding: EdgeInsets.only(bottom: 20),
          separatorBuilder: (context, index) => SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          itemBuilder: (context, index) {
            value = 0;
            value = Language.languageList()[index].languageCode ==
                    PreferenceUtils.getString(
                        PreferenceNames.currentLanguageCode)
                ? index
                : null;
            if (PreferenceUtils.getString(
                    PreferenceNames.currentLanguageCode) ==
                'N/A') {
              value = 0;
            }
            return Card(
              margin: EdgeInsets.zero,
              child: Container(
                height: ScreenUtil().setHeight(75),
                alignment: Alignment.center,
                child: RadioListTile(
                  tileColor: colorWhite,
                  value: index,
                  controlAffinity: ListTileControlAffinity.trailing,
                  groupValue: value,
                  activeColor: colorBlack,
                  selectedTileColor: colorBlack,
                  onChanged: (dynamic value) async {
                    this.value = value;
                    Locale local = await setLocale(
                        Language.languageList()[index].languageCode);
                    setState(() {
                      MyApp.setLocale(context, local);
                      PreferenceUtils.setString(
                          PreferenceNames.currentLanguageCode,
                          Language.languageList()[index].languageCode);
                      Navigator.of(context).pop();
                    });
                  },
                  title: index == 0
                      ? Text.rich(
                          TextSpan(
                            text: Language.languageList()[index].name,
                            style: TextStyle(
                              fontFamily: groldReg,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colorBlack,
                            ),
                            children: const [
                              TextSpan(
                                  text: ' (Default)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: colorBlack,
                                      fontFamily: groldReg))
                            ],
                          ),
                        )
                      : Text(
                          Language.languageList()[index].name,
                          style: TextStyle(
                            fontFamily: groldReg,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: colorBlack,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
