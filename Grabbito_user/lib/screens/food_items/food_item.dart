import 'package:flutter/material.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/main.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/screens/common/widget_no_internet.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:iconly/iconly.dart';

class FoodItems extends StatefulWidget {
  final Submenu item;
  const FoodItems({Key? key, required this.item}) : super(key: key);

  @override
  _FoodItemsState createState() => _FoodItemsState();
}

class _FoodItemsState extends State<FoodItems> {
  bool isNetworkAvailable = true;
  bool isCartSymbolAvailable = false;
  int cartSymbolAvailableItems = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.only(top: 9, bottom: 9, left: 16),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorWidgetBorder,
              border: Border.all(width: 1, color: colorWidgetBg)),
          child: IconButton(
            icon: Icon(
              IconlyLight.arrow_left,
              color: colorBlack,
              size: 20.0,
            ),
            // padding: EdgeInsets.all(10),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          widget.item.name!.toString(),
          style: TextStyle(
              fontFamily: groldReg,
              fontWeight: FontWeight.w400,
              color: colorBlack,
              fontSize: 20),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            child: isNetworkAvailable == true
                ? SizedBox(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  children: [
                    widget.item.fullImage ==
                        "https://grabbito.com/public/images/upload/prod_default.png"
                        ? SizedBox()
                        : Container(
                      height: 252,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                              image: NetworkImage(
                                  widget.item.fullImage.toString()),
                              fit: BoxFit.fill)),
                    ),
                    widget.item.description == ""
                        ? SizedBox()
                        : Padding(
                      padding:  EdgeInsets.only(top: (widget.item.fullImage == "https://grabbito.com/public/images/upload/prod_default.png") ? 0 : 20),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.item.description.toString(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: groldReg,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff54545A),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : NoInternetWidget(),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    final allRows = await dbHelper.queryAllRows();
    if (allRows.isNotEmpty) {
      isCartSymbolAvailable = true;
      cartSymbolAvailableItems = allRows.length;
    }
  }
}
