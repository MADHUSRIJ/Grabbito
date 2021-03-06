import 'package:flutter/material.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';

class NoDataWidget extends StatelessWidget {
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
            child: Image.asset('assets/images/no_image.png')),
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
