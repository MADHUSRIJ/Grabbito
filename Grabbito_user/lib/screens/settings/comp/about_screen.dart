import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:iconly/iconly.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _htmlData = '';
  @override
  void initState() {
    super.initState();
    _htmlData = PreferenceUtils.getString(PreferenceNames.aboutInfoSetting);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, about).toString(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
              fontFamily: groldReg, color: colorBlack, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          child: Html(
            data: _htmlData,
          ),
        ),
      ),
    );
  }
}
