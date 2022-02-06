import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/screens/search/search_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/homepage/banner_model.dart';
import 'package:grabbito/model/homepage/business_types_model.dart';
import 'package:grabbito/model/homepage/offers_at_fruit_veg_model.dart';
import 'package:grabbito/model/homepage/offers_at_grocery_model.dart';
import 'package:grabbito/model/homepage/offers_at_restaurant_model.dart';
import 'package:grabbito/model/setting_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/auth/login_screen.dart';
import 'package:grabbito/screens/cart/cart_screen.dart';
import 'package:grabbito/screens/common/widget_no_internet.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';
import 'package:scoped_model/scoped_model.dart';

class MainPage extends StatefulWidget {
  final bool isTrackOrderPadding;

  const MainPage({required this.isTrackOrderPadding});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {


  final dbHelper = DatabaseHelper.instance;
  bool isCartSymbolAvailable = false;
  int cartSymbolAvailableItems = 0;
  int businessTypeIdForRestaurant = 2;
  int businessTypeIdForGrocery = 3;
  int businessTypeIdForFruitVegetables = 4;
  double aspect = 0.00;
  double aspect1 = 0.00;
  String selectedLocation = "Select Location";
  late Position currentLocation;
  late LatLng _center;
  bool isLocationSet = false;
  bool isNetworkAvailable = true;
  ScrollController? _scrollController;
  bool isScrolledToTop = true;
  static const double EMPTY_SPACE = 10.0;

  bool isVegOnly = false;
  bool isFirst = true;
  String bannerImage = '';
  bool veg = false;
  bool nonVeg = false;
  bool both = false;

  double tempPrice = 0;
  double totalCartAmount = 0;
  int totalQty = 0;

  List<Product> listCart = [];

  List<BusinessTypesData> businessTypes = [];
  List<OffersAtRestaurantData> offersAtRestaurant = [];

  List<BannerData> banners = [];
  List<OffersAtGroceryData> offersAtGrocery = [];
  List<OffersAtFruitData> offersAtFruit = [];

  //for Future data
  Future<BaseModel<BannerModel>>? bannerDataFuture;
  Future<BaseModel<BusinessTypesModel>>? businessTypeFuture;
  Future<BaseModel<OffersAtRestaurantModel>>? offersAtRestaurantFuture;
  Future<BaseModel<OffersAtGroceryModel>>? offersAtGroceryFuture;
  Future<BaseModel<OffersAtFruitsModel>>? offersAtFruitsFuture;

  @override
  void initState() {
    super.initState();
    initializeController();
    bannerDataFuture = bannerApi();
    businessTypeFuture = businessTypesApi();
    singleShopApiOnlyFood();
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);
    _queryFirst(context);
  }

  _scrollListener() {
    if (_scrollController!.offset <= _scrollController!.position.minScrollExtent &&
        !_scrollController!.position.outOfRange) {
      //call setState only when values are about to change
      if(!isScrolledToTop) {
        setState(() {
          //reach the top
          isScrolledToTop = true;
        });
      }

    }else{
      //call setState only when values are about to change
      if(_scrollController!.offset > EMPTY_SPACE && isScrolledToTop) {
        setState(() {
          //not the top
          isScrolledToTop = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  void initializeController() {
    getUserLocation();
    if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == true) {
      if (PreferenceUtils.getBool(PreferenceNames.storeWithoutLogin) == true) {
        addAddress();
      }
    }
    CommonFunction.checkNetwork().then((value) => isNetworkAvailable = value);
    if (PreferenceUtils.getString(PreferenceNames.addressOfSetLocation)
            .isNotEmpty &&
        PreferenceUtils.getString(PreferenceNames.addressOfSetLocation) !=
            'N/A') {
      selectedLocation =
          PreferenceUtils.getString(PreferenceNames.addressOfSetLocation);
      isLocationSet = true;
    }
    bannerApi();
    businessTypesApi();
    settingData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    aspect1 = 0.00;
    aspect = 0.00;
    for (var i = 0; i < 20; i++) {
      aspect = aspect + 0.05;
      aspect1 = MediaQuery.of(context).size.width /
          (MediaQuery.of(context).size.height / aspect);
      if (aspect1 > 0.33) break;
    }
    SizeConfig().init(context);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        orientation: Orientation.portrait);
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        leadingWidth: 0,
        backgroundColor: colorWhite,
        elevation: isScrolledToTop ? 0 : 2,
        title: GestureDetector(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorWidgetBorder,
                    border: Border.all(width: 1, color: colorWidgetBg)),
                child: Icon(
                  IconlyBold.location,
                  color: colorOrange,
                  size: 20.0,
                ),
              ),
              SizedBox(
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 4),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                getTranslated(context, location).toString(),
                                style: TextStyle(
                                  fontFamily: groldReg,
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                IconlyBold.arrow_down_2,
                                color: colorOrange,
                                size: 16,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Text(
                              selectedLocation,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: groldReg,
                                color: colorBlack,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, setLocationRoute);
            setState(() {
              initializeController();
            });
          },
        ),
        leading: SizedBox(
          width: 1,
          height: 1,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 8, right: 8),
            height: 40,
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
              // padding: EdgeInsets.all(10),
              tooltip: 'Search',
              onPressed: () {
                Navigator.of(context).push(Transitions(
                    transitionType: TransitionType.slideUp,
                    curve: Curves.bounceInOut,
                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                    widget: SearchPage()));
              },
            ),
          ),
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, right: 16),
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorWidgetBorder,
                    border: Border.all(width: 1, color: colorWidgetBg)),
                child: IconButton(
                  icon: Icon(
                    IconlyBroken.buy,
                    color: colorBlack,
                    size: 20.0,
                  ),
                  // padding: EdgeInsets.all(10),
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.of(context).push(Transitions(
                        transitionType: TransitionType.slideUp,
                        curve: Curves.bounceInOut,
                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                        widget: CartScreen()));
                  },
                ),
              ),
              isCartSymbolAvailable == true
                  ? Positioned(
                      top: ScreenUtil().setHeight(4),
                      right: ScreenUtil().setWidth(8),
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 10.0,
                        child: Center(
                          child: Text(
                            cartSymbolAvailableItems.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 1,
                      width: 1,
                    ),
            ],
          ),
        ],

        shadowColor: isScrolledToTop ? Colors.white : colorDivider,
        excludeHeaderSemantics: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            child: isNetworkAvailable == true
                ? isLocationSet == true
                    ? SizedBox(
                        width: SizeConfig.screenWidth,
                        height: SizeConfig.screenHeight,
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView(
                            shrinkWrap: true,
                            padding: widget.isTrackOrderPadding == true
                                ? EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.30)
                                : EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.20),
                            children: [
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: SizeConfig.screenWidth,
                                height: ScreenUtil().setHeight(136),
                                margin: EdgeInsets.only(
                                  left: 0.0,
                                  right: 0.0,
                                ),
                                child: _buildBanners(),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                //height: ScreenUtil().setHeight(260),
                                child: FutureBuilder(
                                  future: businessTypeFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return SizedBox();
                                    } else {
                                      return Container(
                                        height: 320,
                                        alignment: Alignment.center,
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.bottomLeft,
                                              margin: EdgeInsets.only(
                                                left: 0.0,
                                                right: 16.0,
                                                top: 20.0,
                                              ),
                                              child: SizedBox(
                                                height: (MediaQuery.of(context).size.height /
                                                    100) *
                                                    5,
                                                child: Text(
                                                  getTranslated(context, serviceList)
                                                      .toString(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: groldReg,
                                                      fontSize: 18,
                                                      color: colorBlack),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 500,
                                                alignment: Alignment.center,
                                                child: GridView.builder(
                                                  itemCount: 4,
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    childAspectRatio: 1.5,
                                                    crossAxisSpacing:16,
                                                    mainAxisSpacing:16,
                                                  ),
                                                  itemBuilder: (context, index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        index == 0 ? Navigator.pushNamed(context,
                                                            categoryDetailPageRoute,
                                                            arguments:
                                                            businessTypes[index]) : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                          content: Text(businessTypes[index]
                                                              .name
                                                              .toString()+"is currently not available in your place"),
                                                          backgroundColor: colorOrange,
                                                        ));
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(16),
                                                          color: colorPurple,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  top: 16, left: 12),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    businessTypes[index]
                                                                        .name
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign.start,
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow
                                                                        .ellipsis,
                                                                    style: TextStyle(
                                                                      fontSize: (MediaQuery.of(
                                                                                      context)
                                                                                  .size
                                                                                  .width /
                                                                              100) *
                                                                          3.8,
                                                                      fontFamily:
                                                                          groldReg,
                                                                      color: colorWhite,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  CircleAvatar(
                                                                    backgroundColor:
                                                                        colorWhite,
                                                                    radius: 10,
                                                                    child: Icon(
                                                                      IconlyLight
                                                                          .arrow_right,
                                                                      color: colorBlack,
                                                                      size: 12,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )),
                                                            Expanded(
                                                                child: Column(
                                                              children: [
                                                                SizedBox(height: 28),
                                                                CachedNetworkImage(
                                                                  alignment:
                                                                      Alignment.center,
                                                                  fit: BoxFit.fill,
                                                                  height: ScreenUtil()
                                                                      .setHeight(80),
                                                                  width: ScreenUtil()
                                                                      .setWidth(80),
                                                                  imageUrl:
                                                                      businessTypes[index]
                                                                          .fullImage
                                                                          .toString(),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      SpinKitFadingCircle(
                                                                          color:
                                                                              colorRed),
                                                                  errorWidget: (context,
                                                                          url, error) =>
                                                                      Image.asset(
                                                                          "assets/images/no_image.png"),
                                                                ),
                                                              ],
                                                            ))
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                height: ScreenUtil().setHeight(100),
                                alignment: Alignment.center,
                                child: FutureBuilder(
                                  future: businessTypeFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return SizedBox();
                                    } else {
                                      return GridView.builder(
                                        itemCount: 4,
                                        shrinkWrap: true,
                                        primary: false,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 1,
                                          mainAxisSpacing:
                                              ScreenUtil().setHeight(7),
                                        ),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              // Navigator.pushNamed(context,
                                              //     categoryDetailPageRoute,
                                              //     arguments:
                                              //         businessTypes[index + 4]);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text(businessTypes[index+4]
                                                    .name
                                                    .toString()+" is currently not available in your place"),
                                                backgroundColor: colorOrange,
                                              ));
                                            },
                                            child: Container(
                                              height:
                                                  ScreenUtil().setHeight(88),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: colorWhite,
                                                  border: Border.all(
                                                      width: 1,
                                                      color:
                                                          Color(0xffF6F6F6))),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CachedNetworkImage(
                                                      alignment:
                                                          Alignment.center,
                                                      fit: BoxFit.fill,
                                                      height: ScreenUtil()
                                                          .setHeight(40),
                                                      width: ScreenUtil()
                                                          .setWidth(40),
                                                      imageUrl: businessTypes[
                                                              index + 4]
                                                          .fullImage
                                                          .toString(),
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitFadingCircle(
                                                              color: colorRed),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                              "assets/images/no_image.png"),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 2),
                                                      child: Text(
                                                        businessTypes[index + 4]
                                                            .name
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  100) *
                                                              3,
                                                          fontFamily: groldReg,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: colorBlack,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),

                              Container(
                                width: SizeConfig.screenWidth,
                                height: ScreenUtil().setHeight(200),
                                margin: EdgeInsets.only(
                                  left: 0.0,
                                  right: 0.0,
                                ),
                                child: _buildOffersRestaurant(),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: SizeConfig.screenWidth,
                        height: MediaQuery.of(context).size.height / 2 + 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height / 2,
                              child: Image.asset(
                                  'assets/images/setup_location.png'),
                            ),
                            SizedBox(height: 10),
                            Text(
                              getTranslated(context, setupLocation).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: groldReg,
                                  fontSize: 20),
                            ),
                            SizedBox(height: 15),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                getTranslated(context, setupDesc).toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colorBlack,
                                    fontSize: 16,
                                    fontFamily: groldReg),
                              ),
                            ),
                            SizedBox(height: 20),
                            ListTile(
                              onTap: () async {
                                if (PreferenceUtils.getBool(
                                        PreferenceNames.checkLogin) ==
                                    true) {
                                  await Navigator.pushNamed(
                                      context, manageLocationRoute);
                                  setState(() {
                                    initializeController();
                                  });
                                } else {
                                  Navigator.pushNamed(
                                      context, setLocationRoute);
                                }
                              },
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, changeLocation)
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: groldBold,
                                        fontSize: 16,
                                        color: colorBlue),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      IconlyBold.arrow_right_2,
                                      color: colorBlue,
                                      size: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                : NoInternetWidget(),
          ),
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
                  color: colorOrange, borderRadius: BorderRadius.circular(50)),
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
                        Icon(
                          IconlyBold.bag_2,
                          color: Colors.white,
                          size: 20,
                        ),
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

  void singleShopApiOnlyFood() async {
    listCart
        .addAll(ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart);

    print("LIST CART" + listCart.toString());
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

  _buildBanners() => FutureBuilder(
        future: bannerDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SizedBox(
            );
          } else {
            return banners.isNotEmpty
                ? ListView.separated(
                    itemCount: banners.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(width: 15),
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Stack(
                        children: [
                          Container(
                            padding: index == 0
                                ? EdgeInsets.only(left: 20.0)
                                : index == banners.length - 1
                                    ? EdgeInsets.only(right: 20.0)
                                    : EdgeInsets.zero,
                            child: CachedNetworkImage(
                              alignment: Alignment.center,
                              imageUrl: banners[index].fullImage.toString(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: ScreenUtil().setHeight(145),
                                width: MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width / 100) *
                                        10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.grey,
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey.withOpacity(0.5),
                                  //     spreadRadius: 4,
                                  //     blurRadius: 15,
                                  //     offset: Offset(
                                  //         0, 15), // changes position of shadow
                                  //   ),
                                  // ],
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  SizedBox(
                                  ),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/images/no_image.png"),
                            ),
                          ),
                          // Positioned(
                          //   top: ScreenUtil().setHeight(36),
                          //   left: ScreenUtil().setHeight(40),
                          //   child: SizedBox(
                          //     width: ScreenUtil().setWidth(100),
                          //     child: Text(
                          //       banners[index].name.toString(),
                          //       textAlign: TextAlign.left,
                          //       overflow: TextOverflow.ellipsis,
                          //       maxLines: 5,
                          //       style: TextStyle(
                          //           fontSize: 13,
                          //           fontFamily: 'Grold Regular',
                          //           color: Colors.white),
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        getTranslated(context, noDataDesc).toString(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: groldXBold,
                        ),
                      ),
                    ),
                  );
          }
        },
      );

  _buildOffersRestaurant() => FutureBuilder<BaseModel<OffersAtRestaurantModel>>(
    future: offersAtRestaurantFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return SizedBox();
      } else {
        if (snapshot.data!.data == null) {
          if (snapshot.data!.error
              .getErrorMessage()
              .toString()
              .contains('Unauthenticated.')) {
            //clear session and logout
            PreferenceUtils.clear();
            Future.delayed(
                Duration.zero, () => dialogUnauthenticated(context));
          }
          return Center(
              child: Text(snapshot.data!.error.getErrorMessage()));
        } else {
          return offersAtRestaurant.isNotEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.bottomLeft,
                margin: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 20.0,
                ),
                child: SizedBox(
                  height: (MediaQuery.of(context).size.height /
                      100) *
                      5,
                  child: Text(
                    getTranslated(context, topPicks).toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: groldReg,
                        fontSize: 18,
                        color: colorBlack),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 152,
                  alignment: Alignment.center,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: offersAtRestaurant.length,
                    itemBuilder: (context, index1) {
                      return GridView.builder(
                        itemCount: offersAtRestaurant[index1]
                            .discount!
                            .length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisExtent: MediaQuery.of(context)
                                .size
                                .width /
                                1.4),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  alignment: Alignment.center,
                                  fit: BoxFit.fill,
                                  imageUrl: offersAtRestaurant[index1]
                                      .fullImage
                                      .toString(),
                                  imageBuilder:
                                      (context, imageProvider) =>
                                      Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width /
                                            1,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(20.0),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url,
                                      error) =>
                                      Image.asset(
                                          "assets/images/no_image.png"),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 40,
                                  width: ScreenUtil().setWidth(120),
                                  height: ScreenUtil().setHeight(150),
                                  // Note: without ClipRect, the blur region will be expanded to full
                                  // size of the Image instead of custom size
                                  child: ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 0.1, sigmaY: 0.1),
                                      child: Container(
                                        color: Colors.black
                                            .withOpacity(0.7),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    offersAtRestaurant[
                                                    index1]
                                                        .discount![
                                                    index]
                                                        .discount
                                                        .toString() +
                                                        "%",
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .w900,
                                                        fontFamily:
                                                        groldItalic,
                                                        fontSize: 48,
                                                        color:
                                                        colorWhite),
                                                  ),
                                                  Transform.translate(
                                                    offset: Offset(
                                                        -1.0, -9.0),
                                                    child: Text(
                                                      "OFF",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .w500,
                                                          fontFamily:
                                                          groldItalic,
                                                          fontSize: 24,
                                                          color:
                                                          colorWhite),
                                                    ),
                                                  ),
                                                  Transform.translate(
                                                    offset: Offset(
                                                        -1.0, -2.0),
                                                    child: Text(
                                                      "ON ORDERS ABOVE Rs " +
                                                          offersAtRestaurant[
                                                          index1]
                                                              .discount![
                                                          index]
                                                              .minAmount
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                          fontFamily:
                                                          groldXBold,
                                                          fontSize: 8,
                                                          color:
                                                          colorWhite),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: colorOrange),
                                              alignment:
                                              Alignment.center,
                                              child: Padding(
                                                padding: EdgeInsets
                                                    .symmetric(
                                                    vertical: 6,
                                                    horizontal: 2),
                                                child: Text(
                                                  offersAtRestaurant[
                                                  index]
                                                      .name!
                                                      .toString()
                                                      .toUpperCase(),
                                                  maxLines: 1,
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w400,
                                                      fontFamily:
                                                      groldReg,
                                                      fontSize: 16,
                                                      color:
                                                      colorWhite),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          )
              : SizedBox();
        }
      }
    },
  );

  // _buildOffersGrocery() => FutureBuilder(
  //       future: offersAtGroceryFuture,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState != ConnectionState.done) {
  //           return SizedBox(
  //          );
  //         } else {
  //           return offersAtGrocery.isNotEmpty
  //               ? GridView.builder(
  //                   itemCount: offersAtGrocery.length,
  //                   shrinkWrap: true,
  //                   primary: false,
  //                   scrollDirection: Axis.horizontal,
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 2,
  //                     mainAxisExtent: ScreenUtil().screenWidth /
  //                         1.1, // <== change the height to fit your needs
  //                   ),
  //                   itemBuilder: (context, index) {
  //                     return InkWell(
  //                       onTap: () {
  //                         if (offersAtGrocery[index].availableNow == 1) {
  //                           Navigator.pushNamed(
  //                             context,
  //                             foodShopPageRoute,
  //                             arguments: FoodDeliveryShop(
  //                               singleShopId:
  //                                   offersAtGrocery[index].id!.toInt(),
  //                               businessTypeId: businessTypeIdForGrocery,
  //                             ),
  //                           );
  //                         } else {
  //                           CommonFunction.toastMessage(
  //                               getTranslated(context, shopClose).toString());
  //                         }
  //                       },
  //                       child: Container(
  //                         margin: EdgeInsets.all(5),
  //                         height: ScreenUtil().setWidth(75),
  //                         width: ScreenUtil().setWidth(75),
  //                         decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(10),
  //                             boxShadow: [
  //                               BoxShadow(
  //                                 color:
  //                                     Colors.grey.withAlpha(50).withOpacity(.1),
  //                                 spreadRadius: 2,
  //                                 blurRadius: 5,
  //                               ),
  //                             ]),
  //                         padding: EdgeInsets.all(5),
  //                         child: Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Stack(
  //                               children: [
  //                                 CachedNetworkImage(
  //                                   alignment: Alignment.center,
  //                                   fit: BoxFit.fill,
  //                                   height: ScreenUtil().setWidth(75),
  //                                   width: ScreenUtil().setWidth(75),
  //                                   imageUrl: offersAtGrocery[index]
  //                                       .fullImage
  //                                       .toString(),
  //                                   imageBuilder: (context, imageProvider) =>
  //                                       Container(
  //                                     width: MediaQuery.of(context).size.width /
  //                                         1.4,
  //                                     decoration: BoxDecoration(
  //                                       borderRadius:
  //                                           BorderRadius.circular(20.0),
  //                                       image: DecorationImage(
  //                                         image: imageProvider,
  //                                         fit: BoxFit.fill,
  //                                         alignment: Alignment.center,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   placeholder: (context, url) =>
  //                                       SizedBox(
  //                                      ),
  //                                   errorWidget: (context, url, error) =>
  //                                       Image.asset(
  //                                           "assets/images/no_image.png"),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 0,
  //                                   child: Container(
  //                                     height: ScreenUtil().setHeight(23),
  //                                     decoration: BoxDecoration(
  //                                         color: Color(0xFFA5D6B6)
  //                                             .withOpacity(0.8),
  //                                         borderRadius: BorderRadius.vertical(
  //                                             bottom: Radius.circular(15.0))),
  //                                     child: ClipRRect(
  //                                       borderRadius: BorderRadius.vertical(
  //                                           bottom: Radius.circular(15.0)),
  //                                       child: BackdropFilter(
  //                                         filter: ImageFilter.blur(
  //                                             sigmaX: 4.0, sigmaY: 4.0),
  //                                         child: Container(
  //                                           width: ScreenUtil().setWidth(75),
  //                                           alignment: Alignment.center,
  //                                           decoration: BoxDecoration(
  //                                               borderRadius:
  //                                                   BorderRadius.vertical(
  //                                                       bottom: Radius.circular(
  //                                                           15.0))),
  //                                           child: Text(
  //                                             () {
  //                                               if (offersAtGrocery[index]
  //                                                   .discount!
  //                                                   .isNotEmpty) {
  //                                                 return offersAtGrocery[index]
  //                                                     .discount!
  //                                                     .first
  //                                                     .name!;
  //                                               } else {
  //                                                 return '';
  //                                               }
  //                                             }(),
  //                                             overflow: TextOverflow.ellipsis,
  //                                             maxLines: 1,
  //                                             textAlign: TextAlign.center,
  //                                             style: TextStyle(
  //                                               color: colorWhite,
  //                                               fontSize: 13,
  //                                               fontFamily: groldBold,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 )
  //                               ],
  //                             ),
  //                             SizedBox(width: 10),
  //                             SizedBox(
  //                               width: SizeConfig.screenWidth! / 1.7,
  //                               child: Column(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(15),
  //                                     child: Text(
  //                                       offersAtGrocery[index].name.toString(),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         fontFamily: groldXBold,
  //                                         color: colorBlack,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     height: 5,
  //                                   ),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(25),
  //                                     child: Text(
  //                                       () {
  //                                         if (offersAtGrocery[index]
  //                                             .menu!
  //                                             .isNotEmpty) {
  //                                           String allMenus = "";
  //                                           String _temp = "";
  //                                           for (int i = 0;
  //                                               i <
  //                                                   offersAtGrocery[index]
  //                                                       .menu!
  //                                                       .length;
  //                                               i++) {
  //                                             _temp = offersAtGrocery[index]
  //                                                 .menu![i];
  //                                             allMenus =
  //                                                 allMenus + _temp + ', ';
  //                                           }
  //                                           String showMenus =
  //                                               allMenus.substring(
  //                                                   0, allMenus.length - 2);
  //                                           return showMenus + ".";
  //                                         } else {
  //                                           return "";
  //                                         }
  //                                       }(),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       maxLines: 2,
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         fontFamily: groldBold,
  //                                         color: colorDivider,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     height: 5,
  //                                   ),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(16),
  //                                     child: Row(
  //                                       children: [
  //                                         Icon(
  //                                           Icons.star_rate,
  //                                           size: 15,
  //                                           color: Colors.grey,
  //                                         ),
  //                                         SizedBox(
  //                                           width: 5,
  //                                         ),
  //                                         Text(
  //                                           offersAtGrocery[index]
  //                                               .rate
  //                                               .toString(),
  //                                           style: TextStyle(
  //                                               fontSize: 12,
  //                                               color: Colors.grey,
  //                                               fontFamily: groldBold),
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         CircleAvatar(
  //                                           backgroundColor: Colors.grey,
  //                                           radius: 3.0,
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         Text(
  //                                           offersAtGrocery[index]
  //                                                   .distance
  //                                                   .toString() +
  //                                               "Km",
  //                                           style: TextStyle(
  //                                               fontSize: 12,
  //                                               color: Colors.grey,
  //                                               fontFamily: groldBold),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(21),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.spaceBetween,
  //                                       children: [
  //                                         Container(
  //                                           padding: EdgeInsets.all(5),
  //                                           decoration: BoxDecoration(
  //                                               color:
  //                                                   Colors.green.withAlpha(40),
  //                                               borderRadius:
  //                                                   BorderRadius.circular(10)),
  //                                           child: Text(
  //                                             '${getTranslated(context, useCodeText).toString()} ${offersAtGrocery[index].discount![0].code}',
  //                                             overflow: TextOverflow.ellipsis,
  //                                             maxLines: 1,
  //                                             style: TextStyle(
  //                                                 color: Colors.green,
  //                                                 fontSize: 11,
  //                                                 fontFamily: groldReg),
  //                                           ),
  //                                         ),
  //                                         Visibility(
  //                                           visible: offersAtGrocery.length > 1,
  //                                           child: TextButton(
  //                                             onPressed: () {
  //                                               Navigator.pushNamed(
  //                                                 context,
  //                                                 foodShopPageRoute,
  //                                                 arguments: FoodDeliveryShop(
  //                                                   singleShopId:
  //                                                       offersAtGrocery[index]
  //                                                           .id!
  //                                                           .toInt(),
  //                                                   businessTypeId:
  //                                                       businessTypeIdForRestaurant,
  //                                                 ),
  //                                               );
  //                                             },
  //                                             child: Text(
  //                                               getTranslated(context, viewAll)
  //                                                   .toString(),
  //                                               style: TextStyle(
  //                                                   fontWeight: FontWeight.bold,
  //                                                   fontFamily: groldBold,
  //                                                   fontSize: 16,
  //                                                   color: colorBlue),
  //                                             ),
  //                                             style: TextButton.styleFrom(
  //                                                 padding: EdgeInsets.zero),
  //                                           ),
  //                                         )
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 )
  //               : SizedBox(
  //                   height: MediaQuery.of(context).size.height * 0.15,
  //                   width: MediaQuery.of(context).size.width,
  //                   child: Center(
  //                     child: Text(
  //                       getTranslated(context, noDataDesc).toString(),
  //                       textAlign: TextAlign.center,
  //                       overflow: TextOverflow.ellipsis,
  //                       maxLines: 1,
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontFamily: groldXBold,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //         }
  //       },
  //     );

  // _buildOffersFruits() => FutureBuilder(
  //       future: offersAtFruitsFuture,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState != ConnectionState.done) {
  //           return SizedBox(
  //           );
  //         } else {
  //           return offersAtFruit.isNotEmpty
  //               ? GridView.builder(
  //                   itemCount: offersAtFruit.length,
  //                   shrinkWrap: true,
  //                   primary: false,
  //                   scrollDirection: Axis.horizontal,
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 2,
  //                     mainAxisExtent: ScreenUtil().screenWidth /
  //                         1.1, // <== change the height to fit your needs
  //                   ),
  //                   itemBuilder: (context, index) {
  //                     return InkWell(
  //                       onTap: () {
  //                         if (offersAtFruit[index].availableNow == 1) {
  //                           Navigator.pushNamed(
  //                             context,
  //                             foodShopPageRoute,
  //                             arguments: FoodDeliveryShop(
  //                               singleShopId: offersAtFruit[index].id!.toInt(),
  //                               businessTypeId:
  //                                   businessTypeIdForFruitVegetables,
  //                             ),
  //                           );
  //                         } else {
  //                           CommonFunction.toastMessage(
  //                               getTranslated(context, shopClose).toString());
  //                         }
  //                       },
  //                       child: Container(
  //                         margin: EdgeInsets.all(5),
  //                         height: ScreenUtil().setWidth(75),
  //                         width: ScreenUtil().setWidth(75),
  //                         decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(10),
  //                             boxShadow: [
  //                               BoxShadow(
  //                                 color:
  //                                     Colors.grey.withAlpha(50).withOpacity(.1),
  //                                 spreadRadius: 2,
  //                                 blurRadius: 5,
  //                               ),
  //                             ]),
  //                         padding: EdgeInsets.all(5),
  //                         child: Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Stack(
  //                               children: [
  //                                 CachedNetworkImage(
  //                                   alignment: Alignment.center,
  //                                   fit: BoxFit.fill,
  //                                   height: ScreenUtil().setWidth(75),
  //                                   width: ScreenUtil().setWidth(75),
  //                                   imageUrl: offersAtFruit[index]
  //                                       .fullImage
  //                                       .toString(),
  //                                   imageBuilder: (context, imageProvider) =>
  //                                       Container(
  //                                     width: MediaQuery.of(context).size.width /
  //                                         1.4,
  //                                     decoration: BoxDecoration(
  //                                       borderRadius:
  //                                           BorderRadius.circular(20.0),
  //                                       image: DecorationImage(
  //                                         image: imageProvider,
  //                                         fit: BoxFit.fill,
  //                                         alignment: Alignment.center,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   placeholder: (context, url) =>
  //                                       SizedBox(
  //                                       ),
  //                                   errorWidget: (context, url, error) =>
  //                                       Image.asset(
  //                                           "assets/images/no_image.png"),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 0,
  //                                   child: Container(
  //                                     height: ScreenUtil().setHeight(23),
  //                                     decoration: BoxDecoration(
  //                                         color: Color(0xFF6F85C1)
  //                                             .withOpacity(0.8),
  //                                         borderRadius: BorderRadius.vertical(
  //                                             bottom: Radius.circular(15.0))),
  //                                     child: ClipRRect(
  //                                       borderRadius: BorderRadius.vertical(
  //                                           bottom: Radius.circular(15.0)),
  //                                       child: BackdropFilter(
  //                                         filter: ImageFilter.blur(
  //                                             sigmaX: 4.0, sigmaY: 4.0),
  //                                         child: Container(
  //                                           width: ScreenUtil().setWidth(75),
  //                                           alignment: Alignment.center,
  //                                           decoration: BoxDecoration(
  //                                               borderRadius:
  //                                                   BorderRadius.vertical(
  //                                                       bottom: Radius.circular(
  //                                                           15.0))),
  //                                           child: Text(
  //                                             () {
  //                                               if (offersAtFruit[index]
  //                                                   .discount!
  //                                                   .isNotEmpty) {
  //                                                 return offersAtFruit[index]
  //                                                     .discount!
  //                                                     .first
  //                                                     .name!;
  //                                               } else {
  //                                                 return '';
  //                                               }
  //                                             }(),
  //                                             overflow: TextOverflow.ellipsis,
  //                                             maxLines: 1,
  //                                             textAlign: TextAlign.center,
  //                                             style: TextStyle(
  //                                               color: colorWhite,
  //                                               fontSize: 13,
  //                                               fontFamily: groldBold,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 )
  //                               ],
  //                             ),
  //                             SizedBox(width: 10),
  //                             SizedBox(
  //                               width: SizeConfig.screenWidth! / 1.7,
  //                               child: Column(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(15),
  //                                     child: Text(
  //                                       offersAtFruit[index].name.toString(),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         fontFamily: groldXBold,
  //                                         color: colorBlack,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(25),
  //                                     child: Text(
  //                                       () {
  //                                         if (offersAtFruit[index]
  //                                             .menu!
  //                                             .isNotEmpty) {
  //                                           String allMenus = "";
  //                                           String _temp = "";
  //                                           for (int i = 0;
  //                                               i <
  //                                                   offersAtFruit[index]
  //                                                       .menu!
  //                                                       .length;
  //                                               i++) {
  //                                             _temp =
  //                                                 offersAtFruit[index].menu![i];
  //                                             allMenus =
  //                                                 allMenus + _temp + ', ';
  //                                           }
  //                                           String showMenus =
  //                                               allMenus.substring(
  //                                                   0, allMenus.length - 2);
  //                                           return showMenus + ".";
  //                                         } else {
  //                                           return "";
  //                                         }
  //                                       }(),
  //                                       overflow: TextOverflow.ellipsis,
  //                                       maxLines: 2,
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         fontFamily: groldBold,
  //                                         color: colorDivider,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(16),
  //                                     child: Row(
  //                                       children: [
  //                                         Icon(
  //                                           Icons.star_rate,
  //                                           size: 15,
  //                                           color: Colors.grey,
  //                                         ),
  //                                         SizedBox(width: 5),
  //                                         Text(
  //                                           offersAtFruit[index]
  //                                               .rate
  //                                               .toString(),
  //                                           style: TextStyle(
  //                                               fontSize: 12,
  //                                               color: Colors.grey,
  //                                               fontFamily: groldBold),
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         CircleAvatar(
  //                                           backgroundColor: Colors.grey,
  //                                           radius: 3.0,
  //                                         ),
  //                                         SizedBox(width: 10),
  //                                         Text(
  //                                           offersAtFruit[index]
  //                                                   .distance
  //                                                   .toString() +
  //                                               "Km",
  //                                           style: TextStyle(
  //                                               fontSize: 12,
  //                                               color: Colors.grey,
  //                                               fontFamily: groldBold),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   SizedBox(
  //                                     height: ScreenUtil().setHeight(21),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.spaceBetween,
  //                                       children: [
  //                                         Container(
  //                                           padding: EdgeInsets.all(5),
  //                                           decoration: BoxDecoration(
  //                                               color:
  //                                                   Colors.blue.withAlpha(40),
  //                                               borderRadius:
  //                                                   BorderRadius.circular(10)),
  //                                           child: Text(
  //                                             '${getTranslated(context, useCodeText).toString()} ${offersAtFruit[index].discount![0].code}',
  //                                             overflow: TextOverflow.ellipsis,
  //                                             maxLines: 1,
  //                                             style: TextStyle(
  //                                                 color: Colors.blue,
  //                                                 fontSize: 11,
  //                                                 fontFamily: groldReg),
  //                                           ),
  //                                         ),
  //                                         Visibility(
  //                                           visible: offersAtFruit.length > 1,
  //                                           child: TextButton(
  //                                             onPressed: () {
  //                                               Navigator.pushNamed(
  //                                                 context,
  //                                                 foodShopPageRoute,
  //                                                 arguments: FoodDeliveryShop(
  //                                                   singleShopId:
  //                                                       offersAtFruit[index]
  //                                                           .id!
  //                                                           .toInt(),
  //                                                   businessTypeId:
  //                                                       businessTypeIdForRestaurant,
  //                                                 ),
  //                                               );
  //                                             },
  //                                             child: Text(
  //                                               getTranslated(context, viewAll)
  //                                                   .toString(),
  //                                               style: TextStyle(
  //                                                   fontWeight: FontWeight.bold,
  //                                                   fontFamily: groldBold,
  //                                                   fontSize: 16,
  //                                                   color: colorBlue),
  //                                             ),
  //                                             style: TextButton.styleFrom(
  //                                                 padding: EdgeInsets.zero),
  //                                           ),
  //                                         )
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 )
  //               : SizedBox(
  //                   height: MediaQuery.of(context).size.height * 0.15,
  //                   width: MediaQuery.of(context).size.width,
  //                   child: Center(
  //                     child: Text(
  //                       getTranslated(context, noDataDesc).toString(),
  //                       textAlign: TextAlign.center,
  //                       overflow: TextOverflow.ellipsis,
  //                       maxLines: 1,
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontFamily: groldXBold,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //         }
  //       },
  //     );

  getUserLocation() async {
    final allRows = await dbHelper.queryAllRows();
    if (allRows.isNotEmpty) {
      isCartSymbolAvailable = true;
      cartSymbolAvailableItems = allRows.length;
      // setState(() {
      // });
    }
    if (PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation) != 0.0 &&
        PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation) != 0.0) {
      double lat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation);
      double long =
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation);
      //for initialize future data
      offersAtRestaurantFuture =
          offersAtRestaurantApi(lat.toString(), long.toString());
      offersAtGroceryFuture =
          offersAtGroceryApi(lat.toString(), long.toString());
      offersAtFruitsFuture =
          offersAtFruitsAndVegetableApi(lat.toString(), long.toString());
      //for call api data
      offersAtRestaurantApi(lat.toString(), long.toString());
      offersAtGroceryApi(lat.toString(), long.toString());
      offersAtFruitsAndVegetableApi(lat.toString(), long.toString());
    } else {
      currentLocation = await locateUser();
      if (mounted) {
        setState(() {
          _center = LatLng(currentLocation.latitude, currentLocation.longitude);
        });
      }
      Future.delayed(Duration(seconds: 1), () {
        PreferenceUtils.setDouble(
            PreferenceNames.latOfSetLocation, _center.latitude);
        PreferenceUtils.setDouble(
            PreferenceNames.longOfSetLocation, _center.longitude);
        //for initialize future data
        offersAtRestaurantFuture = offersAtRestaurantApi(
            _center.latitude.toString(), _center.longitude.toString());
        offersAtGroceryFuture = offersAtGroceryApi(
            _center.latitude.toString(), _center.longitude.toString());
        offersAtFruitsFuture = offersAtFruitsAndVegetableApi(
            _center.latitude.toString(), _center.longitude.toString());
        //for call api
        offersAtRestaurantApi(
            _center.latitude.toString(), _center.longitude.toString());
        offersAtGroceryApi(
            _center.latitude.toString(), _center.longitude.toString());
        offersAtFruitsAndVegetableApi(
            _center.latitude.toString(), _center.longitude.toString());
      });
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
    if (mounted) {
      setState(() {
        CommonFunction.checkNetwork()
            .then((value) => isNetworkAvailable = value);
        initializeController();
      });
    }
  }

  Future<BaseModel<BannerModel>> bannerApi() async {
    BannerModel response;
    try {
      setState(() {});
      response = await ApiServices(ApiHeader().dioData()).banner();

      banners.clear();
      if (response.success == true) {
        banners.addAll(response.data!);
      } else {}

      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<BusinessTypesModel>> businessTypesApi() async {
    BusinessTypesModel response;
    try {
      setState(() {});
      response = await ApiServices(ApiHeader().dioData()).businessType();

      businessTypes.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          businessTypes.addAll(response.data!);
          businessTypeIdForRestaurant = 2;
          businessTypeIdForGrocery = 3;
          businessTypeIdForFruitVegetables = 4;
        }
      }
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OffersAtRestaurantModel>> offersAtRestaurantApi(
      String lat, String long) async {
    OffersAtRestaurantModel response;
    try {
      setState(() {});

      Map<String, dynamic> body = {
        'lat': lat,
        'lang': long,
      };
      response =
          await ApiServices(ApiHeader().dioData()).offersAtRestaurant(body);

      offersAtRestaurant.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          offersAtRestaurant.addAll(response.data!);
          print("home_widget Line 1745" + response.data!.toString());
        }
      }
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OffersAtGroceryModel>> offersAtGroceryApi(
      String lat, String long) async {
    OffersAtGroceryModel response;
    try {
      setState(() {});

      Map<String, dynamic> body = {
        'lat': lat,
        'lang': long,
      };
      response = await ApiServices(ApiHeader().dioData()).offersAtGrocery(body);

      offersAtGrocery.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          offersAtGrocery.addAll(response.data!);
        } else {}
      } else {}
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<OffersAtFruitsModel>> offersAtFruitsAndVegetableApi(
      String lat, String long) async {
    OffersAtFruitsModel response;
    try {
      setState(() {});

      Map<String, dynamic> body = {
        'lat': lat,
        'lang': long,
      };

      response = await ApiServices(ApiHeader().dioData()).offersAtFruit(body);
      offersAtFruit.clear();
      if (response.success == true) {
        if (response.data!.isNotEmpty) {
          offersAtFruit.addAll(response.data!);
        }
      }
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<String>> addAddress() async {
    String response;
    try {
      String address = '',
          landmark = '',
          locationType = '',
          lat = "",
          long = "";
      assert(PreferenceUtils.getString(
                  PreferenceNames.addressOfSetLocationWithoutLogin)
              .isNotEmpty &&
          PreferenceUtils.getString(
                  PreferenceNames.landMarkOfSetLocationWithoutLogin)
              .isNotEmpty &&
          PreferenceUtils.getString(
                  PreferenceNames.locationTypeOfSetLocationWithoutLogin)
              .isNotEmpty &&
          PreferenceUtils.getDouble(
                  PreferenceNames.latOfSetLocationWithoutLogin) >
              0.0 &&
          PreferenceUtils.getDouble(
                  PreferenceNames.longOfSetLocationWithoutLogin) >
              0.0);
      address = PreferenceUtils.getString(
          PreferenceNames.addressOfSetLocationWithoutLogin);
      landmark = PreferenceUtils.getString(
          PreferenceNames.landMarkOfSetLocationWithoutLogin);
      locationType = PreferenceUtils.getString(
                  PreferenceNames.locationTypeOfSetLocationWithoutLogin) ==
              'N/A'
          ? "Home"
          : PreferenceUtils.getString(
              PreferenceNames.locationTypeOfSetLocationWithoutLogin);
      lat = PreferenceUtils.getDouble(
              PreferenceNames.latOfSetLocationWithoutLogin)
          .toString();
      long = PreferenceUtils.getDouble(
              PreferenceNames.longOfSetLocationWithoutLogin)
          .toString();

      Map<String, dynamic> bodyForApi = {
        'address': address,
        'landmark': landmark,
        'location_type': locationType,
        'lat': lat,
        'lang': long,
      };
      response =
          await ApiServices(ApiHeader().dioData()).addLocation(bodyForApi);

      final body = json.decode(response);
      bool? success = body['success'];

      if (success == true) {
        PreferenceUtils.setInt(
            PreferenceNames.idOfSetLocation, body['location']['id']);
        PreferenceUtils.setBool(PreferenceNames.storeWithoutLogin, false);
        PreferenceUtils.remove(
            PreferenceNames.addressOfSetLocationWithoutLogin);
        PreferenceUtils.remove(
            PreferenceNames.landMarkOfSetLocationWithoutLogin);
        PreferenceUtils.remove(
            PreferenceNames.locationTypeOfSetLocationWithoutLogin);
        PreferenceUtils.remove(PreferenceNames.latOfSetLocationWithoutLogin);
        PreferenceUtils.remove(PreferenceNames.longOfSetLocationWithoutLogin);
      } else {
        CommonFunction.toastMessage(body["message"]);
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SettingModel>> settingData() async {
    SettingModel response;
    try {
      setState(() {});

      response = await ApiServices(ApiHeader().dioData()).settingApi();

      if (response.success == true) {
        PreferenceUtils.setString(
            PreferenceNames.appNameSetting, response.data!.name.toString());
        PreferenceUtils.setString(PreferenceNames.currencyCodeSetting,
            response.data!.currencyCode.toString());
        PreferenceUtils.setString(PreferenceNames.currencySymbolSetting,
            response.data!.currencySymbol.toString());
        PreferenceUtils.setString(PreferenceNames.aboutInfoSetting,
            response.data!.userAbout.toString());
        PreferenceUtils.setString(PreferenceNames.tAndCInfoSetting,
            response.data!.userTAndC.toString());
        PreferenceUtils.setString(PreferenceNames.privacyInfoSetting,
            response.data!.userPrivacy.toString());
        PreferenceUtils.setString(PreferenceNames.deliveryChargeBasedOnSetting,
            response.data!.deliveryChargeBasedOn.toString());
        PreferenceUtils.setString(PreferenceNames.deliveryChargeSetting,
            response.data!.deliveryCharges.toString());
        PreferenceUtils.setString(PreferenceNames.amountBaseOnSetting,
            response.data!.amountBasedOn.toString());
        PreferenceUtils.setString(
            PreferenceNames.amountSetting, response.data!.amount.toString());
        PreferenceUtils.setString(
            PreferenceNames.autoRefresh, response.data!.autoRefresh!);
        if (response.data!.paypal == "1") {
          PreferenceUtils.setString(PreferenceNames.paypalAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalAvailable, "0");
        }
        if (response.data!.razor == "1") {
          PreferenceUtils.setString(
              PreferenceNames.razorPayAvailable.toString(), "1");
        } else {
          PreferenceUtils.setString(
              PreferenceNames.razorPayAvailable.toString(), "0");
        }
        if (response.data!.stripe == "1") {
          PreferenceUtils.setString(PreferenceNames.stripeAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.stripeAvailable, "0");
        }
        if (response.data!.cod == "1") {
          PreferenceUtils.setString(PreferenceNames.codAvailable, "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.codAvailable, "0");
        }
        if (response.data!.razorKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.razorPayKey, response.data!.razorKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.razorPayKey, "");
        }
        if (response.data!.flutterwaveKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.flutterWaveKey, response.data!.flutterwaveKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.flutterWaveKey, "");
        }
        if (response.data!.paypalProductionKey != null) {
          PreferenceUtils.setString(PreferenceNames.paypalProductionKey,
              response.data!.paypalProductionKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalProductionKey, "");
        }
        if (response.data!.paypalEnviromentKey != null) {
          PreferenceUtils.setString(PreferenceNames.paypalEnvironmentKey,
              response.data!.paypalEnviromentKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.paypalEnvironmentKey, "");
        }
        if (response.data!.paystackKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.payStackKey, response.data!.paystackKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.payStackKey, "");
        }
        if (response.data!.stripeSecretKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.stripeSecretKey, response.data!.stripeSecretKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.stripeSecretKey, "");
        }
        if (response.data!.stripePublicKey != null) {
          PreferenceUtils.setString(
              PreferenceNames.stripePublicKey, response.data!.stripePublicKey!);
        } else {
          PreferenceUtils.setString(PreferenceNames.stripePublicKey, "");
        }
        if (response.data!.userAppId != null) {
          PreferenceUtils.setString(
              PreferenceNames.onesignalUserAppID, response.data!.userAppId!);
        } else {
          PreferenceUtils.setString(PreferenceNames.onesignalUserAppID, "");
        }
        if (PreferenceUtils.getString(PreferenceNames.onesignalPushToken)
                .isNotEmpty ||
            PreferenceUtils.getString(PreferenceNames.onesignalPushToken) !=
                'N/A') {
          getOneSingleToken(
              PreferenceUtils.getString(PreferenceNames.onesignalUserAppID));
        } else {
          CommonFunction.toastMessage('Error while get app setting data.');
        }
      }
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSingleToken(String appId) async {
    // String push_token = '';
    String? userId = '';
    // OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);// for onesignal debug
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await (OneSignal.shared.getDeviceState());
    // var pushtoken = await status.subscriptionStatus.pushToken;
    userId = status!.userId;
    print("pushtoken1:$userId");
    // print("pushtoken123456:$pushtoken");
    // push_token = pushtoken-;

    if (PreferenceUtils.getString(PreferenceNames.onesignalPushToken).isEmpty) {
    } else {
      PreferenceUtils.setString(PreferenceNames.onesignalPushToken, userId!);
    }
    print('ok =======5');
  }

  dialogUnauthenticated(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(0),
                color: colorRed,
                child: Center(
                  child: Text(
                    getTranslated(context, alert)!,
                    style: TextStyle(
                      fontFamily: groldBold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            //height: MediaQuery.of(context).size.height / 2.5,
            return Wrap(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        getTranslated(context, yourSessionExpired)!,
                        style: TextStyle(
                            color: colorPink,
                            fontSize: 16,
                            fontFamily: groldBold),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            );
          }),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: colorRed),
              child: Text(
                getTranslated(context, ok)!,
                style: TextStyle(
                    fontFamily: groldBold, fontSize: 12, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
