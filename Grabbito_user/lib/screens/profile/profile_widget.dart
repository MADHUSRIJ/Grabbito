import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/homepage/order_history_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/cart/order_detail_screen.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  List<PastOrder> pastOrder = [];
  List<UpcomingOrder> upComingOrder = [];
  List<PickDropup> pickUpOrder = [];
  String userName = "UserName",
      phoneNo = "123456789",
      emailAdd = "demo@gmail.com";

  Future<BaseModel<OrderHistoryModel>>? orderHistoryData;

  @override
  void initState() {
    super.initState();
    if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == true) {
      orderHistoryData = orderHistory();
    }
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
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        orientation: Orientation.portrait);
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              IconlyBold.document,
              size: 24.0,
              color: colorBlack,
            ),
          ),
          backgroundColor: colorWhite,
          title: Text(
            getTranslated(context, orderTitle).toString(),
            style: TextStyle(
                fontFamily: groldReg,
                color: colorBlack,
                fontSize: 20,
                fontWeight: FontWeight.w400),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: colorOrange,
            indicatorWeight: 2.0,
            labelColor: colorOrange,
            unselectedLabelColor: colorBlack,
            tabs: [
              Tab(
                child: Text(
                  "${getTranslated(context, pastOrders).toString()} ${getTranslated(context, pastOrders2).toString()}",
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: groldReg,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Tab(
                child: Text(
                  "${getTranslated(context, upcomingOrders).toString()} ${getTranslated(context, upcomingOrders2).toString()}",
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: groldReg,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Tab(
                child: Text(
                  "${getTranslated(context, pickupOrders).toString()} ${getTranslated(context, pickupOrders2).toString()}",
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: groldReg,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),

              ),
            ],
          ),
        ),
        body: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          margin: EdgeInsets.only(left: 5, right: 5, top: 20),
          child: TabBarView(
            children: [
              //past_order
              FutureBuilder<BaseModel<OrderHistoryModel>>(
                future: orderHistoryData,
                builder: (context, snapshot) {
                  if (PreferenceUtils.getBool(PreferenceNames.checkLogin) ==
                      true) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return SpinKitFadingCircle(color: colorRed);
                    } else {
                      return pastOrder.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.separated(
                                itemCount: pastOrder.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 30),
                                separatorBuilder: (context, index) => SizedBox(
                                    height: ScreenUtil().setHeight(20)),
                                itemBuilder: (context, index) {
                                  return Container(
                                    // margin: EdgeInsets.only(top: 40),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width:
                                                  SizeConfig.screenWidth! / 1.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pastOrder[index]
                                                        .shop!
                                                        .name
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: groldBold,
                                                      color: colorBlack,
                                                    ),
                                                  ),
                                                  Text(
                                                    pastOrder[index]
                                                        .address!
                                                        .address
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: groldReg,
                                                      color: colorDivider,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${pastOrder[index].amount.toString()}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: groldReg,
                                                          color: colorBlack,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_outlined,
                                                        size: 15,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: ScreenUtil()
                                                      .setHeight(55),
                                                  child: Text(
                                                    pastOrder[index]
                                                        .orderStatus
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: groldReg,
                                                      color: colorBlack,
                                                    ),
                                                  ),
                                                ),
                                                () {
                                                  if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Pending") {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Approve") {
                                                    return Icon(
                                                      Icons.done,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Accept") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                              .orderStatus ==
                                                          "Reject" ||
                                                      pastOrder[index]
                                                              .orderStatus ==
                                                          "Cancel") {
                                                    return Icon(
                                                      Icons.highlight_off,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Driver PickedUp Item") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Reached") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Complete") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "Preparing Item") {
                                                    return Icon(
                                                      Icons.coffee_maker,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pastOrder[index]
                                                          .orderStatus ==
                                                      "On The Way") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  }
                                                }(),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: List.generate(
                                              600 ~/ 10,
                                              (index) => Expanded(
                                                    child: Container(
                                                      color: index % 2 == 0
                                                          ? Colors.transparent
                                                          : Colors.grey,
                                                      height: 1,
                                                    ),
                                                  )),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          () {
                                            if (pastOrder[index]
                                                .orderItems!
                                                .isNotEmpty) {
                                              String tempData = "",
                                                  tempItemName = "",
                                                  tempItemQuantity = "";
                                              for (int i = 0;
                                                  i <
                                                      pastOrder[index]
                                                          .orderItems!
                                                          .length;
                                                  i++) {
                                                tempItemName = pastOrder[index]
                                                    .orderItems![i]
                                                    .itemName!;
                                                tempItemQuantity =
                                                    pastOrder[index]
                                                        .orderItems![i]
                                                        .qty
                                                        .toString();
                                                tempData = tempData +
                                                    tempItemName +
                                                    " x " +
                                                    tempItemQuantity +
                                                    ', ';
                                              }

                                              String showUpcomingOrder =
                                                  tempData.substring(
                                                      0, tempData.length - 2);
                                              return showUpcomingOrder;
                                            } else {
                                              return "";
                                            }
                                          }(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorBlack,
                                          ),
                                        ),
                                        Text(
                                          pastOrder[index].date.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorDivider,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: List.generate(
                                            600 ~/ 10,
                                            (index) => Expanded(
                                              child: Container(
                                                color: index % 2 == 0
                                                    ? Colors.transparent
                                                    : Colors.grey,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  Transitions(
                                                    transitionType:
                                                        TransitionType.slideUp,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    widget: OrderDetailScreen(
                                                      singleOrderId:
                                                          pastOrder[index].id!,
                                                      whichOrder:
                                                          "regularOrder",
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                getTranslated(context, reOrder)
                                                    .toString(),
                                                style: TextStyle(
                                                  color: colorBlue,
                                                  fontSize: 16,
                                                  fontFamily: 'Grold Bold',
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no_image.png"),
                            Text(
                              getTranslated(context, noDataDesc).toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: groldReg,
                                color: colorBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: colorWhite),
                        onPressed: () {
                          Navigator.pushNamed(context, loginRoute);
                        },
                        child: Text(
                          getTranslated(context, loginPlease).toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: groldReg,
                            color: colorRed,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              // upcomming_order
              FutureBuilder(
                future: orderHistoryData,
                builder: (context, snapshot) {
                  if (PreferenceUtils.getBool(PreferenceNames.checkLogin) ==
                      true) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return SpinKitFadingCircle(color: colorRed);
                    } else {
                      return upComingOrder.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.separated(
                                itemCount: upComingOrder.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 30),
                                separatorBuilder: (context, index) => SizedBox(
                                    height: ScreenUtil().setHeight(20)),
                                itemBuilder: (context, index) {
                                  return Container(
                                    // margin: EdgeInsets.only(top: 40),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    upComingOrder[index]
                                                        .shop!
                                                        .name
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: groldBold,
                                                      color: colorBlack,
                                                    ),
                                                  ),
                                                  Text(
                                                    upComingOrder[index]
                                                        .address!
                                                        .address
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: groldReg,
                                                      color: colorDivider,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${upComingOrder[index].amount.toString()}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: groldReg,
                                                          color: colorBlack,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_outlined,
                                                        size: 15,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              width:
                                                  SizeConfig.screenWidth! / 1.5,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: ScreenUtil()
                                                      .setHeight(55),
                                                  child: Text(
                                                    upComingOrder[index]
                                                        .orderStatus
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: groldReg,
                                                      color: colorBlack,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                () {
                                                  if (upComingOrder[index]
                                                          .orderStatus ==
                                                      "Pending") {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Approve") {
                                                    return Icon(
                                                      Icons.done,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Accept") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                                  index]
                                                              .orderStatus ==
                                                          "Reject" ||
                                                      upComingOrder[index]
                                                              .orderStatus ==
                                                          "Cancel") {
                                                    return Icon(
                                                      Icons.highlight_off,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Driver PickedUp Item") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Reached") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Complete") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "Preparing Item") {
                                                    return Icon(
                                                      Icons.coffee_maker,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (upComingOrder[
                                                              index]
                                                          .orderStatus ==
                                                      "On The Way") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  }
                                                }(),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: List.generate(
                                              600 ~/ 10,
                                              (index) => Expanded(
                                                    child: Container(
                                                      color: index % 2 == 0
                                                          ? Colors.transparent
                                                          : Colors.grey,
                                                      height: 1,
                                                    ),
                                                  )),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          () {
                                            if (upComingOrder[index]
                                                .orderItems!
                                                .isNotEmpty) {
                                              String tempData = "",
                                                  tempItemName = "",
                                                  tempItemQuantity = "";
                                              for (int i = 0;
                                                  i <
                                                      upComingOrder[index]
                                                          .orderItems!
                                                          .length;
                                                  i++) {
                                                tempItemName =
                                                    upComingOrder[index]
                                                        .orderItems![i]
                                                        .itemName!;
                                                tempItemQuantity =
                                                    upComingOrder[index]
                                                        .orderItems![i]
                                                        .qty
                                                        .toString();
                                                tempData = tempData +
                                                    tempItemName +
                                                    " x " +
                                                    tempItemQuantity +
                                                    ', ';
                                              }

                                              String showUpcomingOrder =
                                                  tempData.substring(
                                                      0, tempData.length - 2);
                                              return showUpcomingOrder;
                                            } else {
                                              return "";
                                            }
                                          }(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorBlack,
                                          ),
                                        ),
                                        Text(
                                          upComingOrder[index].date.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorDivider,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: List.generate(
                                              600 ~/ 10,
                                              (index) => Expanded(
                                                    child: Container(
                                                      color: index % 2 == 0
                                                          ? Colors.transparent
                                                          : Colors.grey,
                                                      height: 1,
                                                    ),
                                                  )),
                                        ),
                                        SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  Transitions(
                                                    transitionType:
                                                        TransitionType.slideUp,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    widget: OrderDetailScreen(
                                                      singleOrderId:
                                                          upComingOrder[index]
                                                              .id!,
                                                      whichOrder:
                                                          "regularOrder",
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                getTranslated(context, reOrder)
                                                    .toString(),
                                                style: TextStyle(
                                                  color: colorBlue,
                                                  fontSize: 16,
                                                  fontFamily: groldBold,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          :  RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no_image.png"),
                            Text(
                              getTranslated(context, noDataDesc).toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: groldReg,
                                color: colorBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: colorWhite),
                        onPressed: () {
                          Navigator.pushNamed(context, loginRoute);
                        },
                        child: Text(
                          getTranslated(context, loginPlease).toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: groldReg,
                            color: colorRed,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              // pickup_and_drop_order
              FutureBuilder(
                future: orderHistoryData,
                builder: (context, snapshot) {
                  if (PreferenceUtils.getBool(PreferenceNames.checkLogin) ==
                      true) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return SpinKitFadingCircle(color: colorRed);
                    } else {
                      return pickUpOrder.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.separated(
                                itemCount: pickUpOrder.length,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 30),
                                separatorBuilder: (context, index) => SizedBox(
                                    height: ScreenUtil().setHeight(20)),
                                itemBuilder: (context, index) {
                                  return Container(
                                    // margin: EdgeInsets.only(top: 40),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pickUpOrder[index]
                                                        .shop!
                                                        .name!,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: groldBold,
                                                        color: colorBlack),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    getTranslated(
                                                            context, pickUp)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: groldReg,
                                                        color: colorBlack,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    pickUpOrder[index]
                                                        .pickupLocation!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: groldReg,
                                                      color: colorDivider,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    getTranslated(
                                                            context, dropOff)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: groldReg,
                                                        color: colorBlack,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    pickUpOrder[index]
                                                        .dropupLocation!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: groldReg,
                                                      color: colorDivider,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${pickUpOrder[index].amount.toString()}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: groldReg,
                                                          color: colorBlack,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_outlined,
                                                        size: 15,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              width:
                                                  SizeConfig.screenWidth! / 1.5,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: ScreenUtil()
                                                      .setHeight(55),
                                                  child: Text(
                                                    pickUpOrder[index]
                                                        .orderStatus
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: groldReg,
                                                      color: colorBlack,
                                                    ),
                                                  ),
                                                ),
                                                () {
                                                  if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Pending") {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Approve") {
                                                    return Icon(
                                                      Icons.done,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade200,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Accept") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                              .orderStatus ==
                                                          "Reject" ||
                                                      pickUpOrder[index]
                                                              .orderStatus ==
                                                          "Cancel") {
                                                    return Icon(
                                                      Icons.highlight_off,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Driver PickedUp Item") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade200,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Reached") {
                                                    return Icon(
                                                      Icons.check,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade200,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Complete") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "Preparing Item") {
                                                    return Icon(
                                                      Icons.coffee_maker,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade200,
                                                    );
                                                  } else if (pickUpOrder[index]
                                                          .orderStatus ==
                                                      "On The Way") {
                                                    return Icon(
                                                      Icons.check_circle,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade200,
                                                    );
                                                  } else {
                                                    return Icon(
                                                      Icons.error,
                                                      size: 15,
                                                      color: colorRed,
                                                    );
                                                  }
                                                }(),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: List.generate(
                                              600 ~/ 10,
                                              (index) => Expanded(
                                                    child: Container(
                                                      color: index % 2 == 0
                                                          ? Colors.transparent
                                                          : Colors.grey,
                                                      height: 1,
                                                    ),
                                                  )),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          pickUpOrder[index].category!.name!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorBlack,
                                          ),
                                        ),
                                        Text(
                                          () {
                                            String showDate = '';
                                            String tempDate = '';
                                            if (pickUpOrder[index]
                                                .createdAt!
                                                .isNotEmpty) {
                                              tempDate = pickUpOrder[index]
                                                  .createdAt!
                                                  .split('T')
                                                  .first;
                                              var inputFormat =
                                                  DateFormat('yyyy-MM-dd');
                                              var date1 =
                                                  inputFormat.parse(tempDate);
                                              var outputFormat =
                                                  DateFormat('dd-MM-yyyy');
                                              var date2 =
                                                  outputFormat.format(date1);
                                              showDate = date2.toString();
                                              return showDate;
                                            } else {
                                              return showDate;
                                            }
                                          }(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: groldReg,
                                            color: colorDivider,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: List.generate(
                                            600 ~/ 10,
                                            (index) => Expanded(
                                              child: Container(
                                                color: index % 2 == 0
                                                    ? Colors.transparent
                                                    : Colors.grey,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.center,
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  Transitions(
                                                    transitionType:
                                                        TransitionType.slideUp,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    widget: OrderDetailScreen(
                                                      singleOrderId:
                                                          pickUpOrder[index]
                                                              .id!,
                                                      whichOrder: "pickupOrder",
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                getTranslated(context, reOrder)
                                                    .toString(),
                                                style: TextStyle(
                                                  color: colorBlue,
                                                  fontSize: 16,
                                                  fontFamily: groldBold,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          :  RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no_image.png"),
                            Text(
                              getTranslated(context, noDataDesc).toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: groldReg,
                                color: colorBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: colorWhite),
                        onPressed: () {
                          Navigator.pushNamed(context, loginRoute);
                        },
                        child: Text(
                          getTranslated(context, loginPlease).toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: groldReg,
                            color: colorRed,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<OrderHistoryModel>> orderHistory() async {
    OrderHistoryModel response;
    try {
      response = await ApiServices(ApiHeader().dioData()).orderHistory();

      pastOrder.clear();
      if (response.success == true) {
        if (response.data!.pastOrder!.isNotEmpty) {
          pastOrder.addAll(response.data!.pastOrder!);
        }
        if (response.data!.upcomingOrder!.isNotEmpty) {
          upComingOrder.addAll(response.data!.upcomingOrder!);
        }
        if (response.data!.pickDropup!.isNotEmpty) {
          pickUpOrder.addAll(response.data!.pickDropup!);
        }
      }

      setState(() {
        // _loading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        // _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use refreshFailed()
    if (mounted) {
      setState(() {
        orderHistory();
      });
    }
  }
}
