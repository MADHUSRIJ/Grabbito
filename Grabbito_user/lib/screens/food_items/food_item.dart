import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/screens/common/widget_no_internet.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:iconly/iconly.dart';
import 'package:scoped_model/scoped_model.dart';

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

  double totalCartAmount = 0;
  int totalQty = 0;
  List<Product> products = [];
  List<Product> listCart = [];
  Future<BaseModel<SingleShopModel>>? menuFuture;

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
      body: SizedBox(
        child: isNetworkAvailable == true
            ? SizedBox(
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenHeight,
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Column(
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
                                  padding: EdgeInsets.only(
                                      top: (widget.item.fullImage ==
                                              "https://grabbito.com/public/images/upload/prod_default.png")
                                          ? 0
                                          : 20),
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
                          widget.item.custimization!.isNotEmpty
                              ? SizedBox(
                                  height:
                                      widget.item.custimization!.length * 200,
                                  child: ListView.builder(
                                    itemCount:
                                        widget.item.custimization!.length,
                                    itemBuilder: (context, index) {
                                      String myJSON = widget.item
                                          .custimization![index].custimization!;
                                      var json = jsonDecode(myJSON);
                                      List<CustomizationItemModel>
                                          listCustomizationItem = (json as List)
                                              .map((i) => CustomizationItemModel
                                                  .fromJson(i))
                                              .toList();
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 20,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                widget.item
                                                    .custimization![index].name
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: groldReg,
                                                    fontWeight: FontWeight.w400,
                                                    color: colorBlack,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            widget.item.custimization![index]
                                                        .name ==
                                                    "Extras"
                                                ? Container(
                                                    height: 16,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: const [
                                                        Text(
                                                          "Optional",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  groldReg,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  colorOrange,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          " • Select upto 3",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  groldReg,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  colorDividerDark,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    height: 16,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: const [
                                                        Text(
                                                          "Required",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  groldReg,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  colorOrange,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          " • Select 1",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  groldReg,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  colorDividerDark,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            SizedBox(
                                              height:
                                                  listCustomizationItem.length *
                                                      30,
                                              child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(
                                                            height: 16,
                                                          ),
                                                  itemCount:
                                                      listCustomizationItem
                                                          .length,
                                                  itemBuilder:
                                                      (context, cusindex) {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            listCustomizationItem[
                                                                    cusindex]
                                                                .name
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    groldReg,
                                                                fontWeight:
                                                                    FontWeight.w400,
                                                                color: colorBlack,
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                        listCustomizationItem[
                                                        cusindex]
                                                            .price.toString() == "0" ? "" :"+RS "+listCustomizationItem[
                                                            cusindex]
                                                                .price
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                groldReg,
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                color: colorBlack,
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : NoInternetWidget(),
      ),
      bottomNavigationBar: Container(
        height: 83,
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1, color: Color(0xffF6F6F6))),
          color: colorWhite,
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Container(
              height: 48,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorWhite,
                border: Border.all(width: 1, color: Color(0xffF6F6F6)),
                borderRadius: BorderRadius.circular(50),
              ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        "-",
                        style: TextStyle(
                            fontFamily: groldReg,
                            fontWeight: FontWeight.w400,
                            color: colorDivider,
                            fontSize: 20),
                      ),
                      Text(
                        "1",
                        style: TextStyle(
                            fontFamily: groldReg,
                            fontWeight: FontWeight.w400,
                            color: colorBlack,
                            fontSize: 20),
                      ),
                      Text(
                        "+",
                        style: TextStyle(
                            fontFamily: groldReg,
                            fontWeight: FontWeight.w400,
                            color: colorBlack,
                            fontSize: 20),
                      ),
                    ],
                  ),
            )),
            Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorOrange,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Add Rs " + "200",
                    style: TextStyle(
                        fontFamily: groldReg,
                        fontWeight: FontWeight.w400,
                        color: colorWhite,
                        fontSize: 20),
                  ),
                ))
          ],
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

  // Future<dynamic> openFoodCustomisationBottomSheet(
  //   CartModel cartModel,
  //   Submenu item,
  //   double currentFoodItemPrice,
  //   double totalCartAmount,
  //   int totalQty,
  //   List<Custimization> customization,
  // ) {
  //   double tempPrice = 0;
  //   List<CustomizationItemModel> _listCustomizationItem = [];
  //   List<CustomModel> _listFinalCustomization = [];
  //   List<int> _radioButtonFlagList = [];
  //   List<String> _listForAPI = [];
  //  //listFinalCustomizationCheck.clear();
  //
  //   for (int i = 0; i < customization.length; i++) {
  //     String? myJSON = customization[i].custimization;
  //     if (customization[i].custimization != null &&
  //         customization[i].custimization != "") {
  //       _listFinalCustomizationCheck.add(true);
  //     } else {
  //       widget.listFinalCustomizationCheck.add(false);
  //     }
  //     if (customization[i].custimization != null &&
  //         customization[i].custimization != "") {
  //       var json = jsonDecode(myJSON!);
  //
  //       _listCustomizationItem = (json as List)
  //           .map((i) => CustomizationItemModel.fromJson(i))
  //           .toList();
  //
  //       for (int j = 0; j < _listCustomizationItem.length; j++) {
  //         print(_listCustomizationItem[j].name);
  //       }
  //
  //       _listFinalCustomization
  //           .add(CustomModel(customization[i].name, _listCustomizationItem));
  //
  //       for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
  //         if (_listFinalCustomization[i].list[k].isDefault == 1) {
  //           _listFinalCustomization[i].list[k].isSelected = true;
  //           _radioButtonFlagList.add(k);
  //           tempPrice +=
  //               double.parse(_listFinalCustomization[i].list[k].price!);
  //           _listForAPI.add(
  //               '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
  //         } else {
  //           _listFinalCustomization[i].list[k].isSelected = false;
  //         }
  //       }
  //       print(_listFinalCustomization.length);
  //       print('temp ' + tempPrice.toString());
  //     } else {
  //       _listFinalCustomization
  //           .add(CustomModel(customization[i].name, _listCustomizationItem));
  //       continue;
  //     }
  //   }
  //
  //   return showModalBottomSheet(
  //       isDismissible: true,
  //       context: context,
  //       builder: (context) => StatefulBuilder(
  //             builder: (context, bottomSheetSetState) {
  //               return SafeArea(
  //                 child: Scaffold(
  //                   body: SizedBox(
  //                     height: SizeConfig.screenHeight,
  //                     child: ListView(
  //                       children: [
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Container(
  //                               margin: EdgeInsets.all(15),
  //                               child: Text(
  //                                 getTranslated(context, customizationAndMore)
  //                                     .toString(),
  //                                 style: TextStyle(
  //                                     fontFamily: groldXBold,
  //                                     color: colorBlack,
  //                                     fontSize: 18),
  //                               ),
  //                             ),
  //                             ListView.separated(
  //                               physics: ClampingScrollPhysics(),
  //                               itemCount: customization.length,
  //                               shrinkWrap: true,
  //                               separatorBuilder: (context, index) => SizedBox(
  //                                 height: 20,
  //                               ),
  //                               itemBuilder: (context, outerIndex) {
  //                                 return Column(
  //                                   mainAxisAlignment: MainAxisAlignment.start,
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.stretch,
  //                                   children: [
  //                                     Container(
  //                                       margin: EdgeInsets.only(
  //                                           left: 20, bottom: 10.0),
  //                                       child: Text(
  //                                         _listFinalCustomization[outerIndex]
  //                                             .title
  //                                             .toString(),
  //                                         style: TextStyle(
  //                                             fontFamily: groldXBold,
  //                                             color: colorBlack,
  //                                             fontSize: 18),
  //                                       ),
  //                                     ),
  //                                     _listFinalCustomization[outerIndex]
  //                                             .list
  //                                             .isNotEmpty
  //                                         ? widget.listFinalCustomizationCheck[
  //                                                     outerIndex] ==
  //                                                 true
  //                                             ? ListView.separated(
  //                                                 physics:
  //                                                     NeverScrollableScrollPhysics(),
  //                                                 padding: EdgeInsets.symmetric(
  //                                                     horizontal: 20),
  //                                                 shrinkWrap: true,
  //                                                 itemCount:
  //                                                     _listFinalCustomization[
  //                                                             outerIndex]
  //                                                         .list
  //                                                         .length,
  //                                                 separatorBuilder: (context,
  //                                                         index) =>
  //                                                     SizedBox(height: 10.0),
  //                                                 itemBuilder:
  //                                                     (context, innerIndex) {
  //                                                   return InkWell(
  //                                                     onTap: () {
  //                                                       if (!_listFinalCustomization[
  //                                                               outerIndex]
  //                                                           .list[innerIndex]
  //                                                           .isSelected!) {
  //                                                         tempPrice = 0;
  //                                                         _listForAPI.clear();
  //                                                         bottomSheetSetState(
  //                                                             () {
  //                                                           _radioButtonFlagList[
  //                                                                   outerIndex] =
  //                                                               innerIndex;
  //
  //                                                           for (var element
  //                                                               in _listFinalCustomization[
  //                                                                       outerIndex]
  //                                                                   .list) {
  //                                                             element.isSelected =
  //                                                                 false;
  //                                                           }
  //                                                           _listFinalCustomization[
  //                                                                   outerIndex]
  //                                                               .list[
  //                                                                   innerIndex]
  //                                                               .isSelected = true;
  //
  //                                                           for (int i = 0;
  //                                                               i <
  //                                                                   _listFinalCustomization
  //                                                                       .length;
  //                                                               i++) {
  //                                                             for (int j = 0;
  //                                                                 j <
  //                                                                     _listFinalCustomization[
  //                                                                             i]
  //                                                                         .list
  //                                                                         .length;
  //                                                                 j++) {
  //                                                               if (_listFinalCustomization[
  //                                                                       i]
  //                                                                   .list[j]
  //                                                                   .isSelected!) {
  //                                                                 tempPrice += double.parse(
  //                                                                     _listFinalCustomization[
  //                                                                             i]
  //                                                                         .list[
  //                                                                             j]
  //                                                                         .price!);
  //
  //                                                                 print(_listFinalCustomization[
  //                                                                         i]
  //                                                                     .title);
  //                                                                 print(
  //                                                                     _listFinalCustomization[
  //                                                                             i]
  //                                                                         .list[
  //                                                                             j]
  //                                                                         .name);
  //                                                                 print(_listFinalCustomization[
  //                                                                         i]
  //                                                                     .list[j]
  //                                                                     .isDefault);
  //                                                                 print(_listFinalCustomization[
  //                                                                         i]
  //                                                                     .list[j]
  //                                                                     .isSelected);
  //                                                                 print(_listFinalCustomization[
  //                                                                         i]
  //                                                                     .list[j]
  //                                                                     .price);
  //
  //                                                                 _listForAPI.add(
  //                                                                     '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
  //                                                                 print(_listForAPI
  //                                                                     .toString());
  //                                                               }
  //                                                             }
  //                                                           }
  //                                                         });
  //                                                       }
  //                                                     },
  //                                                     child: Container(
  //                                                       padding:
  //                                                           EdgeInsets.all(5),
  //                                                       child: Row(
  //                                                         mainAxisAlignment:
  //                                                             MainAxisAlignment
  //                                                                 .spaceBetween,
  //                                                         children: [
  //                                                           Row(
  //                                                             crossAxisAlignment:
  //                                                                 CrossAxisAlignment
  //                                                                     .center,
  //                                                             children: [
  //                                                               _radioButtonFlagList[
  //                                                                           outerIndex] ==
  //                                                                       innerIndex
  //                                                                   ? getChecked()
  //                                                                   : getUnChecked(),
  //                                                               SizedBox(
  //                                                                   width: 5),
  //                                                               Text(
  //                                                                 _listFinalCustomization[
  //                                                                         outerIndex]
  //                                                                     .list[
  //                                                                         innerIndex]
  //                                                                     .name
  //                                                                     .toString(),
  //                                                                 style:
  //                                                                     TextStyle(
  //                                                                   fontSize:
  //                                                                       16,
  //                                                                   fontFamily:
  //                                                                       groldReg,
  //                                                                 ),
  //                                                               ),
  //                                                             ],
  //                                                           ),
  //                                                           Text(
  //                                                             '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${_listFinalCustomization[outerIndex].list[innerIndex].price.toString()}',
  //                                                             style: TextStyle(
  //                                                               fontFamily:
  //                                                                   groldBold,
  //                                                               color:
  //                                                                   colorBlack,
  //                                                               fontSize: 16,
  //                                                             ),
  //                                                           ),
  //                                                         ],
  //                                                       ),
  //                                                     ),
  //                                                   );
  //                                                 },
  //                                               )
  //                                             : Center(
  //                                                 child: Column(
  //                                                   crossAxisAlignment:
  //                                                       CrossAxisAlignment
  //                                                           .stretch,
  //                                                   mainAxisAlignment:
  //                                                       MainAxisAlignment
  //                                                           .center,
  //                                                   children: [
  //                                                     Image.asset(
  //                                                         "assets/images/no_image.png"),
  //                                                     Text(
  //                                                       getTranslated(context,
  //                                                               noDataDesc)
  //                                                           .toString(),
  //                                                       textAlign:
  //                                                           TextAlign.center,
  //                                                       overflow: TextOverflow
  //                                                           .ellipsis,
  //                                                       maxLines: 1,
  //                                                       style: TextStyle(
  //                                                         fontSize: 20,
  //                                                         fontFamily: groldReg,
  //                                                         color: colorBlack,
  //                                                       ),
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               )
  //                                         : Center(
  //                                             child: Column(
  //                                               crossAxisAlignment:
  //                                                   CrossAxisAlignment.stretch,
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment.center,
  //                                               children: [
  //                                                 Image.asset(
  //                                                     "assets/images/no_image.png"),
  //                                                 Text(
  //                                                   getTranslated(
  //                                                           context, noDataDesc)
  //                                                       .toString(),
  //                                                   textAlign: TextAlign.center,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   maxLines: 1,
  //                                                   style: TextStyle(
  //                                                     fontSize: 20,
  //                                                     fontFamily: groldReg,
  //                                                     color: colorBlack,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                   ],
  //                                 );
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   bottomNavigationBar: GestureDetector(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                       print(
  //                           '===================Continue with List Data=================');
  //                       print(_listForAPI.toString());
  //                       addCustomizationFoodDataToDB(
  //                           _listForAPI.toString(),
  //                           item,
  //                           cartModel,
  //                           currentFoodItemPrice + tempPrice,
  //                           currentFoodItemPrice,
  //                           false,
  //                           0,
  //                           0);
  //                     },
  //                     child: Container(
  //                       height: 60,
  //                       width: SizeConfig.screenWidth,
  //                       color: colorGreen,
  //                       padding: EdgeInsets.only(
  //                         left: 20,
  //                         right: 20,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           SizedBox(
  //                             width: SizeConfig.screenWidth! / 1.7,
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Row(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: [
  //                                     Text(
  //                                       '${totalQty + 1} ${getTranslated(context, totalItems).toString()}',
  //                                       style: TextStyle(
  //                                           fontSize: 18,
  //                                           color: Colors.white,
  //                                           fontFamily: groldBold),
  //                                     ),
  //                                     SizedBox(
  //                                       width: 10,
  //                                     ),
  //                                     VerticalDivider(
  //                                       thickness: 2,
  //                                       width: 2,
  //                                       color: colorWhite,
  //                                     ),
  //                                     SizedBox(
  //                                       width: 10,
  //                                     ),
  //                                     Text(
  //                                       '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} ${currentFoodItemPrice + tempPrice}',
  //                                       style: TextStyle(
  //                                           fontSize: 18,
  //                                           color: Colors.white,
  //                                           fontFamily: groldBold),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 getTranslated(context, addItemText)
  //                                     .toString(),
  //                                 style: TextStyle(
  //                                   fontSize: 18,
  //                                   color: Colors.white,
  //                                   fontFamily: groldReg,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 5),
  //                               Icon(
  //                                 Icons.add,
  //                                 color: colorWhite,
  //                                 size: 20,
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ));
  // }

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
      height: 25,
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
