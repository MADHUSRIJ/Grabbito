import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/singleorder_package.dart';
import 'package:grabbito/model/track_order_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class OrderDetailScreen extends StatefulWidget {
  final int singleOrderId;
  final String whichOrder;

  const OrderDetailScreen({required this.singleOrderId, required this.whichOrder});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String orderId = "";
  dynamic amount = 0.0;
  dynamic tax = 0.0;
  dynamic deliveryCharge = 0.0;
  String pickUpAddress = "";
  String dropOffAddress = "";
  String orderStatus = "";
  String orderDate = "";
  String driverName = "";
  String discountCouponName = "";
  String discountPrice = "0";
  bool pickUpAddressStatus = false;
  bool dropOffAddressStatus = false;
  bool deliveredSuccess = false;
  List<OrderItems>? orderItems = [];
  bool _loading = false;
  bool isRegularOrder = false;
  bool showDriver = false;
  bool orderReject = false;
  bool orderCancel = false;
  String categoryNameForPackage = "";
  String packageWeight = "";

  @override
  void initState() {
    super.initState();
    if (widget.whichOrder == "regularOrder") {
      isRegularOrder = true;
      trackOrderApi(widget.singleOrderId);
    } else {
      trackOrderApiForPackage(widget.singleOrderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 1.0,
      color: Colors.transparent,
      progressIndicator: SpinKitFadingCircle(color: colorRed),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '${getTranslated(context, order).toString()} $orderId',
            style: TextStyle(
              fontWeight: FontWeight.w400,
                fontFamily: groldReg, color: colorBlack, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  _buildTimeline(),
                  Visibility(
                      visible: showDriver == true, child: SizedBox(height: 10)),
                  Visibility(
                    visible: showDriver == true,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        () {
                          if (orderReject) {
                            return "${getTranslated(context, orderRejectedName).toString()} on $orderDate";
                          } else {
                            return "${getTranslated(context, orderCancelName).toString()} on $orderDate";
                          }
                        }(),
                        style: TextStyle(
                          color: colorBlack,
                          fontFamily: groldReg,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Text(
                      getTranslated(context, billingDetails).toString(),
                      style: TextStyle(
                          color: colorOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: groldReg),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      children: [
                        ListView.separated(
                          itemCount: orderItems!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 15),
                          itemBuilder: (context, cartItemIndex) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    orderItems![cartItemIndex]
                                        .itemName
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: groldReg,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'x ${orderItems![cartItemIndex].qty}',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${orderItems![cartItemIndex].price}',
                                style: TextStyle(
                                  fontFamily: groldBold,
                                  color: colorBlack,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? DottedLine(dashColor: colorDivider)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, subtotalText)
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: groldReg,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    () {
                                      double tempPrice = 0.0;
                                      String showPrice = '';
                                      if (orderItems!.isNotEmpty) {
                                        for (int i = 0;
                                            i < orderItems!.length;
                                            i++) {
                                          tempPrice +=
                                              orderItems![i].price!.toInt();
                                        }
                                      }
                                      showPrice = tempPrice.toInt().toString();
                                      return '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}$showPrice';
                                    }(),
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      categoryNameForPackage,
                                      style: TextStyle(
                                        fontFamily: groldBold,
                                        color: colorBlack,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      packageWeight + " (kg)",
                                      style: TextStyle(
                                        fontFamily: groldBold,
                                        color: colorBlack,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? DottedLine(dashColor: colorDivider)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, taxText).toString(),
                                    style: TextStyle(
                                      fontFamily: groldReg,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}$tax',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, deliveryChargesText)
                                        .toString(),
                                    style: TextStyle(
                                      fontFamily: groldReg,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}$deliveryCharge',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTranslated(
                                                context, promocodeDiscount)
                                            .toString(),
                                        style: TextStyle(
                                          fontFamily: groldReg,
                                          color: colorBlack,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        discountCouponName,
                                        style: TextStyle(
                                          fontFamily: groldReg,
                                          color: colorRed,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '-${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}$discountPrice',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorRed,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? DottedLine(dashColor: colorDivider)
                            : SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        isRegularOrder
                            ? SizedBox(height: 15)
                            : SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, toPay).toString(),
                              style: TextStyle(
                                fontFamily: groldBold,
                                color: colorBlack,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}$amount',
                              style: TextStyle(
                                fontFamily: groldBold,
                                color: colorBlack,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  _buildTimeline() {
    return Column(
      children: [
        //first
        Container(
          height: 80.0,
          margin: EdgeInsets.only(right: 10),
          child: TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            afterLineStyle: LineStyle(
              color: pickUpAddressStatus == true ? colorButton : colorDivider,
              thickness: 2,
            ),
            beforeLineStyle: LineStyle(
              color: colorButton,
              thickness: 2,
            ),
            indicatorStyle: IndicatorStyle(
              color: colorOrange,
              width: 12.0,
              height: 12.0,
            ),
            isFirst: true,
            endChild: Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      Text(
                        getTranslated(context, pickupAddressText).toString(),
                        style: TextStyle(
                          color: colorBlack,
                          fontWeight: FontWeight.w400,
                          fontFamily: groldReg,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Text(
                          pickUpAddress,
                          style: TextStyle(
                            color: colorDivider,
                            fontFamily: groldReg,
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        //second
        Container(
          height: 80.0,
          margin: EdgeInsets.only(right: 10),
          child: TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            afterLineStyle: showDriver
                ? LineStyle(
                    color: dropOffAddressStatus == true
                        ? colorButton
                        : colorDivider,
                    thickness: 2,
                  )
                : LineStyle(color: Colors.transparent, thickness: 0.0),
            beforeLineStyle: LineStyle(
              color: dropOffAddressStatus == true ? colorButton : colorDivider,
              thickness: 2,
            ),
            indicatorStyle: IndicatorStyle(
              color: dropOffAddressStatus == true ? colorOrange : colorDivider,
              width: 12.0,
              height: 12.0,
            ),
            isFirst: false,
            isLast: showDriver ? false : true,
            endChild: Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      Text(
                        getTranslated(context, dropOffAddressName).toString(),
                        style: TextStyle(
                          color: colorBlack,
                          fontFamily: groldReg,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Text(
                          dropOffAddress,
                          style: TextStyle(
                            color: colorDivider,
                            fontFamily: groldReg,
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        //third
        showDriver
            ? Container(
                height: 80.0,
                margin: EdgeInsets.only(right: 10),
                child: TimelineTile(
                  axis: TimelineAxis.vertical,
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  afterLineStyle: LineStyle(
                    color:
                        deliveredSuccess == true ? colorButton : colorDivider,
                    thickness: 2,
                  ),
                  beforeLineStyle: LineStyle(
                    color:
                        deliveredSuccess == true ? colorButton : colorDivider,
                    thickness: 2,
                  ),
                  indicatorStyle: IndicatorStyle(
                    color:
                        deliveredSuccess == true ? colorButton : colorDivider,
                    indicator: deliveredSuccess == true
                        ? Icon(
                            Icons.check_circle,
                            color: colorGreen,
                            size: 20,
                          )
                        : Icon(
                            Icons.circle,
                            color: colorDivider,
                            size: 15,
                          ),
                  ),
                  isLast: true,
                  endChild: Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 20.0),
                            Text(
                              () {
                                if (orderReject) {
                                  return getTranslated(
                                          context, orderRejectedName)
                                      .toString();
                                } else if (orderCancel) {
                                  return getTranslated(context, orderCancelName)
                                      .toString();
                                } else {
                                  return getTranslated(
                                          context, deliveredSuccessName)
                                      .toString();
                                }
                              }(),
                              style: TextStyle(
                                color: colorBlack,
                                fontFamily: groldBold,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20.0),
                            Text(
                              '${getTranslated(context, order).toString()} on $orderDate',
                              style: TextStyle(
                                color: colorDivider,
                                fontFamily: groldReg,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20.0),
                            Text(
                              'by $driverName',
                              style: TextStyle(
                                color: colorDivider,
                                fontFamily: groldReg,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
      ],
    );
  }

  Future<BaseModel<TrackOrderModel>> trackOrderApi(int id) async {
    TrackOrderModel response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData()).trackOrder(id);
      setState(() {
        _loading = false;
        orderId = response.data!.orderId!;
        pickUpAddress = response.data!.shop!.location!;
        dropOffAddress = response.data!.address!.address!;
        orderStatus = response.data!.orderStatus!;
        var inputFormat = DateFormat('yyyy-MM-dd');
        DateTime date1 = inputFormat.parse(response.data!.date!);
        String tempDate = DateFormat.yMMMMd('en_US').format(date1);
        orderDate = tempDate + ' ' + response.data!.time!;
        if (response.data!.deliveryPersonId! > 0) {
          showDriver = true;
          driverName = response.data!.deliveryperson!.name!;
        }
        orderItems!.addAll(response.data!.orderItems!);
        tax = response.data!.tax;
        deliveryCharge = response.data!.deliveryCharge;
        amount = response.data!.amount;
        if (response.data!.promocodePrice! > 0) {
          discountPrice = response.data!.promocodePrice.toString();
          discountCouponName = response.data!.promocode!.name!;
        }
        if (response.data!.shopDiscountPrice! > 0) {
          discountCouponName = response.data!.shopdiscount!.name!;
          discountPrice = response.data!.shopDiscountPrice.toString();
        }
        if (response.data!.orderStatus! == "Pending" ||
            response.data!.orderStatus! == "Approve") {
          pickUpAddressStatus = false;
          dropOffAddressStatus = false;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Accept" ||
            response.data!.orderStatus! == "Driver PickedUp Item" ||
            response.data!.orderStatus! == "Preparing Item" ||
            response.data!.orderStatus! == "On The Way") {
          pickUpAddressStatus = true;
          dropOffAddressStatus = false;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Reached") {
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Reject" ||
            response.data!.orderStatus! == "Cancel") {
          if (response.data!.orderStatus! == "Reject") {
            orderReject = true;
          }
          if (response.data!.orderStatus! == "Cancel") {
            orderCancel = true;
          }
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = true;
        } else {
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = true;
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SinglePackageOrder>> trackOrderApiForPackage(int id) async {
    SinglePackageOrder response;
    try {
      setState(() {
        _loading = true;
      });
      response =
          await ApiServices(ApiHeader().dioData()).trackOrderForPackage(id);
      setState(() {
        _loading = false;
        orderId = response.data!.packageId!;
        pickUpAddress = response.data!.pickupLocation!;
        dropOffAddress = response.data!.dropupLocation!;
        orderStatus = response.data!.orderStatus!;
        var inputFormat = DateFormat('yyyy-MM-dd');
        DateTime date1 = inputFormat.parse(response.data!.date!);
        String tempDate = DateFormat.yMMMMd('en_US').format(date1);
        orderDate = tempDate + ' ' + response.data!.time!;
        //todo:change this to package
        // orderItems!.addAll(response.data!.orderItems!);
        categoryNameForPackage = response.data!.category!.name!;
        packageWeight = response.data!.weight.toString();
        if (response.data!.deliveryPersonId! > 0) {
          showDriver = true;
          driverName = response.data!.deliveryperson!.name!;
        }
        tax = response.data!.tax;
        amount = response.data!.amount;
        if (response.data!.orderStatus! == "Pending" ||
            response.data!.orderStatus! == "Approve") {
          pickUpAddressStatus = false;
          dropOffAddressStatus = false;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Accept" ||
            response.data!.orderStatus! == "Driver PickedUp Item" ||
            response.data!.orderStatus! == "Preparing Item" ||
            response.data!.orderStatus! == "On The Way") {
          pickUpAddressStatus = true;
          dropOffAddressStatus = false;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Reached") {
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = false;
        } else if (response.data!.orderStatus! == "Reject" ||
            response.data!.orderStatus! == "Cancel") {
          if (response.data!.orderStatus! == "Reject") {
            orderReject = true;
          }
          if (response.data!.orderStatus! == "Cancel") {
            orderCancel = true;
          }
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = true;
        } else {
          pickUpAddressStatus = true;
          dropOffAddressStatus = true;
          deliveredSuccess = true;
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
