import 'package:flutter/material.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/routes/route_names.dart';

class SetupLocationWidget extends StatefulWidget {
  @override
  _SetupLocationWidgetState createState() => _SetupLocationWidgetState();
}

class _SetupLocationWidgetState extends State<SetupLocationWidget> {
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
          child: Image.asset('assets/images/setup_location.png'),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          getTranslated(context, setupLocation).toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Grold Black', fontSize: 20),
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
                fontSize: 20,
                fontFamily: 'Grold Regular'),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Text(
                getTranslated(context, changeLocation).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Grold Bold',
                    fontSize: 16,
                    color: colorBlue),
              ),
              onTap: () async {
                await Navigator.pushNamed(context, manageLocationRoute);
                setState(() {
                  print('come back');
                });
              },
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: colorBlue,
              size: 16,
            )
          ],
        ),
      ],
    );
  }
}
