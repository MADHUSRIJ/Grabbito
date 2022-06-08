import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _htmlData = '';
  @override
  void initState() {
    super.initState();
    _htmlData = PreferenceUtils.getString(PreferenceNames.privacyInfoSetting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, privacyPolicy).toString(),
          style: TextStyle(
              fontFamily: groldBlack, color: colorBlack, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: SafeArea(child: Html(data: _htmlData)),
      ),
    );
  }
}
