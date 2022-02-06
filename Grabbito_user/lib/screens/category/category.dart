import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/model/homepage/business_types_model.dart';
import 'package:grabbito/model/homepage/offers_at_restaurant_model.dart';
import 'package:grabbito/model/shops_model.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/auth/login_screen.dart';
import 'package:grabbito/screens/category/pickup_and_drop.dart';
import 'package:grabbito/screens/category_details/food/food_shops.dart';
import 'package:grabbito/screens/common/widget_no_internet.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';
import 'package:iconly/iconly.dart';
import 'package:scoped_model/scoped_model.dart';

class CategoryDetailPage extends StatefulWidget {
  final BusinessTypesData category;
  CategoryDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<Shop> shopData = [];
  late Position currentLocation;
  int totalShops = 0, businessTypeId = 0;
  String pageName = "", title = "", slogan = "", imageUrl = "";

  final dbHelper = DatabaseHelper.instance;
  bool isCartSymbolAvailable = false;
  int cartSymbolAvailableItems = 0;
  int businessTypeIdForRestaurant = 2;
  int businessTypeIdForGrocery = 3;
  int businessTypeIdForFruitVegetables = 4;
  double aspect = 0.00;
  double aspect1 = 0.00;
  String selectedLocation = "Select Location";
  late LatLng _center;
  bool isLocationSet = false;
  bool isNetworkAvailable = true;
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

  //for Future data
  Future<BaseModel<BusinessTypesModel>>? businessTypeFuture;
  Future<BaseModel<OffersAtRestaurantModel>>? offersAtRestaurantFuture;

  Future<BaseModel<ShopsModel>>? businessTypeShopsFuture;

  @override
  void initState() {
    super.initState();
    double lat = PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation);
    double long = PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation);
    businessTypeShopsFuture = businessTypeShopsApi();
    offersAtRestaurantFuture =
        offersAtRestaurantApi(lat.toString(), long.toString());
    singleShopApiOnlyFood();
    _queryFirst(context);
  }

  void singleShopApiOnlyFood() async {

          listCart.addAll(
              ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart);

          print("LIST CART"+listCart.toString());

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
          widget.category.name.toString(),
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
          child: SizedBox(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Container(
              child: isNetworkAvailable == true
                  ? RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        shrinkWrap: true,
                        //padding: EdgeInsets.only( bottom: MediaQuery.of(context).size.height *0.30),
                        children: [
                          Container(
                            width: SizeConfig.screenWidth,
                            height: ScreenUtil().setHeight(200),
                            margin: EdgeInsets.only(
                              left: 0.0,
                              right: 0.0,
                            ),
                            child: widget.category.name == "Food & Drink" ? _buildOffersRestaurant() : Center(
                          child: Text("No offer found in "+widget.category.name.toString(),style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),)),
                          ),
                          SizedBox(height: 24),
                          Container(
                            alignment: Alignment.bottomLeft,
                            margin: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: SizedBox(
                              height:
                                  (MediaQuery.of(context).size.height / 100) *
                                      5,
                              child: Text(
                                getTranslated(context, shops).toString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: groldReg,
                                    fontSize: 18,
                                    color: colorBlack),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 0.0,
                              right: 0.0,
                            ),
                            child: _buildRestaurant(),
                          ),
                          SizedBox(
                            height: 120,
                          ),
                        ],
                      ),
                    )
                  : NoInternetWidget(),
            ),
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
      });
    }
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


  _buildOffersRestaurant() => FutureBuilder<BaseModel<OffersAtRestaurantModel>>(
    future: offersAtRestaurantFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return SpinKitFadingCircle(color: colorRed);
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
                  height:
                  (MediaQuery.of(context).size.height / 100) * 5,
                  child: Text(
                    getTranslated(context, offersAtRestaurantName)
                        .toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: groldReg,
                        fontSize: 20,
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
                                  placeholder: (context, url) =>
                                      SpinKitFadingCircle(
                                          color: colorRed),
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

  _buildRestaurant() => FutureBuilder(
        future: businessTypeShopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SpinKitFadingCircle(color: colorRed);
          } else {
            return Container(
              padding: EdgeInsets.only(left: 16, top: 0, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   widget.category.id == 2
                  //       ? '$totalShops ${getTranslated(context, restaurantAvailable).toString()}'
                  //       : '$totalShops ${getTranslated(context, storeAvailable).toString()}',
                  //   style: TextStyle(
                  //       fontFamily: groldXBold,
                  //       color: colorBlack,
                  //       fontSize: 18),
                  // ),
                  Container(
                    child: shopData.isNotEmpty
                        ? GridView.builder(
                            itemCount: shopData.length,
                            shrinkWrap: true,
                            primary: false,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: ScreenUtil().setWidth(16),
                              mainAxisSpacing: ScreenUtil().setHeight(16),
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  //shop available or not
                                  if (shopData[index].availableNow == 1) {
                                    //for pickup and drop
                                    if (widget.category.id == 9) {
                                      PreferenceUtils.setInt(
                                          PreferenceNames.pickupShopId,
                                          shopData[index].id!.toInt());
                                      PreferenceUtils.setString(
                                          PreferenceNames.pickupShopName,
                                          shopData[index].name.toString());
                                      PreferenceUtils.setString(
                                          PreferenceNames.pickupShopTitle,
                                          title);
                                      PreferenceUtils.setString(
                                          PreferenceNames.pickupShopBanner,
                                          imageUrl);
                                      PreferenceUtils.setString(
                                          PreferenceNames.pickupShopSlogan,
                                          slogan);
                                    }
                                    widget.category.id == 9
                                        ? Navigator.push(
                                            context,
                                            Transitions(
                                              transitionType:
                                                  TransitionType.slideUp,
                                              curve: Curves.bounceInOut,
                                              reverseCurve:
                                                  Curves.fastLinearToSlowEaseIn,
                                              widget: PickupAndDrop(),
                                            ),
                                          )
                                        : Navigator.pushNamed(
                                            context, foodShopPageRoute,
                                            // arguments: shopData[index].id,
                                            arguments: FoodDeliveryShop(
                                              singleShopId:
                                                  shopData[index].id!.toInt(),
                                              businessTypeId: businessTypeId,
                                            ));
                                  } else {
                                    Navigator.pushNamed(
                                        context, foodShopPageRoute,
                                        // arguments: shopData[index].id,
                                        arguments: FoodDeliveryShop(
                                          singleShopId:
                                          shopData[index].id!.toInt(),
                                          businessTypeId: businessTypeId,
                                        ));
                                    // CommonFunction.toastMessage(
                                    //     getTranslated(context, shopClose)
                                    //         .toString());
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: (MediaQuery.of(context).size.height / 100) * 15,
                                      alignment: Alignment.center,
                                      child: CachedNetworkImage(
                                        alignment: Alignment.center,
                                        fit: BoxFit.fill,
                                        imageUrl: shopData[index]
                                            .fullImage
                                            .toString(),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.4,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
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
                                                "assets/images/no_image.png"),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 48,
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child: Row(
                                              children: [
                                                Expanded(
                                                  flex:2,
                                                  child: Container(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(shopData[index]
                                                        .name
                                                        .toString(),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.start,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: groldReg,
                                                      fontWeight: FontWeight.w400,
                                                    ),),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: Colors.white,
                                                  ),
                                                )
                                              ],
                                            )),
                                            Expanded(child: Row(
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
                                                Text( shopData[index]
                                                    .distance == 0? "0.1km" :shopData[index]
                                                    .distance
                                                    .toString()+"km",style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: groldReg,
                                                  fontWeight: FontWeight.w200,
                                                ),),
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
                                                Text(shopData[index]
                                                    .estimatedTime
                                                    .toString()+"mins",style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: groldReg,
                                                  fontWeight: FontWeight.w200,
                                                ),)
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Align(
                                    //   alignment: Alignment.center,
                                    //   child: Container(
                                    //     width: 20,
                                    //     height: 20,
                                    //     color: Colors.black,
                                    //   ),
                                    // ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.translate(
                                        offset: Offset(36.0, 36.0),
                                        child: Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                                alignment: Alignment.center,
                                                child: CachedNetworkImage(
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.fill,
                                                  imageUrl: "https://grabbito.com/public/images/upload/"+shopData[index]
                                                      .bannerImage
                                                      .toString(),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(

                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.4,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.fill,
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: colorRed),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Image.asset(
                                                          "assets/images/Merchant.png"),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Column(
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
            );
          }
        },
      );

  Future<BaseModel<ShopsModel>> businessTypeShopsApi() async {
    ShopsModel response;
    try {
      response = await ApiServices(ApiHeader().dioData()).shopApi(
          widget.category.id,
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
              .toString(),
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
              .toString());

      totalShops = response.data!.shop!.length;
      if (response.success == true) {
        if (response.data!.shop!.isNotEmpty) {
          shopData.addAll(response.data!.shop!);
          shopData.sort((a,b) => a.distance!.compareTo(b.distance!));
        }
        if (response.data!.bussinessType != null) {
          pageName = response.data!.bussinessType!.name.toString();
          title = response.data!.bussinessType!.title1.toString();
          slogan = response.data!.bussinessType!.title2.toString();
          imageUrl = response.data!.bussinessType!.fullBannerImage.toString();
          businessTypeId = response.data!.bussinessType!.id!.toInt();
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
}
