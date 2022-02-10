import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/single_shop_search.dart';
import 'package:grabbito/model/single_shop_search.dart' as demo;
import 'package:grabbito/model/single_shop_model.dart' as singleShopModelLib;
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/model/cart_model.dart';

class SearchFood extends StatefulWidget {
  final int singleShopId;
  final String shopName;
  final int businessTypeId;
  SearchFood(
      {required this.singleShopId,
      required this.shopName,
      required this.businessTypeId});
  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  TextEditingController searchController = TextEditingController();
  bool isSearched = false;
  // bool _loading = false;
  Timer? _timer;
  String previousKeyword = "";
  int foundedResult = 0;
  List<demo.SingleShopSearchModelData> singleShopSearchData = [];
  final dbHelper = DatabaseHelper.instance;
  List<Product> products = [];
  List<Product> listCart = [];
  int restaurantId = 0;
  String restaurantName = "",
      restaurantImage = "",
      address = '',
      distance = '',
      restaurantEstimatedTime = '';
  List<bool> listFinalCustomizationCheck = [];
  int totalQty = 0;
  double totalCartAmount = 0;
  Future<BaseModel<SingleShopSearchModel>>? searchedFuture;

  @override
  void initState() {
    super.initState();
    singleShopApiOnlyFood();
    _queryFirst(context);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.shopName.isNotEmpty
              ? '${getTranslated(context, searchFoodInText).toString()}${widget.shopName}'
              : getTranslated(context, searchFoodText).toString(),
          style: TextStyle(
              fontFamily: 'Grold Black', color: colorBlack, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                width: SizeConfig.screenWidth! / 1.1,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withAlpha(10), spreadRadius: 0),
                    ]),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      previousKeyword = value.substring(value.length - 1);
                      searchWithThrottle(value, throttleTime: 1);
                      setState(() {
                        isSearched = true;
                      });
                    }
                  },
                  onSubmitted: (value) {
                    setState(() {
                      isSearched = false;
                      searchController.clear();
                    });
                  },
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                      color: colorDivider,
                      fontFamily: 'Grold Regular',
                      fontSize: 16),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: GestureDetector(
                      child: Icon(Icons.search, color: colorDivider),
                      onTap: () {
                        setState(() {
                          isSearched = true;
                          searchController.text = 'Food delivery';
                        });
                      },
                    ),
                    suffixIcon: GestureDetector(
                      child: isSearched
                          ? Icon(Icons.clear, color: colorDivider)
                          : SizedBox(
                              height: 10,
                              width: 10,
                            ),
                      onTap: () {
                        setState(() {
                          isSearched = false;
                          searchController.clear();
                        });
                      },
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            isSearched == false
                ? SizedBox(
                    height: 1,
                    width: 1,
                  )
                : Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${getTranslated(context, foundedResults).toString()} ( $foundedResult )',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Grold XBold',
                                fontSize: 18,
                                color: colorBlack),
                          ),
                          _itemBuilder()
                        ],
                      ),
                    ),
                  )
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
          child: Container(
            height: 60,
            width: SizeConfig.screenWidth,
            color: colorGreen,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
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
                        thickness: 3,
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
                            fontFamily: groldReg),
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
                      SizedBox(width: 5),
                      Image(image: AssetImage('assets/images/bag.png')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _itemBuilder() => ScopedModelDescendant<CartModel>(
        builder: (context, child, model) {
          return FutureBuilder(
            future: searchedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SpinKitFadingCircle(color: colorRed);
              } else {
                return singleShopSearchData.isNotEmpty
                    ? ListView.separated(
                        itemCount: singleShopSearchData.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.all(5),
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.black),
                        itemBuilder: (BuildContext context, int subMenuIndex) {
                          return Container(
                            width: SizeConfig.screenWidth,
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: SizeConfig.screenWidth! / 1.5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          widget.businessTypeId == 2
                                              ? CircleAvatar(
                                                  backgroundColor:
                                                      singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .type ==
                                                              "veg"
                                                          ? Colors.green
                                                          : Colors.red,
                                                  radius: 8.0,
                                                )
                                              : SizedBox(
                                                  height: 0.1,
                                                  width: 0.1,
                                                ),
                                          widget.businessTypeId == 2
                                              ? SizedBox(width: 10)
                                              : SizedBox(
                                                  height: 0.1,
                                                  width: 0.1,
                                                ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.7,
                                            child: Text(
                                              singleShopSearchData[subMenuIndex]
                                                  .name
                                                  .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: groldReg,
                                                color: colorBlack,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        singleShopSearchData[subMenuIndex]
                                            .description
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: groldReg,
                                          color: colorDivider,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${singleShopSearchData[subMenuIndex].price}',
                                        style: TextStyle(
                                          fontFamily: groldReg,
                                          color: colorBlack,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  child: singleShopSearchData[subMenuIndex]
                                          .isAdded!
                                      ? Container(
                                          height: 40,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey.withAlpha(30),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height:
                                                    20,
                                                width:
                                                    23,
                                                child: IconButton(
                                                  onPressed: () {
                                                    if (singleShopSearchData[
                                                                subMenuIndex]
                                                            .custimization!
                                                            .isNotEmpty &&
                                                        singleShopSearchData[
                                                                subMenuIndex]
                                                            .isRepeatCustomization!) {
                                                      int isRepeatCustomization =
                                                          singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .isRepeatCustomization!
                                                              ? 1
                                                              : 0;

                                                      setState(() {
                                                        if (singleShopSearchData[
                                                                    subMenuIndex]
                                                                .count !=
                                                            1) {
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count--;
                                                        } else {
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .isAdded = false;
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count = 0;
                                                        }
                                                      });
                                                      model.updateProduct(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count);
                                                      String?
                                                          finalFoodCustomization;
                                                      double? price, tempPrice;
                                                      int? qty;
                                                      for (int z = 0;
                                                          z < model.cart.length;
                                                          z++) {
                                                        if (singleShopSearchData[
                                                                    subMenuIndex]
                                                                .id ==
                                                            model.cart[z].id) {
                                                          json.decode(model
                                                              .cart[z]
                                                              .foodCustomization!);
                                                          finalFoodCustomization =
                                                              model.cart[z]
                                                                  .foodCustomization;
                                                          price = model
                                                              .cart[z].price;
                                                          // title = model.cart[z].title;
                                                          qty =
                                                              model.cart[z].qty;
                                                          tempPrice = model
                                                              .cart[z]
                                                              .tempPrice;
                                                        }
                                                      }
                                                      if (qty != null &&
                                                          tempPrice != null) {
                                                        price = tempPrice * qty;
                                                      } else {
                                                        price = 0;
                                                      }
                                                      _updateForCustomizedFood(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          price.toString(),
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantId,
                                                          restaurantName,
                                                          finalFoodCustomization,
                                                          isRepeatCustomization,
                                                          1);
                                                    } else {
                                                      setState(() {
                                                        if (singleShopSearchData[
                                                                    subMenuIndex]
                                                                .count !=
                                                            1) {
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count--;
                                                          // ConstantsUtils.removeItem(widget.listRestaurantsMenu[widget.index].name, menus[index,.submenu![subMenuIndexmenus[index..submenu![subMenuIndexid);
                                                        } else {
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .isAdded = false;
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count = 0;
                                                        }
                                                      });
                                                      model.updateProduct(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count);
                                                      _update(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantId,
                                                          restaurantName,
                                                          0,
                                                          0,
                                                          0,
                                                          '0');
                                                    }
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  iconSize: ScreenUtil()
                                                      .setHeight(20),
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: colorButton,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width:
                                                    17,
                                                color: colorWhite,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    singleShopSearchData[
                                                            subMenuIndex]
                                                        .count
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: groldReg,
                                                      color: colorBlack,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    20,
                                                width:
                                                    23,
                                                child: IconButton(
                                                  onPressed: () {
                                                    if (singleShopSearchData[
                                                            subMenuIndex]
                                                        .custimization!
                                                        .isNotEmpty) {
                                                      var ab;
                                                      String?
                                                          finalFoodCustomization;
                                                      double price = 0;
                                                      int qty = 0;
                                                      for (int z = 0;
                                                          z < model.cart.length;
                                                          z++) {
                                                        if (singleShopSearchData[
                                                                    subMenuIndex]
                                                                .id ==
                                                            model.cart[z].id) {
                                                          ab = json.decode(model
                                                              .cart[z]
                                                              .foodCustomization!);
                                                          finalFoodCustomization =
                                                              model.cart[z]
                                                                  .foodCustomization;
                                                          price = model
                                                              .cart[z].price!;
                                                          qty = model
                                                              .cart[z].qty!;
                                                        }
                                                      }
                                                      List<String?>
                                                          nameOfcustomization =
                                                          [];
                                                      for (int i = 0;
                                                          i < ab.length;
                                                          i++) {
                                                        nameOfcustomization.add(
                                                            ab[i]['data']
                                                                ['name']);
                                                      }
                                                      singleShopSearchData[
                                                                  subMenuIndex]
                                                              .isRepeatCustomization =
                                                          true;
                                                      updateCustomizationFoodDataToDB(
                                                        finalFoodCustomization,
                                                        singleShopModelLib
                                                            .Submenu(
                                                          count: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          id: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          fullImage:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .fullImage,
                                                          name: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          type: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .type,
                                                          description:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .description,
                                                          image: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          isAdded:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .isAdded,
                                                          isRepeatCustomization:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .isRepeatCustomization,
                                                          price: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          unit: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .unit,
                                                          unitId:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .unitId
                                                                  .toString(),
                                                          custimization: singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .custimization
                                                              as List<
                                                                  singleShopModelLib
                                                                      .Custimization>?,
                                                        ),
                                                        model,
                                                        price += price * qty,
                                                      );
                                                    } else {
                                                      setState(() {
                                                        singleShopSearchData[
                                                                subMenuIndex]
                                                            .count++;
                                                      });
                                                      model.updateProduct(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count);
                                                      _update(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantId,
                                                          restaurantName,
                                                          0,
                                                          0,
                                                          0,
                                                          '0');
                                                    }
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  iconSize: ScreenUtil()
                                                      .setHeight(20),
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: colorButton,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 40,
                                          width: 65,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey.withAlpha(30)),
                                          child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (singleShopSearchData[
                                                          subMenuIndex]
                                                      .custimization!
                                                      .isNotEmpty) {
                                                    openFoodCustomisationBottomSheet(
                                                      model,
                                                      singleShopModelLib
                                                          .Submenu(
                                                        count:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .count,
                                                        id: singleShopSearchData[
                                                                subMenuIndex]
                                                            .id,
                                                        fullImage:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .fullImage,
                                                        name:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .name,
                                                        type:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .type,
                                                        description:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .description,
                                                        image:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .image,
                                                        isAdded:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .isAdded,
                                                        isRepeatCustomization:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .isRepeatCustomization,
                                                        price:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .price
                                                                .toString(),
                                                        unit:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .unit,
                                                        unitId:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .unitId
                                                                .toString(),
                                                        custimization: singleShopSearchData[
                                                                    subMenuIndex]
                                                                .custimization
                                                            as List<
                                                                singleShopModelLib
                                                                    .Custimization>?,
                                                      ),
                                                      double.parse(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString()),
                                                      totalCartAmount,
                                                      totalQty,
                                                      singleShopSearchData[
                                                              subMenuIndex]
                                                          .custimization!,
                                                    );
                                                  } else {
                                                    if (ScopedModel.of<
                                                                CartModel>(
                                                            context,
                                                            rebuildOnChange:
                                                                true)
                                                        .cart
                                                        .isEmpty) {
                                                      setState(() {
                                                        singleShopSearchData[
                                                                    subMenuIndex]
                                                                .isAdded =
                                                            !singleShopSearchData[
                                                                    subMenuIndex]
                                                                .isAdded!;
                                                        singleShopSearchData[
                                                                subMenuIndex]
                                                            .count++;
                                                      });
                                                      products.add(Product(
                                                        id: singleShopSearchData[
                                                                subMenuIndex]
                                                            .id,
                                                        qty: singleShopSearchData[
                                                                subMenuIndex]
                                                            .count,
                                                        price: double.parse(
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .price
                                                                .toString()),
                                                        imgUrl:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .image,
                                                        type:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .type,
                                                        title:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .name,
                                                        restaurantsId:
                                                            restaurantId,
                                                        restaurantsName:
                                                            restaurantName,
                                                        restaurantImage:
                                                            restaurantImage,
                                                        foodCustomization: '',
                                                        isRepeatCustomization:
                                                            0,
                                                        isCustomization: 0,
                                                        itemQty: 0,
                                                        tempPrice: 0,
                                                        restaurantAddress:
                                                            address,
                                                        restaurantKm: distance,
                                                        restaurantEstimatedTime:
                                                            restaurantEstimatedTime,
                                                      ));
                                                      model.addProduct(Product(
                                                        id: singleShopSearchData[
                                                                subMenuIndex]
                                                            .id,
                                                        qty: singleShopSearchData[
                                                                subMenuIndex]
                                                            .count,
                                                        price: double.parse(
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .price
                                                                .toString()),
                                                        imgUrl:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .image,
                                                        type:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .type,
                                                        title:
                                                            singleShopSearchData[
                                                                    subMenuIndex]
                                                                .name,
                                                        restaurantsId:
                                                            restaurantId,
                                                        restaurantsName:
                                                            restaurantName,
                                                        restaurantImage:
                                                            restaurantImage,
                                                        foodCustomization: '',
                                                        isRepeatCustomization:
                                                            0,
                                                        isCustomization: 0,
                                                        itemQty: 0,
                                                        tempPrice: 0,
                                                        restaurantAddress:
                                                            address,
                                                        restaurantKm: distance,
                                                        restaurantEstimatedTime:
                                                            restaurantEstimatedTime,
                                                      ));
                                                      _insert(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          '0',
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .type,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantId,
                                                          restaurantName,
                                                          restaurantImage,
                                                          '',
                                                          0,
                                                          0,
                                                          0,
                                                          0,
                                                          address,
                                                          distance,
                                                          restaurantEstimatedTime);
                                                    } else {
                                                      print(ScopedModel.of<
                                                                  CartModel>(
                                                              context,
                                                              rebuildOnChange:
                                                                  true)
                                                          .getRestId());
                                                      if (restaurantId !=
                                                          ScopedModel.of<
                                                                      CartModel>(
                                                                  context,
                                                                  rebuildOnChange:
                                                                      true)
                                                              .getRestId()) {
                                                        showDialogRemoveCart(
                                                            ScopedModel.of<
                                                                        CartModel>(
                                                                    context,
                                                                    rebuildOnChange:
                                                                        true)
                                                                .getRestName(),
                                                            restaurantName);
                                                      } else {
                                                        setState(() {
                                                          singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .isAdded =
                                                              !singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .isAdded!;
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count++;
                                                        });
                                                        products.add(Product(
                                                          id: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          qty: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          price: double.parse(
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .price
                                                                  .toString()),
                                                          imgUrl:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .image,
                                                          type: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .type,
                                                          title: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantsId:
                                                              restaurantId,
                                                          restaurantsName:
                                                              restaurantName,
                                                          restaurantImage:
                                                              restaurantImage,
                                                          foodCustomization: '',
                                                          isCustomization: 0,
                                                          isRepeatCustomization:
                                                              0,
                                                          itemQty: 0,
                                                          tempPrice: 0,
                                                          restaurantAddress:
                                                              address,
                                                          restaurantKm:
                                                              distance,
                                                          restaurantEstimatedTime:
                                                              restaurantEstimatedTime,
                                                        ));
                                                        model
                                                            .addProduct(Product(
                                                          id: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          qty: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          price: double.parse(
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .price
                                                                  .toString()),
                                                          imgUrl:
                                                              singleShopSearchData[
                                                                      subMenuIndex]
                                                                  .image,
                                                          type: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .type,
                                                          title: singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantsId:
                                                              restaurantId,
                                                          restaurantsName:
                                                              restaurantName,
                                                          restaurantImage:
                                                              restaurantImage,
                                                          foodCustomization: '',
                                                          isRepeatCustomization:
                                                              0,
                                                          isCustomization: 0,
                                                          itemQty: 0,
                                                          tempPrice: 0,
                                                          restaurantAddress:
                                                              address,
                                                          restaurantKm:
                                                              distance,
                                                          restaurantEstimatedTime:
                                                              restaurantEstimatedTime,
                                                        ));
                                                        _insert(
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .id,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .count,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .price
                                                              .toString(),
                                                          '0',
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .image,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .type,
                                                          singleShopSearchData[
                                                                  subMenuIndex]
                                                              .name,
                                                          restaurantId,
                                                          restaurantName,
                                                          restaurantImage,
                                                          '',
                                                          0,
                                                          0,
                                                          0,
                                                          0,
                                                          address,
                                                          distance,
                                                          restaurantEstimatedTime,
                                                        );
                                                      }
                                                    }
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                Icons.add,
                                                color: colorButton,
                                              )),
                                        ),
                                ),
                              ],
                            ),
                          );
                        })
                    : Center(
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
            },
          );
        },
      );

  void searchWithThrottle(String keyword, {int? throttleTime}) {
    _timer?.cancel();
    if (keyword != previousKeyword && keyword.isNotEmpty) {
      previousKeyword = keyword;
      _timer = Timer.periodic(Duration(seconds: throttleTime ?? 4), (timer) {
        searchedFuture =
            singleShopSearchApi(widget.singleShopId.toString(), keyword);
        _timer!.cancel();
      });
    }
  }

  Future<BaseModel<SingleShopSearchModel>> singleShopSearchApi(
      String shopId, String searchValue) async {
    SingleShopSearchModel response;
    try {
      setState(() {});
      singleShopSearchData.clear();

      Map<String, dynamic> body = {
        'shop_id': shopId,
        'search_value': searchValue,
      };

      response =
          await ApiServices(ApiHeader().dioData()).singleShopSearch(body);

      if (response.success == true) {
        setState(() {
          foundedResult = response.data!.length;
          singleShopSearchData.addAll(response.data!);
        });
      }
      setState(() {});
    } catch (error, stacktrace) {
      setState(() {});
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  //this function only for get data for add some information to cart
  Future<BaseModel<singleShopModelLib.SingleShopModel>>
      singleShopApiOnlyFood() async {
    singleShopModelLib.SingleShopModel response;
    try {
      widget.businessTypeId == 2
          ? response =
              await ApiServices(ApiHeader().dioData()).singleShopApiOnlyFood(
              widget.singleShopId,
              PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
                  .toString(),
              PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
                  .toString(),
              "veg",
            )
          : response = await ApiServices(ApiHeader().dioData()).singleShopApi(
              widget.singleShopId,
              PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
                  .toString(),
              PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
                  .toString(),
            );

      if (response.success == true) {
        setState(() {
          restaurantId = response.data!.id!;
          restaurantName = response.data!.name!;
          restaurantImage = response.data!.fullBannerImage!;
          address = response.data!.location!;
          distance = response.data!.distance.toString();
          restaurantEstimatedTime = response.data!.estimatedTime.toString();
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
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
    setState(() {});
  }

  void updateCustomizationFoodDataToDB(String? customization,
      singleShopModelLib.Submenu item, CartModel model, double cartPrice) {
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

  Future<dynamic> openFoodCustomisationBottomSheet(
    CartModel cartModel,
    singleShopModelLib.Submenu item,
    double currentFoodItemPrice,
    double totalCartAmount,
    int totalQty,
    List<Customization> customization,
  ) {
    double tempPrice = 0;
    List<CustomizationItemModel> _listCustomizationItem = [];
    List<CustomModel> _listFinalCustomization = [];
    List<bool> listFinalCustomizationCheck = [];
    List<int> _radioButtonFlagList = [];
    List<String> _listForAPI = [];
    listFinalCustomizationCheck.clear();

    for (int i = 0; i < customization.length; i++) {
      String? myJSON = customization[i].custimization;
      if (customization[i].custimization != null) {
        listFinalCustomizationCheck.add(true);
      } else {
        listFinalCustomizationCheck.add(false);
      }
      if (customization[i].custimization != null) {
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
                              SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                itemCount: customization.length,
                                shrinkWrap: true,
                                itemBuilder: (context, outerIndex) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            fontSize: 18,
                                          ),
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
                                                                    groldReg,
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
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/no_image.png"),
                                                    Text(
                                                      getTranslated(context,
                                                              noDataDesc)
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${totalQty + 1} ${getTranslated(context, totalItems).toString()}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: groldReg),
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
                                          fontFamily: groldReg),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InkWell(
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
                            child: Row(
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
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.add,
                                  color: colorWhite,
                                  size: 20,
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
            ));
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
                          child: Text(
                            '${getTranslated(context, labelYourCartContainsDishesFrom).toString()} $restName. ${getTranslated(context, labelYourCartContains1).toString()} $currentRestName?',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: TextStyle(
                                fontSize: 14,
                                color: colorBlack),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        SizedBox(
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
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
                                child: GestureDetector(
                                  onTap: () {
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

  void addCustomizationFoodDataToDB(
      String customization,
      singleShopModelLib.Submenu item,
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
      height: 25,
      width: 25,
      decoration: myBoxDecorationChecked(colorUnCheckItem),
    );
  }

  BoxDecoration myBoxDecorationChecked(Color color) {
    return BoxDecoration(
      color: color,
      // border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
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
