import 'package:flutter/cupertino.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/routes/route_names.dart';

class RemoveAccountWidget extends StatefulWidget {
  @override
  _RemoveAccountWidgetState createState() => _RemoveAccountWidgetState();
}

class _RemoveAccountWidgetState extends State<RemoveAccountWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          child: Text(
            '$removeYourAccount !',
            style: TextStyle(
                fontFamily: groldXBold, color: colorBlack, fontSize: 18),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Text(
            'Are you sure you want to remove your account permanently ?',
            textAlign: TextAlign.start,
            style: TextStyle(
                color: colorDivider, fontFamily: groldReg, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Text(
                  'Yes, Remove It',
                  style: TextStyle(
                      color: colorBlue,
                      fontFamily: groldBold,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pushNamed(context, homeRoute);
                },
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: Text(
                  'No, Go Back',
                  style: TextStyle(
                      color: colorRed,
                      fontFamily: groldBold,
                      fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
