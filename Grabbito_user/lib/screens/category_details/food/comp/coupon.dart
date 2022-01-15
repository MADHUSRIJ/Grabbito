import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class CouponWidget extends StatefulWidget {
  final Discount couponData;
  CouponWidget({Key? key, required this.couponData}) : super(key: key);
  @override
  _CouponWidgetState createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: [
        Container(
          width: SizeConfig.screenWidth,
          height: MediaQuery.of(context).size.height * 0.13,
          margin: EdgeInsets.all(0),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(10),
            padding: EdgeInsets.all(20),
            color: colorBlack,
            strokeWidth: 3,
            dashPattern: const [8, 6],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  () {
                    String shopAmount = '';
                    if (widget.couponData.type == "amount") {
                      shopAmount =
                          '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${widget.couponData.discount.toString()} ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${widget.couponData.minOrderAmount.toString()}';
                    } else {
                      shopAmount =
                          '${widget.couponData.discount.toString()}% ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${widget.couponData.minOrderAmount.toString()}';
                    }
                    return shopAmount;
                  }(),
                  style: TextStyle(
                      color: colorBlack,
                      fontSize: 25,
                      fontFamily: groldBold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${getTranslated(context, useCodeText).toString()} ${widget.couponData.code.toString()}',
                  style: TextStyle(
                      color: colorBlack,
                      fontSize: 18,
                      fontFamily: groldReg),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            Clipboard.setData(
                    ClipboardData(text: widget.couponData.code.toString()))
                .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  getTranslated(context, couponCopied).toString(),
                  style: TextStyle(fontSize: 16, fontFamily: groldBold),
                ),
                backgroundColor: colorBlue,
              ));
            });
          },
          icon: Icon(
            Icons.copy,
            color: colorBlue,
          ),
          label: Text(
            'Copy Coupon Code',
            style: TextStyle(
                color: colorBlue, fontSize: 16, fontFamily: groldBold),
          ),
        )
      ],
    );
  }
}
