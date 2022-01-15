import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/auth/login_screen.dart';
import 'package:grabbito/screens/home/home_screen.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/transition.dart';
import 'payment_method_screen.dart';
import 'select_address_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final dbHelper = DatabaseHelper.instance;
  TextEditingController noteController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  bool _loading = false;
  bool promoCodeApplied = false;
  bool promoCodeAppliedFromSingleShop = false;
  bool promoCodeSingleVendor = true;
  bool promoCodeTextSuccess = false;
  bool isCartEmpty = true;
  List<Submenu> cartMenuItem = [];
  List<Product> products = [];
  List<Menu> listRestaurantsMenu = [];
  List<bool> listFinalCustomizationCheck = [];
  List<Discount> discountList = [];
  double finalTotalPrice = 0,
      finalSubTotal = 0,
      finalTax = 0,
      finalDeliveryCharge = 0,
      finalPromoCodeAmount = 0,
      shopLat = 0,
      shopLong = 0;
  int itemLength = 0;
  int finalPromoCodeId = 0;
  int? restId;
  String? restName = '',
      restImage = '',
      restAddress = '',
      restDistance = '',
      restEstimatedTime = '',
      couponDiscountAmountFromRes = '',
      minDiscountAmountFromRes = '',
      typeDiscountFromRes = '',
      tempTaxInPercent = '';
  @override
  void initState() {
    super.initState();
    _queryNew();
  }

  void _queryNew() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    products.clear();
    finalTotalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    setState(() {
      if (allRows.isNotEmpty) {
        isCartEmpty = false;
        for (int i = 0; i < allRows.length; i++) {
          products.add(Product(
            id: allRows[i]['pro_id'],
            restaurantsName: allRows[i]['restName'],
            title: allRows[i]['pro_name'],
            imgUrl: allRows[i]['pro_image'],
            type: allRows[i]['pro_type'],
            price: double.parse(allRows[i]['pro_price']),
            qty: allRows[i]['pro_qty'],
            restaurantsId: allRows[i]['restId'],
            restaurantImage: allRows[i]['restImage'],
            restaurantAddress: allRows[i]['restAddress'],
            restaurantKm: allRows[i]['restKm'],
            restaurantEstimatedTime: allRows[i]['restEstimateTime'],
            foodCustomization: allRows[i]['pro_customization'],
            isCustomization: allRows[i]['isCustomization'],
            isRepeatCustomization: allRows[i]['isRepeatCustomization'],
            itemQty: allRows[i]['itemQty'],
            tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
          ));
          restName = allRows[i]['restName'];
          restImage = allRows[i]['restImage'];
          restAddress = allRows[i]['restAddress'];
          restDistance = allRows[i]['restKm'];
          restEstimatedTime = allRows[i]['restEstimateTime'];
          restId = allRows[i]['restId'];
          finalTotalPrice +=
              double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          print(finalTotalPrice);
          print(restId);
          print(allRows[i]['pro_id']);
          if (allRows[i]['pro_customization'] == '') {
            finalTotalPrice +=
                double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
            tempTotal1 +=
                double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          } else {
            finalTotalPrice +=
                double.parse(allRows[i]['pro_price']) + finalTotalPrice;
            tempTotal2 += double.parse(allRows[i]['pro_price']);
          }
          print(finalTotalPrice);
        }
        callGetRestaurantsDetails(
          restId,
          products,
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
              .toString(),
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
              .toString(),
        );
      } else {
        finalTotalPrice = 0;
      }

      print('TempTotal1 $tempTotal1');
      print('TempTotal2 $tempTotal2');
      finalTotalPrice = tempTotal1 + tempTotal2;
      finalSubTotal = finalTotalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        orientation: Orientation.portrait);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorWhite,
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, color: Colors.black),
            onPressed: () => Navigator.pushReplacement(
              context,
              Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: HomeScreen(0),
              ),
            ),
          ),
          title: Text(
            getTranslated(context, cartPageTitle).toString(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
                fontFamily: groldReg, color: colorBlack, fontSize: 18),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          opacity: 1.0,
          color: Colors.transparent,
          progressIndicator: SpinKitFadingCircle(color: colorRed),
          child: ListView(
            children: [
              //for address
              Visibility(
                visible: !isCartEmpty,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: colorOrange,
                                size: 25,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 5),
                                width: SizeConfig.screenWidth! / 1.8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      PreferenceUtils.getString(PreferenceNames
                                          .locationTypeOfSetLocation),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: groldBold,
                                      ),
                                    ),
                                    Text(
                                      PreferenceUtils.getString(
                                          PreferenceNames.addressOfSetLocation),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: groldReg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  if (PreferenceUtils.getBool(
                                          PreferenceNames.checkLogin) ==
                                      true) {
                                    Navigator.push(
                                      context,
                                      Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: SelectAddressScreen(),
                                      ),
                                    );
                                    setState(() {});
                                  } else {
                                    Navigator.push(
                                      context,
                                      Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: LoginScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  getTranslated(context, locationChange)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontFamily: groldReg),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !isCartEmpty,
                child: Container(
                  width: SizeConfig.screenWidth,
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CachedNetworkImage(
                                  alignment: Alignment.center,
                                  height: ScreenUtil().setHeight(60),
                                  width: ScreenUtil().setWidth(60),
                                  fit: BoxFit.fill,
                                  imageUrl: restImage.toString(),
                                  placeholder: (context, url) =>
                                      SpinKitFadingCircle(color: colorRed),
                                  errorWidget: (context, url, error) =>
                                      Image.asset("assets/images/no_image.png"),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restName.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Grold XBold',
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      restAddress.toString(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Grold Bold'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10.0),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
                                      child: Row(
                                        children: [
                                          Text(
                                            '$restDistance ${getTranslated(context, kmDistanceText).toString()}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontFamily: 'Grold Bold'),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            radius: 3.0,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '$restEstimatedTime ${getTranslated(context, minutesText).toString()}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontFamily: 'Grold Bold'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      //all cart show
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: ListView.separated(
                            itemCount: cartMenuItem.length,
                            separatorBuilder: (context, index) => DottedLine(),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, cartItemIndex) {
                              return ScopedModelDescendant<CartModel>(
                                  builder: (context, child, model) {
                                return Container(
                                  width: SizeConfig.screenWidth,
                                  margin: EdgeInsets.only(top: 10, bottom: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                SizeConfig.screenWidth! / 1.6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    cartMenuItem.isNotEmpty
                                                        ? Visibility(
                                                            visible: cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "veg" ||
                                                                cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "non_veg" ||
                                                                cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "both",
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  cartMenuItem[cartItemIndex]
                                                                              .type ==
                                                                          "veg"
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                              radius: 8.0,
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height: 1,
                                                            width: 1),
                                                    cartMenuItem.isNotEmpty
                                                        ? Visibility(
                                                            visible: cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "veg" ||
                                                                cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "non_veg" ||
                                                                cartMenuItem[
                                                                            cartItemIndex]
                                                                        .type ==
                                                                    "both",
                                                            child: SizedBox(
                                                                width: 10))
                                                        : SizedBox(
                                                            height: 1,
                                                            width: 1),
                                                    cartMenuItem.isNotEmpty
                                                        ? SizedBox(
                                                            width: ScreenUtil()
                                                                .setWidth(200),
                                                            child: Text(
                                                              cartMenuItem[
                                                                      cartItemIndex]
                                                                  .name
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    groldBold,
                                                                color:
                                                                    colorBlack,
                                                                fontSize: 16,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height: 1,
                                                            width: 1),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                cartMenuItem.isNotEmpty &&
                                                        cartMenuItem[
                                                                cartItemIndex]
                                                            .custimization!
                                                            .isNotEmpty
                                                    ? SizedBox(
                                                        width: ScreenUtil()
                                                            .setWidth(200),
                                                        child: Text(
                                                          () {
                                                            var tempDataForCustomize;
                                                            for (int z = 0;
                                                                z <
                                                                    model.cart
                                                                        .length;
                                                                z++) {
                                                              if (cartMenuItem[
                                                                          cartItemIndex]
                                                                      .id ==
                                                                  model.cart[z]
                                                                      .id) {
                                                                tempDataForCustomize =
                                                                    json.decode(model
                                                                        .cart[z]
                                                                        .foodCustomization!);
                                                              }
                                                            }
                                                            if (tempDataForCustomize
                                                                .isNotEmpty) {
                                                              print(
                                                                  tempDataForCustomize);
                                                              String allMenus =
                                                                  "";
                                                              String _temp = "";
                                                              for (int i = 0;
                                                                  i <
                                                                      tempDataForCustomize!
                                                                          .length;
                                                                  i++) {
                                                                _temp = tempDataForCustomize[
                                                                        i][
                                                                    'main_menu'];
                                                                allMenus = allMenus +
                                                                    _temp +
                                                                    ' (' +
                                                                    tempDataForCustomize[i]
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'name'] +
                                                                    ')' +
                                                                    ', ';
                                                              }
                                                              String showMenus =
                                                                  allMenus.substring(
                                                                      0,
                                                                      allMenus.length -
                                                                          2);
                                                              return showMenus +
                                                                  ".";
                                                            } else {
                                                              return "";
                                                            }
                                                          }(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                groldReg,
                                                            color: colorDivider,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 1,
                                                        width: 1,
                                                      ),
                                                SizedBox(height: 5),
                                                cartMenuItem.isNotEmpty
                                                    ? Text(
                                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${cartMenuItem[cartItemIndex].price}',
                                                        style: TextStyle(
                                                          fontFamily: groldReg,
                                                          color: colorBlack,
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 1,
                                                        width: 1,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            height: ScreenUtil().setHeight(40),
                                            width: ScreenUtil().setWidth(80),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    Colors.grey.withAlpha(30)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                //decrement
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setHeight(25),
                                                  width:
                                                      ScreenUtil().setWidth(27),
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    iconSize: ScreenUtil()
                                                        .setHeight(20),
                                                    onPressed: () {
                                                      decrementFunction(
                                                          cartItemIndex, model);
                                                    },
                                                    icon: Icon(
                                                      Icons.remove,
                                                      color: colorButton,
                                                    ),
                                                  ),
                                                ),
                                                //show count
                                                cartMenuItem.isNotEmpty
                                                    ? Container(
                                                        width: ScreenUtil()
                                                            .setWidth(23),
                                                        // height: 40,
                                                        color: colorWhite,
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            cartMenuItem[
                                                                    cartItemIndex]
                                                                .count
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  groldReg,
                                                              color: colorBlack,
                                                              fontSize: 16.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 1,
                                                        width: 1,
                                                      ),
                                                //increment
                                                SizedBox(
                                                  height: ScreenUtil()
                                                      .setHeight(25),
                                                  width:
                                                      ScreenUtil().setWidth(27),
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    iconSize: ScreenUtil()
                                                        .setHeight(20),
                                                    onPressed: () {
                                                      incrementFunction(
                                                          cartItemIndex, model);
                                                    },
                                                    icon: Icon(
                                                      Icons.add,
                                                      color: colorButton,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      //customizable list
                                      cartMenuItem.isNotEmpty &&
                                              cartMenuItem[cartItemIndex]
                                                  .custimization!
                                                  .isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                var ab;
                                                String? finalFoodCustomization,
                                                    currentPriceWithoutCustomization;
                                                for (int q = 0;
                                                    q <
                                                        listRestaurantsMenu
                                                            .length;
                                                    q++) {
                                                  for (int w = 0;
                                                      w <
                                                          listRestaurantsMenu[q]
                                                              .submenu!
                                                              .length;
                                                      w++) {
                                                    if (cartMenuItem[
                                                                cartItemIndex]
                                                            .id ==
                                                        listRestaurantsMenu[q]
                                                            .submenu![w]
                                                            .id) {
                                                      currentPriceWithoutCustomization =
                                                          listRestaurantsMenu[q]
                                                              .submenu![w]
                                                              .price
                                                              .toString();
                                                    }
                                                  }
                                                }
                                                print(
                                                    currentPriceWithoutCustomization);
                                                for (int z = 0;
                                                    z < model.cart.length;
                                                    z++) {
                                                  if (cartMenuItem[
                                                              cartItemIndex]
                                                          .id ==
                                                      model.cart[z].id) {
                                                    ab = json.decode(model
                                                        .cart[z]
                                                        .foodCustomization!);
                                                    finalFoodCustomization =
                                                        model.cart[z]
                                                            .foodCustomization;
                                                  }
                                                }
                                                List<String?>
                                                    nameOfcustomization = [];
                                                for (int i = 0;
                                                    i < ab.length;
                                                    i++) {
                                                  nameOfcustomization.add(
                                                      ab[i]['data']['name']);
                                                }
                                                cartMenuItem[cartItemIndex]
                                                        .isRepeatCustomization =
                                                    true;
                                                openFoodCustomizationBottomSheet(
                                                  model,
                                                  cartMenuItem[cartItemIndex],
                                                  double.parse(cartMenuItem[
                                                          cartItemIndex]
                                                      .price
                                                      .toString()),
                                                  double.parse(
                                                      currentPriceWithoutCustomization!),
                                                  finalTotalPrice,
                                                  cartMenuItem[cartItemIndex]
                                                      .custimization!,
                                                  finalFoodCustomization!,
                                                  cartItemIndex,
                                                );
                                              },
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      getTranslated(context,
                                                              customizeOrderText)
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: colorBlue,
                                                        fontFamily:
                                                            'Grold Regular',
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      size: 15,
                                                      color: colorBlue,
                                                    )
                                                  ],
                                                ),
                                                margin: EdgeInsets.only(
                                                    top: ScreenUtil()
                                                        .setHeight(5)),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      //note for delivery guid
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(right: 0, left: 0, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(width: 0.5, color: colorButton)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, noteForDeliveryGuyText)
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 14),
                              ),
                              TextField(
                                style: TextStyle(
                                    fontFamily: groldReg, fontSize: 16),
                                controller: noteController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: getTranslated(
                                          context, noteForDeliveryGuyText2)
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //promocode
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(right: 0, left: 0, top: 20),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5, color: colorButton)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getTranslated(context, promocodeText)
                                          .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Grold Regular',
                                          fontSize: 14),
                                    ),
                                    TextField(
                                      controller: codeController,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          fontFamily: 'Grold Regular',
                                          fontSize: 16),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: getTranslated(
                                            context, promocodeHintText),
                                        suffix: codeController.text.isNotEmpty
                                            ? Visibility(
                                                visible: !promoCodeApplied,
                                                child: TextButton(
                                                    onPressed: () {
                                                      if (codeController.text
                                                          .trim()
                                                          .isNotEmpty) {
                                                        DateTime now =
                                                            DateTime.now();
                                                        DateTime date =
                                                            DateTime(
                                                                now.year,
                                                                now.month,
                                                                now.day);
                                                        print(date
                                                            .toString()
                                                            .split(" ")[0]);
                                                        checkOffer(
                                                            codeController.text,
                                                            date
                                                                .toString()
                                                                .split(" ")[0],
                                                            finalSubTotal
                                                                .toString());
                                                      }
                                                    },
                                                    child: Text(
                                                      getTranslated(context,
                                                              applyPromoText)
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: colorBlue,
                                                          fontFamily:
                                                              groldXBold),
                                                    )),
                                              )
                                            : TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      Transitions(
                                                        transitionType:
                                                            TransitionType
                                                                .slideUp,
                                                        curve:
                                                            Curves.bounceInOut,
                                                        reverseCurve: Curves
                                                            .fastLinearToSlowEaseIn,
                                                        widget: HomeScreen(2),
                                                      ));
                                                },
                                                child: Text(
                                                  getTranslated(context,
                                                          goToCouponSectionText)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: colorBlue,
                                                      fontFamily: groldXBold),
                                                )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: promoCodeTextSuccess,
                                child: Text(
                                  getTranslated(
                                          context, couponApplySuccessfully)
                                      .toString(),
                                  style: TextStyle(color: colorGreen),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Visibility(
                                visible: promoCodeSingleVendor,
                                child: Text(
                                  getTranslated(context, orSelectAnyoneFromIt)
                                      .toString(),
                                  style: TextStyle(color: colorBlack),
                                ),
                              ),
                              Visibility(
                                visible: promoCodeSingleVendor,
                                child: SizedBox(
                                  height: ScreenUtil().setHeight(85),
                                  child: _couponList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      //price details
                      Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              //show items
                              ListView.separated(
                                itemCount: cartMenuItem.length,
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
                                          cartMenuItem[cartItemIndex]
                                              .name
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
                                          'x ${cartMenuItem[cartItemIndex].count}',
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
                                      '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${cartMenuItem[cartItemIndex].price}',
                                      style: TextStyle(
                                        fontFamily: groldBold,
                                        color: colorBlack,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              DottedLine(
                                dashColor: colorDivider,
                              ),
                              SizedBox(height: 15),
                              Row(
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
                                    '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalSubTotal.ceil().toString()}',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              DottedLine(
                                dashColor: colorDivider,
                              ),
                              SizedBox(height: 15),
                              Row(
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
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalTax.ceil().toString()}',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
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
                                    '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalDeliveryCharge.ceil()}',
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Visibility(
                                visible: promoCodeApplied,
                                child: Row(
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
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              promoCodeApplied = false;
                                              promoCodeSingleVendor = true;
                                              promoCodeTextSuccess = false;
                                              finalTotalPrice +=
                                                  finalPromoCodeAmount;
                                              codeController.clear();
                                            });
                                          },
                                          child: Text(
                                            getTranslated(context, removeCoupon)
                                                .toString(),
                                            style: TextStyle(
                                              fontFamily: groldReg,
                                              color: colorRed,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '-${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalPromoCodeAmount.ceil()}',
                                      style: TextStyle(
                                        fontFamily: groldBold,
                                        color: colorRed,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: promoCodeApplied,
                                child: SizedBox(height: 15),
                              ),
                              DottedLine(
                                dashColor: colorDivider,
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, toPay).toString(),
                                    style: TextStyle(
                                      fontFamily: groldBold,
                                      color: colorBlack,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalTotalPrice.ceil().toString()}",
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
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              //empty cart
              Visibility(
                visible: isCartEmpty,
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
              ),
            ],
          ),
        ),
        bottomNavigationBar: Visibility(
          visible: !isCartEmpty,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
              child: Container(
                height: 60,
                width: SizeConfig.screenWidth,
                decoration: BoxDecoration(
                  color: colorPurple,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: SizeConfig.screenWidth! / 2,
                      color: Colors.white30,
                      padding: EdgeInsets.only(left: 20),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, totalPay).toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: groldReg),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${finalTotalPrice.ceil().toString()}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: groldBold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        getTranslated(context, proceedToPay).toString(),
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: groldReg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == true) {
                if (PreferenceUtils.getInt(PreferenceNames.idOfSetLocation) >
                    0) {
                  List<Map<String, dynamic>> item = [];
                  //for item array
                  final allRows = await dbHelper.queryAllRows();
                  itemLength = allRows.length;
                  print('query all rows:');
                  for (var row in allRows) {
                    print(row);
                  }
                  if (allRows.isNotEmpty) {
                    // String? customization;
                    for (int i = 0; i < allRows.length; i++) {
                      if (allRows[i]['pro_customization'] == '') {
                        print('procustom calling');
                        var addToItem;
                        addToItem = double.parse(allRows[i]['pro_price']) *
                            allRows[i]['pro_qty'];
                        item.add({
                          'id': allRows[i]['pro_id'],
                          'price': addToItem,
                          'qty': allRows[i]['pro_qty'],
                        });
                      } else {
                        print('customise calling');
                        String addToItem;
                        dynamic calculation;
                        calculation =
                            allRows[i]['itemTempPrice'] * allRows[i]['pro_qty'];
                        addToItem = calculation.toString();
                        print('final addToItem is $addToItem');
                        item.add({
                          'id': allRows[i]['pro_id'],
                          'price': addToItem,
                          'qty': allRows[i]['pro_qty'],
                          'custimization':
                              json.decode(allRows[i]['pro_customization'])
                        });
                      }
                    }
                  }
                  DateTime now = DateTime.now();
                  DateTime date = DateTime(now.year, now.month, now.day);
                  print(date.toString().split(" ")[0]);
                  String todayDate = date.toString().split(" ")[0];
                  String bookTime =
                      DateFormat('hh:mm a').format(DateTime.now());
                  Map<String, dynamic> paymentDataBody;
                  if (promoCodeApplied == true) {
                    if (promoCodeAppliedFromSingleShop == true) {
                      paymentDataBody = {
                        "tax": finalTax.ceil(),
                        "amount": finalTotalPrice.ceil(),
                        "delivery_charge": finalDeliveryCharge,
                        "item": json.encode(item).toString(),
                        "shop_id": restId,
                        "shop_discount_id": finalPromoCodeId,
                        "shop_discount_price": finalPromoCodeAmount.ceil(),
                        "location_id": PreferenceUtils.getInt(
                            PreferenceNames.idOfSetLocation),
                        "date": todayDate,
                        "time": bookTime,
                      };
                    } else {
                      paymentDataBody = {
                        "tax": finalTax.ceil(),
                        "amount": finalTotalPrice.ceil(),
                        "delivery_charge": finalDeliveryCharge.ceil(),
                        "item": json.encode(item).toString(),
                        "shop_id": restId,
                        "promocode_id": finalPromoCodeId,
                        "promocode_price": finalPromoCodeAmount.ceil(),
                        "location_id": PreferenceUtils.getInt(
                            PreferenceNames.idOfSetLocation),
                        "date": todayDate,
                        "time": bookTime,
                      };
                    }
                  } else {
                    paymentDataBody = {
                      "tax": finalTax.ceil(),
                      "amount": finalTotalPrice.ceil(),
                      "delivery_charge": finalDeliveryCharge.ceil(),
                      "item": json.encode(item).toString(),
                      "shop_id": restId,
                      "location_id": PreferenceUtils.getInt(
                          PreferenceNames.idOfSetLocation),
                      "date": todayDate,
                      "time": bookTime,
                    };
                  }
                  Navigator.push(
                    context,
                    Transitions(
                      transitionType: TransitionType.slideUp,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: PaymentMethodScreen(
                        fromWhere: "fromFoodAndGrocery",
                        paymentData: paymentDataBody,
                      ),
                    ),
                  );
                } else {
                  CommonFunction.toastMessage("select address please!");
                }
              } else {
                Navigator.push(
                    context,
                    Transitions(
                      transitionType: TransitionType.slideUp,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: LoginScreen(),
                    ));
              }
            },
          ),
        ),
      ),
    );
  }

  void decrementFunction(int cartItemIndex, CartModel model) async {
    final allRows = await dbHelper.queryAllRows();
    if (cartMenuItem[cartItemIndex].count > 1) {
      cartMenuItem[cartItemIndex].count--;
      model.updateProduct(
          cartMenuItem[cartItemIndex].id, cartMenuItem[cartItemIndex].count);
      String? customization, currentPriceWithoutCustomization;
      for (int z = 0; z < model.cart.length; z++) {
        if (cartMenuItem[cartItemIndex].id == model.cart[z].id) {
          customization = model.cart[z].foodCustomization;
        }
      }
      for (int q = 0; q < listRestaurantsMenu.length; q++) {
        for (int w = 0; w < listRestaurantsMenu[q].submenu!.length; w++) {
          if (cartMenuItem[cartItemIndex].id ==
              listRestaurantsMenu[q].submenu![w].id) {
            currentPriceWithoutCustomization =
                listRestaurantsMenu[q].submenu![w].price.toString();
          }
        }
      }
      if (cartMenuItem[cartItemIndex].custimization!.isNotEmpty) {
        int isRepeatCustomization =
            cartMenuItem[cartItemIndex].isRepeatCustomization! ? 1 : 0;
        await _updateForCustomizedFood(
            cartMenuItem[cartItemIndex].id,
            cartMenuItem[cartItemIndex].count,
            double.parse(cartMenuItem[cartItemIndex].price.toString()),
            currentPriceWithoutCustomization,
            cartMenuItem[cartItemIndex].image,
            cartMenuItem[cartItemIndex].type,
            cartMenuItem[cartItemIndex].name,
            restId,
            restName,
            customization,
            isRepeatCustomization,
            1,
            "decrement");
      } else {
        await _update(
            cartMenuItem[cartItemIndex].id,
            cartMenuItem[cartItemIndex].count,
            cartMenuItem[cartItemIndex].price.toString(),
            cartMenuItem[cartItemIndex].image,
            cartMenuItem[cartItemIndex].name,
            restId,
            restName,
            "decrement");
      }
    } else {
      print(allRows.length);
      cartMenuItem[cartItemIndex].isAdded = false;
      cartMenuItem[cartItemIndex].count = 0;
      if (cartMenuItem[cartItemIndex].count == 0) {
        isCartEmpty = true;
      }
      model.updateProduct(
          cartMenuItem[cartItemIndex].id, cartMenuItem[cartItemIndex].count);
      String? customization, currentPriceWithoutCustomization;
      for (int z = 0; z < model.cart.length; z++) {
        if (cartMenuItem[cartItemIndex].id == model.cart[z].id) {
          customization = model.cart[z].foodCustomization;
        }
      }

      for (int q = 0; q < listRestaurantsMenu.length; q++) {
        for (int w = 0; w < listRestaurantsMenu[q].submenu!.length; w++) {
          if (cartMenuItem[cartItemIndex].id ==
              listRestaurantsMenu[q].submenu![w].id) {
            currentPriceWithoutCustomization =
                listRestaurantsMenu[q].submenu![w].price.toString();
          }
        }
      }
      print(currentPriceWithoutCustomization);
      if (cartMenuItem[cartItemIndex].custimization!.isNotEmpty) {
        int isRepeatCustomization =
            cartMenuItem[cartItemIndex].isRepeatCustomization! ? 1 : 0;
        await _updateForCustomizedFood(
            cartMenuItem[cartItemIndex].id,
            cartMenuItem[cartItemIndex].count,
            double.parse(cartMenuItem[cartItemIndex].price.toString()),
            currentPriceWithoutCustomization,
            cartMenuItem[cartItemIndex].image,
            cartMenuItem[cartItemIndex].type,
            cartMenuItem[cartItemIndex].name,
            restId,
            restName,
            customization,
            isRepeatCustomization,
            1,
            "decrement");
      } else {
        await _update(
            cartMenuItem[cartItemIndex].id,
            cartMenuItem[cartItemIndex].count,
            cartMenuItem[cartItemIndex].price.toString(),
            cartMenuItem[cartItemIndex].image,
            cartMenuItem[cartItemIndex].name,
            restId,
            restName,
            "decrement");
      }
    }
    _query();
  }

  Future<void> incrementFunction(int cartItemIndex, CartModel model) async {
    cartMenuItem[cartItemIndex].count++;
    model.updateProduct(
        cartMenuItem[cartItemIndex].id, cartMenuItem[cartItemIndex].count);
    if (cartMenuItem[cartItemIndex].custimization!.isNotEmpty) {
      int isRepeatCustomization =
          cartMenuItem[cartItemIndex].isRepeatCustomization! ? 1 : 0;
      String? customization, currentPriceWithoutCustomization;
      for (int z = 0; z < model.cart.length; z++) {
        if (cartMenuItem[cartItemIndex].id == model.cart[z].id) {
          customization = model.cart[z].foodCustomization;
        }
      }
      for (int q = 0; q < listRestaurantsMenu.length; q++) {
        for (int w = 0; w < listRestaurantsMenu[q].submenu!.length; w++) {
          if (cartMenuItem[cartItemIndex].id ==
              listRestaurantsMenu[q].submenu![w].id) {
            currentPriceWithoutCustomization =
                listRestaurantsMenu[q].submenu![w].price.toString();
          }
        }
      }
      print(currentPriceWithoutCustomization);
      await _updateForCustomizedFood(
          cartMenuItem[cartItemIndex].id,
          cartMenuItem[cartItemIndex].count,
          double.parse(cartMenuItem[cartItemIndex].price.toString()),
          currentPriceWithoutCustomization,
          cartMenuItem[cartItemIndex].image,
          cartMenuItem[cartItemIndex].type,
          cartMenuItem[cartItemIndex].name,
          restId,
          restName,
          customization,
          isRepeatCustomization,
          1,
          "increment");
    } else {
      await _update(
          cartMenuItem[cartItemIndex].id,
          cartMenuItem[cartItemIndex].count,
          cartMenuItem[cartItemIndex].price.toString(),
          cartMenuItem[cartItemIndex].image,
          cartMenuItem[cartItemIndex].name,
          restId,
          restName,
          "increment");
    }
    _query();
  }

  _couponList() => discountList.isNotEmpty
      ? ListView.builder(
          itemCount: discountList.length,
          padding: EdgeInsets.all(10),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            //Start from Here with discount data in cart page
            return GestureDetector(
              child: Container(
                margin: EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    color: Color(0xFFABDCFF).withAlpha(20),
                    borderRadius: BorderRadius.circular(15)),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(15),
                  padding: EdgeInsets.all(10),
                  color: Color(0xFF0396FF),
                  strokeWidth: 3,
                  dashPattern: const [8, 6],
                  child: Column(
                    children: [
                      Text(
                        () {
                          String shopAmount = '';
                          if (discountList[index].type == "amount") {
                            shopAmount =
                                '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].discount.toString()} ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].minOrderAmount.toString()}';
                          } else {
                            shopAmount =
                                '${discountList[index].discount.toString()}% ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].minOrderAmount.toString()}';
                          }
                          return shopAmount;
                        }(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: colorBlack,
                            fontSize: 16,
                            fontFamily: groldBold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${getTranslated(context, useCodeText).toString()} ${discountList[index].code.toString()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: colorBlack,
                            fontSize: 14,
                            fontFamily: groldReg),
                      )
                    ],
                  ),
                ),
              ),
              onTap: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              onPressed: () {},
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.21,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: SizeConfig.screenWidth,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.13,
                                        margin: EdgeInsets.all(0),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: Radius.circular(10),
                                          padding: EdgeInsets.all(20),
                                          color: colorBlack,
                                          strokeWidth: 3,
                                          dashPattern: const [8, 6],
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                () {
                                                  String shopAmount = '';
                                                  if (discountList[index]
                                                          .type ==
                                                      "amount") {
                                                    shopAmount =
                                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].discount.toString()} ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].minOrderAmount.toString()}';
                                                  } else {
                                                    shopAmount =
                                                        '${discountList[index].discount.toString()}% ${getTranslated(context, offUptoText).toString()} ${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].minOrderAmount.toString()}';
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
                                                '${getTranslated(context, useCodeText).toString()} ${discountList[index].code.toString()}',
                                                style: TextStyle(
                                                    color: colorBlack,
                                                    fontSize: 18,
                                                    fontFamily: groldReg),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      TextButton(
                                        onPressed: () {
                                          checkShopDiscount(
                                            discountList[index],
                                            finalSubTotal.toString(),
                                          );
                                        },
                                        child: Text(
                                          getTranslated(
                                                  context, applyThisCoupon)
                                              .toString(),
                                          style: TextStyle(
                                              color: colorBlue,
                                              fontSize: 16,
                                              fontFamily: groldBold),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ));
              },
            );
          })
      : Center(
          child: Text(
            getTranslated(context, noCouponDesc).toString(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Grold XBold',
            ),
          ),
        );

  Future<BaseModel<SingleShopModel>> callGetRestaurantsDetails(
      int? restaurantId, List<Product> _listCart, lat, lang) async {
    SingleShopModel response;
    try {
      setState(() {
        _loading = true;
      });

      response = await ApiServices(ApiHeader().dioData())
          .singleShopApi(restaurantId, lat, lang);
      print(response.success);
      if (response.success!) {
        listRestaurantsMenu.addAll(response.data!.menu!);
        discountList.addAll(response.data!.discount!);
        shopLat = double.parse(response.data!.lat.toString());
        shopLong = double.parse(response.data!.lang.toString());
        tempTaxInPercent = response.data!.tax!.toString();
        _query();
        cartMenuItem.clear();
        if (_listCart.isNotEmpty) {
          for (int i = 0; i < _listCart.length; i++) {
            if (listRestaurantsMenu.isNotEmpty) {
              for (int j = 0; j < listRestaurantsMenu.length; j++) {
                for (int k = 0;
                    k < listRestaurantsMenu[j].submenu!.length;
                    k++) {
                  if (listRestaurantsMenu[j].submenu![k].id ==
                      _listCart[i].id) {
                    if (_listCart[i].foodCustomization == '') {
                      cartMenuItem.add(Submenu(
                          price: _listCart[i].price!.toString(),
                          id: _listCart[i].id,
                          name: _listCart[i].title,
                          image: _listCart[i].imgUrl,
                          type: _listCart[i].type,
                          count: _listCart[i].qty!,
                          custimization: [],
                          isRepeatCustomization:
                              _listCart[i].isRepeatCustomization == 0
                                  ? false
                                  : true,
                          isAdded: true));
                    } else {
                      cartMenuItem.add(Submenu(
                          price: _listCart[i].tempPrice!.toString(),
                          id: _listCart[i].id,
                          name: _listCart[i].title,
                          image: _listCart[i].imgUrl,
                          type: _listCart[i].type,
                          count: _listCart[i].qty!,
                          custimization:
                              listRestaurantsMenu[j].submenu![k].custimization,
                          isRepeatCustomization:
                              _listCart[i].isRepeatCustomization == 0
                                  ? false
                                  : true,
                          isAdded: true));
                    }
                  }
                }
              }
            }
          }
        }
        if (cartMenuItem.isNotEmpty) {
          isCartEmpty = false;
        }
      }
      setState(() {
        _loading = false;
      });
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<String>> checkOffer(
      String code, String date, String amount) async {
    String response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData())
          .checkOffer(code, date, amount);

      final responseBody = json.decode(response);
      bool? success = responseBody['success'];

      if (success == true) {
        couponDiscountAmountFromRes =
            responseBody['data']['discount'].toString();
        minDiscountAmountFromRes =
            responseBody['data']['min_discount_amount'].toString();
        typeDiscountFromRes = responseBody['data']['type'].toString();
        if (typeDiscountFromRes == "amount") {
          if (double.parse(couponDiscountAmountFromRes.toString()) >
              double.parse(minDiscountAmountFromRes.toString())) {
            finalPromoCodeAmount =
                double.parse(minDiscountAmountFromRes.toString());
          } else {
            finalPromoCodeAmount =
                double.parse(couponDiscountAmountFromRes.toString());
          }
        } else {
          double tempAmount = double.parse(amount.toString()) *
              double.parse(couponDiscountAmountFromRes.toString()) /
              100;
          if (tempAmount > double.parse(minDiscountAmountFromRes.toString())) {
            finalPromoCodeAmount =
                double.parse(minDiscountAmountFromRes.toString());
          } else {
            finalPromoCodeAmount = tempAmount;
          }
        }
        setState(() {
          finalTotalPrice -= finalPromoCodeAmount;
          finalPromoCodeId = responseBody['data']['id'];
          promoCodeApplied = true;
          promoCodeAppliedFromSingleShop = false;
          promoCodeTextSuccess = true;
          promoCodeSingleVendor = false;
        });
      } else {
        CommonFunction.toastMessage(responseBody['msg'].toString());
      }
      setState(() {
        _loading = false;
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

  checkShopDiscount(Discount discountObject, String amount) async {
    try {
      //single shop coupon calculation
      DateTime now = DateTime.now();
      DateTime startDate = DateTime.parse(discountObject.startDate.toString());
      DateTime endDate = DateTime.parse(discountObject.endDate.toString());
      print(startDate.isBefore(now));
      print(endDate.isAfter(now));
      if (startDate.isBefore(now) && endDate.isAfter(now)) {
        couponDiscountAmountFromRes = discountObject.discount.toString();
        minDiscountAmountFromRes = discountObject.minDiscountAmount.toString();
        typeDiscountFromRes = discountObject.type.toString();
        if (typeDiscountFromRes == "amount") {
          if (double.parse(couponDiscountAmountFromRes.toString()) >
              double.parse(minDiscountAmountFromRes.toString())) {
            finalPromoCodeAmount =
                double.parse(minDiscountAmountFromRes.toString());
          } else {
            finalPromoCodeAmount =
                double.parse(couponDiscountAmountFromRes.toString());
          }
        } else {
          double tempAmount = double.parse(amount.toString()) *
              double.parse(couponDiscountAmountFromRes.toString()) /
              100;
          if (tempAmount > double.parse(minDiscountAmountFromRes.toString())) {
            finalPromoCodeAmount =
                double.parse(minDiscountAmountFromRes.toString());
          } else {
            finalPromoCodeAmount = tempAmount;
          }
        }
        setState(() {
          finalTotalPrice -= finalPromoCodeAmount;
          finalPromoCodeId = discountObject.id!.toInt();
          promoCodeApplied = true;
          promoCodeAppliedFromSingleShop = true;
          promoCodeTextSuccess = true;
          promoCodeSingleVendor = false;
          codeController.text = discountObject.code.toString();
        });
      } else {
        CommonFunction.toastMessage("Promo Code Is Not Available");
      }
      Navigator.pop(context);
    } catch (error) {
      CommonFunction.toastMessage('something went wrong');
    }
  }

  void openFoodCustomizationBottomSheet(
      CartModel cartModel,
      Submenu item,
      double currentFoodItemPrice,
      double currentPriceWithoutCustomization,
      double totalCartAmount,
      List<Custimization> custimization,
      String previousFoodCustomization,
      int cartItemIndex) {
    print(currentFoodItemPrice);
    print(item.price);

    double tempPrice = 0;
    List<String> _listForAPI = [];
    var previous = jsonDecode(previousFoodCustomization);
    List<PreviousCustomizationItemModel> _listPreviousCustomization = [];
    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    listFinalCustomizationCheck.clear();

    _listPreviousCustomization = (previous as List)
        .map((i) => PreviousCustomizationItemModel.fromJson(i))
        .toList();

    int previousPrice = 0;
    List<String?> previousItemName = [];
    for (int i = 0; i < _listPreviousCustomization.length; i++) {
      previousPrice +=
          int.parse(_listPreviousCustomization[i].datamodel!.price!);
      previousItemName.add(_listPreviousCustomization[i].datamodel!.name);
      if (custimization[i].custimization != null &&
          custimization[i].custimization != "") {
        listFinalCustomizationCheck.add(true);
      } else {
        listFinalCustomizationCheck.add(false);
      }
    }
    print(previousPrice);

    double singleFinal = currentFoodItemPrice - previousPrice;

    for (int i = 0; i < custimization.length; i++) {
      String? myJSON = custimization[i].custimization;
      if (custimization[i].custimization != null &&
          custimization[i].custimization != "") {
        var json = jsonDecode(myJSON!);

        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          for (int z = 0; z < previousItemName.length; z++) {
            if (_listFinalCustomization[i].list[k].isSelected != true) {
              if (_listFinalCustomization[i].list[k].name ==
                  previousItemName[z]) {
                _listFinalCustomization[i].list[k].isSelected = true;
                _radioButtonFlagList.add(k);
                tempPrice +=
                    double.parse(_listFinalCustomization[i].list[k].price!);
                _listForAPI.add(
                    '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
              } else {
                _listFinalCustomization[i].list[k].isSelected = false;
              }
            }
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));
        continue;
      }
    }
    print(_listForAPI.toString());
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              child: StatefulBuilder(
                builder: (context, bottomSheetSetState) {
                  return SafeArea(
                    child: Scaffold(
                      body: SizedBox(
                        height: SizeConfig.screenHeight,
                        child: ListView(
                          physics: ClampingScrollPhysics(),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(20),
                                  child: Text(
                                    getTranslated(context, customizationAndMore)
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: groldXBold,
                                        color: colorBlack,
                                        fontSize: 18),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  itemCount: custimization.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, outerIndex) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(20),
                                          child: Text(
                                            _listFinalCustomization[outerIndex]
                                                .title
                                                .toString(),
                                            style: TextStyle(
                                                fontFamily: groldXBold,
                                                color: colorBlack,
                                                fontSize: 18),
                                          ),
                                        ),
                                        _listFinalCustomization[outerIndex]
                                                .list
                                                .isNotEmpty
                                            ? listFinalCustomizationCheck[
                                                        outerIndex] ==
                                                    true
                                                ? ListView.separated(
                                                    itemCount:
                                                        _listFinalCustomization[
                                                                outerIndex]
                                                            .list
                                                            .length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    separatorBuilder: (context,
                                                            index) =>
                                                        SizedBox(height: 10.0),
                                                    itemBuilder:
                                                        (context, innerIndex) {
                                                      return InkWell(
                                                        onTap: () {
                                                          if (!_listFinalCustomization[
                                                                  outerIndex]
                                                              .list[innerIndex]
                                                              .isSelected!) {
                                                            tempPrice = 0;
                                                            _listForAPI.clear();
                                                            bottomSheetSetState(
                                                                () {
                                                              _radioButtonFlagList[
                                                                      outerIndex] =
                                                                  innerIndex;
                                                              for (var element
                                                                  in _listFinalCustomization[
                                                                          outerIndex]
                                                                      .list) {
                                                                element.isSelected =
                                                                    false;
                                                              }
                                                              _listFinalCustomization[
                                                                      outerIndex]
                                                                  .list[
                                                                      innerIndex]
                                                                  .isSelected = true;
                                                              for (int i = 0;
                                                                  i <
                                                                      _listFinalCustomization
                                                                          .length;
                                                                  i++) {
                                                                for (int j = 0;
                                                                    j <
                                                                        _listFinalCustomization[i]
                                                                            .list
                                                                            .length;
                                                                    j++) {
                                                                  if (_listFinalCustomization[
                                                                          i]
                                                                      .list[j]
                                                                      .isSelected!) {
                                                                    tempPrice += double.parse(_listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .price!);
                                                                    print(_listFinalCustomization[
                                                                            i]
                                                                        .title);
                                                                    print(_listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .name);
                                                                    print(_listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .isDefault);
                                                                    print(_listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .isSelected);
                                                                    print(_listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .price);
                                                                    _listForAPI.add(
                                                                        '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                                    print(_listForAPI
                                                                        .toString());
                                                                  }
                                                                }
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  _radioButtonFlagList[
                                                                              outerIndex] ==
                                                                          innerIndex
                                                                      ? getChecked()
                                                                      : getUnChecked(),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    _listFinalCustomization[
                                                                            outerIndex]
                                                                        .list[
                                                                            innerIndex]
                                                                        .name
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          groldReg,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${_listFinalCustomization[outerIndex].list[innerIndex].price.toString()}',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      groldBold,
                                                                  color:
                                                                      colorBlack,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          "assets/images/no_image.png"),
                                                      Text(
                                                        getTranslated(context,
                                                                noDataDesc)
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: groldReg,
                                                          color: colorBlack,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                      "assets/images/no_image.png"),
                                                  Text(
                                                    getTranslated(
                                                            context, noDataDesc)
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: groldReg,
                                                      color: colorBlack,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      bottomNavigationBar: Container(
                        height: 60,
                        width: SizeConfig.screenWidth,
                        color: colorGreen,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: SizeConfig.screenWidth! / 1.7,
                              child: Text(
                                '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${singleFinal + tempPrice}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: groldBold),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                print(
                                    '===================Continue with List Data=================');
                                print(_listForAPI.toString());
                                double price = singleFinal + tempPrice;
                                cartModel.cart[cartItemIndex]
                                    .foodCustomization = _listForAPI.toString();
                                int isRepeatCustomization =
                                    item.isRepeatCustomization! ? 1 : 0;
                                await _updateForCustomizedFood(
                                    item.id,
                                    item.count,
                                    price,
                                    currentPriceWithoutCustomization.toString(),
                                    item.image,
                                    item.type,
                                    item.name,
                                    restId,
                                    restName,
                                    _listForAPI.toString(),
                                    isRepeatCustomization,
                                    1,
                                    "bottomSheet");
                                _query();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, continueText)
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontFamily: groldReg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ));
  }

  void _query() async {
    print("count query");
    double tempTotal1 = 0, tempTotal2 = 0;
    cartMenuItem.clear();
    products.clear();
    finalTotalPrice = 0;

    final allRows = await dbHelper.queryAllRows();
    itemLength = allRows.length;
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    if (allRows.isNotEmpty) {
      for (int i = 0; i < allRows.length; i++) {
        products.add(Product(
          id: allRows[i]['pro_id'],
          restaurantsName: allRows[i]['restName'],
          title: allRows[i]['pro_name'],
          imgUrl: allRows[i]['pro_image'],
          type: allRows[i]['pro_type'],
          price: double.parse(allRows[i]['pro_price']),
          qty: allRows[i]['pro_qty'],
          restaurantsId: allRows[i]['restId'],
          restaurantImage: allRows[i]['restImage'],
          restaurantAddress: allRows[i]['restAddress'],
          restaurantKm: allRows[i]['restKm'],
          restaurantEstimatedTime: allRows[i]['restEstimateTime'],
          foodCustomization: allRows[i]['pro_customization'],
          isCustomization: allRows[i]['isCustomization'],
          isRepeatCustomization: allRows[i]['isRepeatCustomization'],
          itemQty: allRows[i]['itemQty'],
          tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
        ));

        restName = allRows[i]['restName'];
        restImage = allRows[i]['restImage'];
        restId = allRows[i]['restId'];
        finalTotalPrice +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        print(finalTotalPrice);
        print(restId);
        print(allRows[i]['pro_id']);

        if (allRows[i]['pro_customization'] == '') {
          finalTotalPrice +=
              double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
          tempTotal1 +=
              double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        } else {
          finalTotalPrice +=
              double.parse(allRows[i]['pro_price']) + finalTotalPrice;
          tempTotal2 += double.parse(allRows[i]['pro_price']);
        }

        print(finalTotalPrice);
      }

      if (products.isNotEmpty) {
        for (int i = 0; i < products.length; i++) {
          if (listRestaurantsMenu.isNotEmpty) {
            for (int j = 0; j < listRestaurantsMenu.length; j++) {
              for (int k = 0; k < listRestaurantsMenu[j].submenu!.length; k++) {
                if (listRestaurantsMenu[j].submenu![k].id == products[i].id) {
                  if (products[i].foodCustomization == '') {
                    cartMenuItem.add(Submenu(
                        price: products[i].price!.toString(),
                        id: products[i].id,
                        name: products[i].title,
                        image: products[i].imgUrl,
                        type: products[i].type,
                        count: products[i].qty!,
                        custimization: [],
                        isRepeatCustomization:
                            products[i].isRepeatCustomization == 0
                                ? false
                                : true,
                        isAdded: true));
                  } else {
                    cartMenuItem.add(Submenu(
                        price: products[i].tempPrice!.toString(),
                        id: products[i].id,
                        name: products[i].title,
                        image: products[i].imgUrl,
                        type: products[i].type,
                        count: products[i].qty!,
                        custimization:
                            listRestaurantsMenu[j].submenu![k].custimization,
                        isRepeatCustomization:
                            products[i].isRepeatCustomization == 0
                                ? false
                                : true,
                        isAdded: true));
                  }
                }
              }
            }
          }
        }
      }
    } else {
      finalTotalPrice = 0;
    }

    print('TempTotal1 $tempTotal1');
    print('TempTotal2 $tempTotal2');
    finalTotalPrice = tempTotal1 + tempTotal2;
    finalSubTotal = finalTotalPrice;
    finalTax = finalSubTotal * double.parse(tempTaxInPercent!) / 100;
    finalTotalPrice += finalTax;

    ///distance wise set amount
    if (PreferenceUtils.getString(
            PreferenceNames.deliveryChargeBasedOnSetting) ==
        "distance") {
      List<ChargesModel> decodeAmount = [];
      String localAmountArray =
          PreferenceUtils.getString(PreferenceNames.deliveryChargeSetting);
      var deliveryCharge = json.decode(localAmountArray);
      decodeAmount = (deliveryCharge as List)
          .map((i) => ChargesModel.fromJson(i))
          .toList();

      double userLat = 0, userLong = 0;
      userLat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation);
      userLong = PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation);

      double totalDistance =
          calculateDistance(userLat, userLong, shopLat, shopLong);

      String strFinalDeliveryCharge1 = '';
      for (int i = 0; i < decodeAmount.length; i++) {
        if (totalDistance >= double.parse(decodeAmount[i].minValue!) &&
            totalDistance <= double.parse(decodeAmount[i].maxValue!)) {
          strFinalDeliveryCharge1 = decodeAmount[i].charges!;
          break;
        }
      }
      if (strFinalDeliveryCharge1 == '') {
        var max = decodeAmount.reduce((current, next) =>
            int.parse(current.charges!) > int.parse(next.charges!)
                ? current
                : next);
        finalDeliveryCharge = double.parse(max.charges!.toString());
      } else if (totalDistance < 1) {
        finalDeliveryCharge = 0.0;
      } else {
        finalDeliveryCharge = double.parse(strFinalDeliveryCharge1);
      }
    }

    ///amount wise set amount
    else {
      List<ChargesModel> decodeAmount = [];
      String localAmountArray =
          PreferenceUtils.getString(PreferenceNames.amountSetting);
      var deliveryCharge = json.decode(localAmountArray);
      decodeAmount = (deliveryCharge as List)
          .map((i) => ChargesModel.fromJson(i))
          .toList();

      double tempAmount = finalSubTotal;

      String strFinalDeliveryCharge1 = '';
      for (int i = 0; i < decodeAmount.length; i++) {
        if (tempAmount >= double.parse(decodeAmount[i].minValue!) &&
            tempAmount <= double.parse(decodeAmount[i].maxValue!)) {
          strFinalDeliveryCharge1 = decodeAmount[i].charges!;
          break;
        }
      }
      if (strFinalDeliveryCharge1 == '') {
        var max = decodeAmount.reduce((current, next) =>
            int.parse(current.charges!) > int.parse(next.charges!)
                ? current
                : next);
        finalDeliveryCharge = double.parse(max.charges!.toString());
      } else if (tempAmount < 1) {
        finalDeliveryCharge = 0.0;
      } else {
        finalDeliveryCharge = double.parse(strFinalDeliveryCharge1);
      }
    }

    print("final delivery charge is $finalDeliveryCharge");
    finalTotalPrice += finalDeliveryCharge;

    if (promoCodeApplied == true) {
      if (typeDiscountFromRes == "amount") {
        if (double.parse(couponDiscountAmountFromRes.toString()) >
            double.parse(minDiscountAmountFromRes.toString())) {
          finalPromoCodeAmount =
              double.parse(minDiscountAmountFromRes.toString());
        } else {
          finalPromoCodeAmount =
              double.parse(couponDiscountAmountFromRes.toString());
        }
      } else {
        double tempAmount = finalSubTotal *
            double.parse(couponDiscountAmountFromRes.toString()) /
            100;
        if (tempAmount > double.parse(minDiscountAmountFromRes.toString())) {
          finalPromoCodeAmount =
              double.parse(minDiscountAmountFromRes.toString());
        } else {
          finalPromoCodeAmount = tempAmount;
        }
      }
      finalTotalPrice -= finalPromoCodeAmount;
    }
    setState(() {});
  }

  Future _updateForCustomizedFood(
    int? proId,
    int proQty,
    double proPrice,
    String? currentPriceWithoutCustomization,
    String? proImage,
    String? proType,
    String? proName,
    int? restId,
    String? restName,
    String? customization,
    int isRepeatCustomization,
    int isCustomization,
    String fromWhere,
  ) async {
    double price = proPrice * proQty;
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProType: proType,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: price.toString(),
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnRestAddress: restAddress,
      DatabaseHelper.columnRestKm: restDistance,
      DatabaseHelper.columnRestEstimateTime: restEstimatedTime,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemTempPrice: proPrice,
      DatabaseHelper.columnCurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    // _query();
  }

  Future _update(int? proId, int? proQty, String proPrice, String? proImage,
      String? proName, int? restId, String? restName, String fromWhere) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  Widget getChecked() {
    return Container(
      height: ScreenUtil().setHeight(25),
      width: ScreenUtil().setWidth(25),
      child: Icon(
        Icons.check,
        size: 20,
        color: Colors.white,
      ),
      decoration: myBoxDecorationChecked(colorGreen),
    );
  }

  Widget getUnChecked() {
    return Container(
      height: ScreenUtil().setHeight(25),
      width: ScreenUtil().setWidth(25),
      decoration: myBoxDecorationChecked(colorUnCheckItem),
    );
  }

  BoxDecoration myBoxDecorationChecked(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<bool> _onWillPop() async {
    return (await Navigator.pushReplacement(
          context,
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: HomeScreen(0),
          ),
        )) ??
        false;
  }
}

class PreviousCustomizationItemModel {
  String? name;
  DataModel? datamodel;

  PreviousCustomizationItemModel(
    this.name,
    this.datamodel,
  );

  PreviousCustomizationItemModel.fromJson(Map<String, dynamic> json) {
    name = json['main_menu'];
    datamodel = DataModel.fromJson(json['data']);
  }

  Map<String, dynamic>? toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_menu'] = name;
    data['data'] = datamodel;
  }
}

class DataModel {
  String? name;
  String? price;

  DataModel({this.name, this.price});

  DataModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class CustomizationItemModel {
  final String name;
  String? price;
  int? isDefault;
  final int? status;
  bool? isSelected;

  CustomizationItemModel(this.name, this.price, this.isDefault, this.status);

  CustomizationItemModel.fromJson(Map<String, dynamic> json)
      : name = json['name'].toString(),
        price = json['price'],
        isDefault = json['isDefault'],
        status = json['status'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'status': status,
        'isDefault': isDefault,
      };
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String? title;

  CustomModel(this.title, this.list);
}

class ChargesModel {
  String? minValue;
  String? maxValue;
  String? charges;

  ChargesModel({this.minValue, this.maxValue, this.charges});

  factory ChargesModel.fromJson(Map<String, dynamic> parsedJson) {
    return ChargesModel(
        minValue: parsedJson['min_value'],
        maxValue: parsedJson['max_value'],
        charges: parsedJson['charge']);
  }
}
