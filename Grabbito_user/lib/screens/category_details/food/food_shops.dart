import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grabbito/screens/food_items/food_item.dart';
import 'package:iconly/iconly.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/category_details/food/comp/search_food_widget.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'comp/coupon.dart';
import 'custom_tab_bar.dart';

class FoodDeliveryShop extends StatefulWidget {
  final int singleShopId;
  final int businessTypeId;
  const FoodDeliveryShop({required this.singleShopId, required this.businessTypeId});

  @override
  _FoodDeliveryShopState createState() => _FoodDeliveryShopState();
}

class _FoodDeliveryShopState extends State<FoodDeliveryShop>
    with SingleTickerProviderStateMixin {
  TabController? controllerTab;
  bool isVegOnly = false;
  bool isFirst = true;
  bool _loading = false;
  String bannerImage = '';
  bool veg = false;
  bool nonVeg = false;
  bool both = false;

  ScrollController? _scrollViewController;
  bool _showAppbar = true;
  bool isScrollingDown = false;

  List<Discount> discountList = [];
  List<Menu> menus = [];

  String address = '',
      distance = '',
      forTwoPerson = "",
      restaurantName = "",
      restaurantImage = "",
      image = "",
      restaurantEstimatedTime = "";

  int restaurantId = 0;
  int selectedIndex = 0;
  int initPosition = 0;
  final dbHelper = DatabaseHelper.instance;
  List<bool> listFinalCustomizationCheck = [];
  double tempPrice = 0;
  double totalCartAmount = 0;
  int totalQty = 0;
  List<Product> products = [];
  List<Product> listCart = [];
  Future<BaseModel<SingleShopModel>>? menuFuture;

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _scrollViewController!.addListener(() {
      if (_scrollViewController!.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        }
      }

      if (_scrollViewController!.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        }
      }
    });
    menuFuture = singleShopApiOnlyFood();
    _queryFirst(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          restaurantName.toString(),
          style: TextStyle(
              fontFamily: groldReg,
              fontWeight: FontWeight.w400,
              color: !_showAppbar ? colorBlack : colorWhite,
              fontSize: 20),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 9, bottom: 9, left: 16,right: 16),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorWidgetBorder,
                border: Border.all(width: 1, color: colorWidgetBg)),
            child: IconButton(
              icon: Icon(
                IconlyLight.search,
                color: colorBlack,
                size: 20.0,
              ),
              tooltip: 'search',
              onPressed: () {
                Navigator.pushNamed(context, searchFoodRoute,
                    arguments: SearchFood(
                      singleShopId: widget.singleShopId,
                      shopName: restaurantName,
                      businessTypeId: widget.businessTypeId,
                    ));
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollViewController,
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bannerImage == "https://grabbito.com/public/images/upload/prod_default.png" ? SizedBox(width: 16,height: 0.1,) :
                  Expanded(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        fit: BoxFit.fill,
                        imageUrl: bannerImage,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            SpinKitFadingCircle(color: colorRed),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/images/Merchant.png"),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 28,
                            child: Text(
                              restaurantName.toString(),
                              style: TextStyle(
                                  fontFamily: groldReg,
                                  fontWeight: FontWeight.w400,
                                  color: colorBlack,
                                  fontSize: 20),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                IconlyBold.location,
                                size: 16,
                                color: colorOrange,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                distance == 0
                                    ? "0.1km"
                                    : distance.toString() + "km",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: groldReg,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                IconlyBold.time_circle,
                                size: 16,
                                color: colorPurple,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                restaurantEstimatedTime.toString() + "mins",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: groldReg,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _couponList(),
            ),
            SizedBox(height: 16),
            // Container(
            //   margin: EdgeInsets.only(left: 20, right: 20),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Expanded(
            //         flex: 8,
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               getTranslated(context, menuText).toString(),
            //               style: TextStyle(
            //                 fontFamily: groldBlack,
            //                 color: colorBlack,
            //                 fontSize: 16,
            //               ),
            //             ),
            //             widget.businessTypeId == 2
            //                 ? Text(
            //                     getTranslated(
            //                             context, menuDescTextFood)
            //                         .toString(),
            //                     style: TextStyle(
            //                       fontFamily: groldReg,
            //                       color: colorDivider,
            //                       fontSize: 12,
            //                     ),
            //                   )
            //                 : Text(
            //                     getTranslated(context, menuDescText)
            //                         .toString(),
            //                     style: TextStyle(
            //                       fontFamily: groldReg,
            //                       color: colorDivider,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //           ],
            //         ),
            //       ),
            //       Spacer(),
            //       widget.businessTypeId == 2
            //           ? Expanded(
            //               flex: 2,
            //               child: Column(
            //                 crossAxisAlignment:
            //                     CrossAxisAlignment.center,
            //                 children: [
            //                   Text(
            //                     getTranslated(context, foodTypeText)
            //                         .toString(),
            //                     style: TextStyle(
            //                       fontFamily: groldReg,
            //                       color: colorDivider,
            //                       fontSize: 11,
            //                     ),
            //                   ),
            //                   SizedBox(height: 5),
            //                   FlutterSwitch(
            //                     height: 25,
            //                     width: 45,
            //                     borderRadius: 30,
            //                     padding: 5.5,
            //                     duration: Duration(milliseconds: 400),
            //                     activeColor: colorPink,
            //                     inactiveColor: colorDivider,
            //                     activeToggleColor: colorWhite,
            //                     inactiveToggleColor: colorWhite,
            //                     toggleSize: 15,
            //                     value: isVegOnly,
            //                     onToggle: (value) {
            //                       setState(() {
            //                         isVegOnly = !isVegOnly;
            //                         singleShopApiOnlyFood();
            //                       });
            //                     },
            //                   ),
            //                 ],
            //               ),
            //             )
            //           : SizedBox(
            //               height: 1,
            //               width: 1,
            //             ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<BaseModel<SingleShopModel>>(
                future: menuFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SpinKitFadingCircle(color: colorRed);
                  } else {
                    return menus.isNotEmpty
                        ? CustomTabView(
                            initPosition: initPosition,
                            itemCount: menus.length > 1 ? menus.length : 1,
                            onPositionChange: (index) {
                              initPosition = index!;
                            },
                            tabBuilder: (context, index) => Tab(
                                child: TabContainer(
                                    menus[index].name.toString(), index)),
                            pageBuilder: (context, index) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: subMenus(index),
                                ))
                        : Center(child: Text(noDataDesc));
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .isNotEmpty
            ? true
            : false,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, cartScreenRoute),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              width: SizeConfig.screenWidth,
              decoration: BoxDecoration(
                  color: colorOrange,
                  borderRadius: BorderRadius.circular(50)
              ),
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$totalQty ${getTranslated(context, totalItems).toString()}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: groldReg),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        VerticalDivider(
                          thickness: 1,
                          width: 10,
                          indent: 20,
                          endIndent: 20,
                          color: colorWhite,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} $totalCartAmount',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: groldBold),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, addToBag).toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: groldReg),
                        ),
                        SizedBox(width: 10),
                        Icon(IconlyBold.bag_2,color: Colors.white,size: 20,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<SingleShopModel>> singleShopApiOnlyFood() async {
    SingleShopModel response;
    try {
      setState(() {
        if (!isFirst) {
          _loading = true;
        }
      });

      widget.businessTypeId == 2
          ? isVegOnly == true
              ? response = await ApiServices(ApiHeader().dioData())
                  .singleShopApiOnlyFood(
                      widget.singleShopId,
                      PreferenceUtils.getDouble(
                              PreferenceNames.latOfSetLocation)
                          .toString(),
                      PreferenceUtils.getDouble(
                              PreferenceNames.longOfSetLocation)
                          .toString(),
                      'veg')
              : response =
                  await ApiServices(ApiHeader().dioData()).singleShopApi(
                  widget.singleShopId,
                  PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
                      .toString(),
                  PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
                      .toString(),
                )
          : response = await ApiServices(ApiHeader().dioData()).singleShopApi(
              widget.singleShopId,
              PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
                  .toString(),
              PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
                  .toString(),
            );

      menus.clear();
      if (response.success == true) {
        setState(() {
          if (response.data!.type == "veg") {
            veg = true;
            nonVeg = false;
          }
          if (response.data!.type == "non_veg") {
            veg = false;
            nonVeg = true;
          }
          if (response.data!.type == "both") {
            both = true;
            veg = false;
            nonVeg = false;
          }
          if (response.data!.type == "") {
            veg = false;
            nonVeg = false;
          }
          if (response.data!.discount!.isNotEmpty) {
            discountList.addAll(response.data!.discount!);
          }
          if (response.data!.menu!.isNotEmpty) {
            menus.addAll(response.data!.menu!);
          }
          bannerImage = response.data!.fullBannerImage!;
          restaurantId = response.data!.id!;
          restaurantName = response.data!.name!;
          restaurantImage = response.data!.bannerImage!;
          image = response.data!.image!;
          forTwoPerson = response.data!.forTwoPerson.toString();
          address = response.data!.location!;
          distance = response.data!.distance.toString();
          restaurantEstimatedTime = response.data!.estimatedTime.toString();

          listCart.addAll(
              ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart);
          if (listCart.isNotEmpty) {
            for (int i = 0; i < listCart.length; i++) {
              if (menus.isNotEmpty) {
                for (int j = 0; j < menus.length; j++) {
                  for (int k = 0; k < menus[j].submenu!.length; k++) {
                    bool isRepeatCustomization;
                    int? repeatcustomization =
                        listCart[i].isRepeatCustomization;
                    if (repeatcustomization == 1) {
                      isRepeatCustomization = true;
                    } else {
                      isRepeatCustomization = false;
                    }
                    if (menus[j].submenu![k].id == listCart[i].id) {
                      menus[j].submenu![k].isAdded = true;
                      menus[j].submenu![k].count = listCart[i].qty!;
                      menus[j].submenu![k].isRepeatCustomization =
                          isRepeatCustomization;
                    }
                  }
                }
              }
            }
          }
        });
      }
      setState(() {
        if (!isFirst) {
          _loading = false;
        }
      });
      isFirst = false;
    } catch (error, stacktrace) {
      setState(() {
        if (!isFirst) {
          _loading = false;
        }
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  //all items list
  subMenus(int index) {
    return ScopedModelDescendant<CartModel>(
      builder: (context, child, model) {
        return menus[index].submenu!.isNotEmpty
            ? ListView.separated(
                itemCount: menus[index].submenu!.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => SizedBox(
                      height: 32,
                    ),
                itemBuilder: (BuildContext context, int subMenuIndex) {
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> FoodItems(item: menus[index].submenu![subMenuIndex]))),
                    child: Container(
                      width: SizeConfig.screenWidth,
                      height: menus[index].submenu![subMenuIndex].description ==
                          "-" || menus[index].submenu![subMenuIndex].description ==
                          "" ? 80 : 90,
                      margin: EdgeInsets.only(left: 24, right: 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      widget.businessTypeId == 2
                                          ? CircleAvatar(
                                              backgroundColor: menus[index]
                                                          .submenu![subMenuIndex]
                                                          .type ==
                                                      "veg"
                                                  ? Color(0xff03DD55)
                                                  : Color(0xffFF2200),
                                              radius: 6.0,
                                            )
                                          : SizedBox(
                                              height: 0.1,
                                              width: 0.1,
                                            ),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(left: 16),
                                          child: Text(
                                            menus[index]
                                                .submenu![subMenuIndex]
                                                .name
                                                .toString(),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: colorBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: groldReg),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                menus[index].submenu![subMenuIndex].description ==
                                        "-" || menus[index].submenu![subMenuIndex].description ==
                                    ""
                                    ? SizedBox(
                                  height: 0.1,
                                )
                                    : Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(left: 30),
                                          child: Text(
                                            menus[index]
                                                .submenu![subMenuIndex]
                                                .description
                                                .toString(),
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color(0xff54545A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: groldReg),
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "${menus[index].submenu![subMenuIndex].unit} ${menus[index].submenu![subMenuIndex].units!.name}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xff54545A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: groldReg),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "RS" ' ${menus[index].submenu![subMenuIndex].price}',
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: colorBlack,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: groldReg),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: menus[index]
                                .submenu![subMenuIndex]
                                .fullImage! == "https://grabbito.com/public/images/upload/prod_default.png" ? SizedBox(): Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: CachedNetworkImage(

                                height: 80,
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                                imageUrl: menus[index]
                                    .submenu![subMenuIndex]
                                    .fullImage!,
                                imageBuilder:
                                    (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(
                                        color: colorRed),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                        "assets/images/Merchant.png"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            : Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child :Text(
                    "No Food Available right now at this category",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: groldReg,
                      color: colorBlack,
                    ),
                  )
                ));
      },
    );
  }

  Container TabContainer(String tabname, int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: colorWidgetBorder),
          borderRadius: BorderRadius.circular(50),
          color: Colors.white),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          tabname,
          style: TextStyle(
              fontFamily: groldReg,
              fontWeight: FontWeight.w400,
              color: colorBlack,
              fontSize: 16),
        ),
      ),
    );
  }

  _couponList() => FutureBuilder(
        future: menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SpinKitFadingCircle(color: colorRed);
          } else {
            return discountList.isNotEmpty
                ? SizedBox(
              height: 68,
                  child: ListView.builder(
                      itemCount: discountList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        //Start from Here with discount data in cart page
                        return GestureDetector(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorWidgetBorder, width: 1),
                                color: colorWhite,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 16, right: 10, top: 10, bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconlyBold.discount,
                                        color: colorOrange,
                                        size: 20.0,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        () {
                                          String shopAmount = '';
                                          if (discountList[index].type ==
                                              "amount") {
                                            shopAmount =
                                                '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)}${discountList[index].discount.toString()}';
                                          } else {
                                            shopAmount =
                                                '${discountList[index].discount.toString()}%';
                                          }
                                          return "FLAT " +
                                              shopAmount.toUpperCase() +
                                              " OFF";
                                        }(),
                                        style: TextStyle(
                                            color: Color(0xff54545A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: groldBold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 16, right: 10, bottom: 10),
                                  child: Text(
                                    "USE " +
                                        discountList[index].code.toString()
                                            .toUpperCase() +
                                        " | ABOVE RS" +
                                        discountList[index].minOrderAmount.toString(),
                                    style: TextStyle(
                                        color: colorBlack,
                                        fontSize: 12,
                                        fontFamily: groldReg),
                                  ),
                                )
                              ],
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
                                            MediaQuery.of(context).size.height *
                                                0.21,
                                        child: CouponWidget(
                                          couponData: discountList[index],
                                        )),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                )
                : SizedBox(height: 0,);
          }
        },
      );

  Future<dynamic> openFoodCustomisationBottomSheet(
    CartModel cartModel,
    Submenu item,
    double currentFoodItemPrice,
    double totalCartAmount,
    int totalQty,
    List<Custimization> customization,
  ) {
    double tempPrice = 0;
    List<CustomizationItemModel> _listCustomizationItem = [];
    List<CustomModel> _listFinalCustomization = [];
    List<int> _radioButtonFlagList = [];
    List<String> _listForAPI = [];
    listFinalCustomizationCheck.clear();

    for (int i = 0; i < customization.length; i++) {
      String? myJSON = customization[i].custimization;
      if (customization[i].custimization != null &&
          customization[i].custimization != "") {
        listFinalCustomizationCheck.add(true);
      } else {
        listFinalCustomizationCheck.add(false);
      }
      if (customization[i].custimization != null &&
          customization[i].custimization != "") {
        var json = jsonDecode(myJSON!);

        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }

        _listFinalCustomization
            .add(CustomModel(customization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          if (_listFinalCustomization[i].list[k].isDefault == 1) {
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
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(customization[i].name, _listCustomizationItem));
        continue;
      }
    }

    return showModalBottomSheet(
        isDismissible: true,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, bottomSheetSetState) {
                return SafeArea(
                  child: Scaffold(
                    body: SizedBox(
                      height: SizeConfig.screenHeight,
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(15),
                                child: Text(
                                  getTranslated(context, customizationAndMore)
                                      .toString(),
                                  style: TextStyle(
                                      fontFamily: groldXBold,
                                      color: colorBlack,
                                      fontSize: 18),
                                ),
                              ),
                              ListView.separated(
                                physics: ClampingScrollPhysics(),
                                itemCount: customization.length,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) => SizedBox(
                                  height: 20,
                                ),
                                itemBuilder: (context, outerIndex) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 20, bottom: 10.0),
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
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list
                                                          .length,
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
                                                                      _listFinalCustomization[
                                                                              i]
                                                                          .list
                                                                          .length;
                                                                  j++) {
                                                                if (_listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .isSelected!) {
                                                                  tempPrice += double.parse(
                                                                      _listFinalCustomization[
                                                                              i]
                                                                          .list[
                                                                              j]
                                                                          .price!);

                                                                  print(_listFinalCustomization[
                                                                          i]
                                                                      .title);
                                                                  print(
                                                                      _listFinalCustomization[
                                                                              i]
                                                                          .list[
                                                                              j]
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
                                                              style: TextStyle(
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
                                              : Center(
                                                  child: Column(
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
                                                  ),
                                                )
                                          : Center(
                                              child: Column(
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
                    bottomNavigationBar: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        print(
                            '===================Continue with List Data=================');
                        print(_listForAPI.toString());
                        addCustomizationFoodDataToDB(
                            _listForAPI.toString(),
                            item,
                            cartModel,
                            currentFoodItemPrice + tempPrice,
                            currentFoodItemPrice,
                            false,
                            0,
                            0);
                      },
                      child: Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${totalQty + 1} ${getTranslated(context, totalItems).toString()}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: groldBold),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      VerticalDivider(
                                        thickness: 2,
                                        width: 2,
                                        color: colorWhite,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${currentFoodItemPrice + tempPrice}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: groldBold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, addItemText)
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: groldReg,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.add,
                                  color: colorWhite,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ));
  }

  showDialogRemoveCart(String? restName, String? currentRestName) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 0, top: 10),
              child: SizedBox(
                height: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, labelRemoveCartItem)
                              .toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 70,
                          child: RichText(
                            text: TextSpan(
                              text:
                                  '${getTranslated(context, labelYourCartContainsDishesFrom).toString()} ',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorBlack,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '$restName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '. ${getTranslated(context, labelYourCartContains1).toString()} ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorBlack,
                                  ),
                                ),
                                TextSpan(
                                  text: '$currentRestName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorBlack,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  getTranslated(context, labelNoGoBack)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colorDividerDark),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .clearCart();
                                    _deleteTable();
                                    setState(() {
                                      totalQty = 0;
                                      totalCartAmount = 0;
                                    });
                                  },
                                  child: Text(
                                    getTranslated(context, labelYesRemoveIt)
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //db
  void _insert(
    int? proId,
    int? proQty,
    String proPrice,
    String currentPriceWithoutCustomization,
    String? proImage,
    String? proType,
    String? proName,
    int? restId,
    String? restName,
    String? restImage,
    String customization,
    int isRepeatCustomization,
    int isCustomization,
    int itemQty,
    double tempPrice,
    String restAddress,
    String restKm,
    String restEstimateTime,
  ) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProType: proType,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnRestImage: restImage,
      //address add
      DatabaseHelper.columnRestAddress: restAddress,
      DatabaseHelper.columnRestKm: restKm,
      DatabaseHelper.columnRestEstimateTime: restEstimateTime,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItemTempPrice: tempPrice,
      DatabaseHelper.columnCurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    _query();
    setState(() {});
  }

  void _queryFirst(BuildContext context) async {
    CartModel model = CartModel();

    double tempTotal1 = 0, tempTotal2 = 0;
    listCart.clear();
    totalCartAmount = 0;
    totalQty = 0;
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    for (int i = 0; i < allRows.length; i++) {
      listCart.add(Product(
        id: allRows[i]['pro_id'],
        restaurantsName: allRows[i]['restName'],
        title: allRows[i]['pro_name'],
        imgUrl: allRows[i]['pro_image'],
        type: allRows[i]['pro_type'],
        price: double.parse(allRows[i]['pro_price']),
        qty: allRows[i]['pro_qty'],
        restaurantsId: allRows[i]['restId'],
        restaurantImage: allRows[i]['restImage'],
        foodCustomization: allRows[i]['pro_customization'],
        isRepeatCustomization: allRows[i]['isRepeatCustomization'],
        tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
        itemQty: allRows[i]['itemQty'],
        isCustomization: allRows[i]['isCustomization'],
        restaurantAddress: allRows[i]['restAddress'],
        restaurantKm: allRows[i]['restKm'],
        restaurantEstimatedTime: allRows[i]['restEstimateTime'],
      ));

      model.addProduct(Product(
        id: allRows[i]['pro_id'],
        restaurantsName: allRows[i]['restName'],
        title: allRows[i]['pro_name'],
        imgUrl: allRows[i]['pro_image'],
        type: allRows[i]['pro_type'],
        price: double.parse(allRows[i]['pro_price']),
        qty: allRows[i]['pro_qty'],
        restaurantsId: allRows[i]['restId'],
        restaurantImage: allRows[i]['restImage'],
        foodCustomization: allRows[i]['pro_customization'],
        isRepeatCustomization: allRows[i]['isRepeatCustomization'],
        restaurantAddress: allRows[i]['restAddress'],
        restaurantKm: allRows[i]['restKm'],
        restaurantEstimatedTime: allRows[i]['restEstimateTime'],
      ));
      if (allRows[i]['pro_customization'] == '') {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        tempTotal1 +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) + totalCartAmount;
        tempTotal2 += double.parse(allRows[i]['pro_price']);
      }

      print(totalCartAmount);

      print('First cart model cart data' +
          ScopedModel.of<CartModel>(context, rebuildOnChange: true)
              .cart
              .toString());
      print('First cart Listcart array' + listCart.length.toString());
      print('First cart listcart string' + listCart.toString());

      totalQty += allRows[i]['pro_qty'] as int;
      print(totalQty);
    }

    print('TempTotal1 $tempTotal1');
    print('TempTotal2 $tempTotal2');
    totalCartAmount = tempTotal1 + tempTotal2;
  }

  void _query() async {
    double tempTotal1 = 0, tempTotal2 = 0;
    listCart.clear();
    totalCartAmount = 0;
    totalQty = 0;
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    for (int i = 0; i < allRows.length; i++) {
      listCart.add(Product(
        id: allRows[i]['pro_id'],
        restaurantsName: allRows[i]['restName'],
        title: allRows[i]['pro_name'],
        imgUrl: allRows[i]['pro_image'],
        type: allRows[i]['pro_type'],
        price: double.parse(allRows[i]['pro_price']),
        qty: allRows[i]['pro_qty'],
        restaurantsId: allRows[i]['restId'],
        restaurantImage: allRows[i]['restImage'],
        foodCustomization: allRows[i]['pro_customization'],
        isCustomization: allRows[i]['isCustomization'],
        isRepeatCustomization: allRows[i]['isRepeatCustomization'],
        itemQty: allRows[i]['itemQty'],
        restaurantAddress: allRows[i]['restAddress'],
        restaurantKm: allRows[i]['restKm'],
        restaurantEstimatedTime: allRows[i]['restEstimateTime'],
        tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      ));
      if (allRows[i]['pro_customization'] == '') {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        tempTotal1 +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) + totalCartAmount;
        tempTotal2 += double.parse(allRows[i]['pro_price']);
      }

      print(totalCartAmount);

      totalQty += allRows[i]['pro_qty'] as int;
      print(totalQty);
    }

    print('TempTotal1 $tempTotal1');
    print('TempTotal2 $tempTotal2');
    totalCartAmount = tempTotal1 + tempTotal2;
    setState(() {});
  }

  void _updateForCustomizedFood(
      int? proId,
      int? proQty,
      String proPrice,
      String? currentPriceWithoutCustomization,
      String? proImage,
      String? proName,
      int? restId,
      String? restName,
      String? customization,
      // Function onSetState,
      int isRepeatCustomization,
      int isCustomization) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isRepeatCustomization,
      DatabaseHelper.columnCurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    _query();
    setState(() {});
  }

  void _update(
      int? proId,
      int? proQty,
      String proPrice,
      String? proImage,
      String? proName,
      int? restId,
      String? restName,
      int isRepeatCustomization,
      int isCustomization,
      int itemQty,
      String customizationTempPrice) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnIsRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnIsCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItemTempPrice: customizationTempPrice,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    _query();
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  void addCustomizationFoodDataToDB(
      String customization,
      Submenu item,
      CartModel model,
      double cartPrice,
      double currentPriceWithoutCustomization,
      bool isFromAddRepeatCustomization,
      int iRepeat,
      int itemQty) {
    int isRepeat = iRepeat;

    if (ScopedModel.of<CartModel>(context, rebuildOnChange: true)
        .cart
        .isEmpty) {
      setState(() {
        if (!isFromAddRepeatCustomization) {
          item.isAdded = !item.isAdded!;
        }
        item.count++;
      });
      products.add(Product(
        id: item.id,
        qty: item.count,
        price: cartPrice,
        imgUrl: item.image,
        title: item.name,
        type: item.type,
        restaurantsId: restaurantId,
        restaurantsName: restaurantName,
        restaurantImage: restaurantImage,
        restaurantAddress: address,
        restaurantKm: distance,
        restaurantEstimatedTime: restaurantEstimatedTime,
        foodCustomization: customization,
        isCustomization: 1,
        isRepeatCustomization: isRepeat,
        itemQty: itemQty,
        tempPrice: cartPrice,
      ));
      model.addProduct(Product(
        id: item.id,
        qty: item.count,
        price: cartPrice,
        imgUrl: item.image,
        type: item.type,
        title: item.name,
        restaurantsId: restaurantId,
        restaurantsName: restaurantName,
        restaurantImage: restaurantImage,
        foodCustomization: customization,
        isCustomization: 1,
        isRepeatCustomization: isRepeat,
        tempPrice: cartPrice,
        itemQty: item.itemQty,
        restaurantAddress: address,
        restaurantKm: distance,
        restaurantEstimatedTime: restaurantEstimatedTime,
      ));
      _insert(
          item.id,
          item.count,
          cartPrice.toString(),
          currentPriceWithoutCustomization.toString(),
          item.image,
          item.type,
          item.name,
          restaurantId,
          restaurantName,
          restaurantImage,
          customization,
          isRepeat,
          1,
          item.itemQty,
          cartPrice,
          address,
          distance,
          restaurantEstimatedTime);
    } else {
      print(restaurantId);
      print(ScopedModel.of<CartModel>(context, rebuildOnChange: true)
          .getRestId());
      if (restaurantId !=
          ScopedModel.of<CartModel>(context, rebuildOnChange: true)
              .getRestId()) {
        showDialogRemoveCart(
            ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .getRestName(),
            restaurantName);
      } else {
        setState(() {
          if (!isFromAddRepeatCustomization) {
            item.isAdded = !item.isAdded!;
          }
          item.count++;
        });
        products.add(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          type: item.type,
          title: item.name,
          restaurantsId: restaurantId,
          restaurantsName: restaurantName,
          restaurantImage: restaurantImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          tempPrice: cartPrice,
          itemQty: itemQty,
          restaurantAddress: address,
          restaurantKm: distance,
          restaurantEstimatedTime: restaurantEstimatedTime,
        ));
        model.addProduct(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          type: item.type,
          title: item.name,
          restaurantsId: restaurantId,
          restaurantsName: restaurantName,
          restaurantImage: restaurantImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          tempPrice: cartPrice,
          itemQty: itemQty,
          restaurantAddress: address,
          restaurantKm: distance,
          restaurantEstimatedTime: restaurantEstimatedTime,
        ));
        _insert(
          item.id,
          item.count,
          cartPrice.toString(),
          currentPriceWithoutCustomization.toString(),
          item.image,
          item.type,
          item.name,
          restaurantId,
          restaurantName,
          restaurantImage,
          customization,
          isRepeat,
          1,
          item.itemQty,
          cartPrice,
          address,
          distance,
          restaurantEstimatedTime,
        );
      }
    }
    setState(() {});
  }

  void updateCustomizationFoodDataToDB(
      String? customization, Submenu item, CartModel model, double cartPrice) {
    setState(() {
      item.count++;
    });
    model.updateProduct(item.id, item.count);
    print("Cart List" +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .toString() +
        "");
    int isRepeatCustomization = item.isRepeatCustomization! ? 1 : 0;
    _updateForCustomizedFood(
        item.id,
        item.count,
        cartPrice.toString(),
        item.price.toString(),
        item.image,
        item.name,
        restaurantId,
        restaurantName,
        customization,
        isRepeatCustomization,
        1);
    setState(() {});
  }

  Widget getChecked() {
    return Container(
      height: 25,
      width: 25,
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
      height:25,
      width: 25,
      decoration: myBoxDecorationChecked(colorUnCheckItem),
    );
  }

  BoxDecoration myBoxDecorationChecked(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String? title;

  CustomModel(this.title, this.list);
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
        isDefault = json['default'],
        status = json['status'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'status': status,
        'isDefault': isDefault,
      };
}
