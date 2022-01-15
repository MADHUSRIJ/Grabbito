import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';

class NoInternetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        SizedBox(
          height: height / 2,
          child: SvgPicture.asset('assets/images/ic_no_internet.svg'),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          getTranslated(context, noInternet).toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Grold Black', fontSize: 16),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            getTranslated(context, setupDesc).toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colorBlack,
                fontSize: 12,
                fontFamily: 'Grold Regular'),
          ),
        ),
      ],
    );
  }
}
