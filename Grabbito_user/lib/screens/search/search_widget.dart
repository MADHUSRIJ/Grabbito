import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/search_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/screens/category_details/food/food_shops.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<String> recentSearchData = [];
  List<String> tempRecentData = [];
  List<String> addDataToLocal = [];
  List<Shops> shopSearchesData = [];
  List<Items> itemSearchesData = [];
  int totalSearch = 0;
  int shopSearch = 0;
  int itemSearch = 0;
  bool isSearched = false;
  late Position currentLocation;
  Future<BaseModel<SearchModel>>? searchFuture;

  Timer? _timer;
  String previousKeyword = "";

  @override
  void initState() {
    super.initState();
    if (PreferenceUtils.getStringList(PreferenceNames.recentSearches)
        .isNotEmpty) {
      tempRecentData =
          PreferenceUtils.getStringList(PreferenceNames.recentSearches);
    } else {
      tempRecentData = [];
    }
    recentSearchData = tempRecentData.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 0,
          backgroundColor: colorWhite,
          leading: SizedBox(
            height: 1,
            width: 1,
          ),
          title: SizedBox(
            width: SizeConfig.screenWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth! / 1.1,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        isSearched = true;
                      });
                      if (value.trim().isNotEmpty) {
                        for (int i = 0; i < recentSearchData.length; i++) {
                          addDataToLocal.add(recentSearchData[i]);
                        }
                        if (value.trim().isNotEmpty) {
                          addDataToLocal.add(value);
                        }
                        PreferenceUtils.setStringList(
                            PreferenceNames.recentSearches, addDataToLocal);
                        if (value.isNotEmpty) {
                          previousKeyword = value.substring(value.length - 1);
                          searchWithThrottle(
                              PreferenceUtils.getDouble(
                                      PreferenceNames.latOfSetLocation)
                                  .toString(),
                              PreferenceUtils.getDouble(
                                      PreferenceNames.longOfSetLocation)
                                  .toString(),
                              value,
                              throttleTime: 1);
                        }
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]"))
                    ],
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      color: colorDivider,
                      fontFamily: groldReg,
                      fontSize: 16,
                    ),
                    controller: searchController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: GestureDetector(
                        child: Icon(Icons.search, color: colorDivider),
                        onTap: () {
                          setState(() {
                            isSearched = true;
                            if (PreferenceUtils.getStringList(
                                    PreferenceNames.recentSearches)
                                .isNotEmpty) {
                              tempRecentData = PreferenceUtils.getStringList(
                                  PreferenceNames.recentSearches);
                            } else {
                              tempRecentData = [];
                            }
                            recentSearchData = tempRecentData.reversed.toList();
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
                      hintText: getTranslated(context, searchHint).toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSearched == false
                  ? Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, recentSearch).toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: groldXBold,
                                      fontSize: 16,
                                      color: colorBlack),
                                ),
                                Visibility(
                                  visible: recentSearchData.isNotEmpty,
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          PreferenceUtils.setStringList(
                                              PreferenceNames.recentSearches,
                                              <String>[]);
                                          recentSearchData =
                                              PreferenceUtils.getStringList(
                                                  PreferenceNames.recentSearches);
                                        });
                                      },
                                      child: Text(
                                        getTranslated(context, clearAll)
                                            .toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: groldBold,
                                            fontSize: 14,
                                            color: colorBlue),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          recentSearchData.isNotEmpty
                              ? ListView.builder(
                                  itemCount: 5 <= recentSearchData.length
                                      ? 5
                                      : recentSearchData.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        searchController.text =
                                            recentSearchData[index];
                                        setState(() {
                                          isSearched = true;
                                        });
                                        for (int i = 0;
                                            i < recentSearchData.length;
                                            i++) {
                                          addDataToLocal.add(recentSearchData[i]);
                                        }
                                        if (searchController.text
                                            .trim()
                                            .isNotEmpty) {
                                          addDataToLocal
                                              .add(searchController.text);
                                        }
                                        PreferenceUtils.setStringList(
                                            PreferenceNames.recentSearches,
                                            addDataToLocal);
                                        if (recentSearchData[index].isNotEmpty) {
                                          previousKeyword =
                                              recentSearchData[index].substring(
                                                  recentSearchData[index].length -
                                                      1);
                                          searchWithThrottle(
                                              PreferenceUtils.getDouble(
                                                      PreferenceNames
                                                          .latOfSetLocation)
                                                  .toString(),
                                              PreferenceUtils.getDouble(
                                                      PreferenceNames
                                                          .longOfSetLocation)
                                                  .toString(),
                                              recentSearchData[index],
                                              throttleTime: 1);
                                          setState(() {
                                            isSearched = true;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 0, left: 0, top: 15),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color: colorDivider,
                                            ),
                                            Text(
                                              recentSearchData[index],
                                              style: TextStyle(
                                                  color: colorDivider,
                                                  fontFamily: 'Grold Bold',
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, noRecentSearch)
                                          .toString(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: groldXBold,
                                          fontSize: 16,
                                          color: colorHintText),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              '${getTranslated(context, finedResult).toString()} ($totalSearch)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: groldXBold,
                                  fontSize: 18,
                                  color: colorBlack),
                            ),
                            SizedBox(height: 15),
                            Text(
                              getTranslated(context, searchShop).toString() +
                                  '($shopSearch)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: groldXBold,
                                  fontSize: 18,
                                  color: colorDivider),
                            ),
                            _buildRestaurant(),
                            SizedBox(height: 20),
                            Text(
                              getTranslated(context, searchItem).toString() +
                                  '($itemSearch)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: groldXBold,
                                  fontSize: 18,
                                  color: colorDivider),
                            ),
                            _buildRestaurantItems()
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _buildRestaurant() => FutureBuilder(
        future: searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SpinKitFadingCircle(color: colorRed);
          } else {
            return shopSearchesData.isNotEmpty
                ? GridView.builder(
                    itemCount: shopSearchesData.length,
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 10,
                      mainAxisExtent: ScreenUtil().screenWidth *
                          0.27, // <== change the height to fit your needs
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, foodShopPageRoute,
                              arguments: FoodDeliveryShop(
                                singleShopId:
                                    shopSearchesData[index].id!.toInt(),
                                businessTypeId: shopSearchesData[index]
                                    .bussinessTypeId!
                                    .toInt(),
                              ));
                          // shopSearchesData[index].id);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  alignment: Alignment.center,
                                  fit: BoxFit.fill,
                                  height: 60,
                                  width: 60,
                                  imageUrl: shopSearchesData[index]
                                      .fullImage
                                      .toString(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.4,
                                    // height: ScreenUtil().setHeight(120),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
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
                                      Image.asset("assets/images/no_image.png"),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  child: Column(
                                    // direction: Axis.horizontal,
                                    // runSpacing: 4.0, // gap between lines
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shopSearchesData[index].name.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: groldXBold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(30),
                                        child: Text(
                                          () {
                                            String allMenus = "";
                                            String _temp = "";
                                            if (shopSearchesData[index]
                                                .menu!
                                                .isNotEmpty) {
                                              for (int i = 0;
                                                  i <
                                                      shopSearchesData[index]
                                                          .menu!
                                                          .length;
                                                  i++) {
                                                _temp = shopSearchesData[index]
                                                    .menu![i]
                                                    .name
                                                    .toString();
                                                allMenus =
                                                    allMenus + _temp + ', ';
                                              }
                                              String showMenus =
                                                  allMenus.substring(
                                                      0, allMenus.length - 2);
                                              return showMenus;
                                            } else {
                                              return "";
                                            }
                                          }(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: groldReg,
                                              color: colorDivider),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(16),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.8,
                                        child: Row(
                                          children: [
                                            Text(
                                              shopSearchesData[index]
                                                      .distance
                                                      .toString() +
                                                  " km",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorDividerDark,
                                                fontFamily: groldBold,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              height: 15,
                                              width: 1.5,
                                              color: colorDivider,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              shopSearchesData[index]
                                                      .estimatedTime
                                                      .toString() +
                                                  " Mins",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorDividerDark,
                                                  fontFamily: groldBold),
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
            );
          }
        },
      );

  _buildRestaurantItems() => FutureBuilder(
        future: searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return SpinKitFadingCircle(color: colorRed);
          } else {
            return itemSearchesData.isNotEmpty
                ? GridView.builder(
                    itemCount: itemSearchesData.length,
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 10,
                      mainAxisExtent: ScreenUtil().screenWidth *
                          0.27, // <== change the height to fit your needs
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            foodShopPageRoute,
                            arguments: FoodDeliveryShop(
                              singleShopId:
                                  itemSearchesData[index].shopId!.toInt(),
                              businessTypeId: itemSearchesData[index]
                                  .bussinessTypeId!
                                  .toInt(),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  alignment: Alignment.center,
                                  fit: BoxFit.fill,
                                  height: 60,
                                  width: 60,
                                  imageUrl: itemSearchesData[index]
                                      .fullImage
                                      .toString(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
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
                                      Image.asset("assets/images/no_image.png"),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemSearchesData[index].name.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: groldBold,
                                          color: colorBlack,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(30),
                                        child: Text(
                                          itemSearchesData[index]
                                              .description
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: groldReg,
                                              color: colorDivider),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(15),
                                        child: Row(
                                          children: [
                                            Text(
                                              getTranslated(
                                                      context, searchItemPrice)
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colorBlack,
                                                fontFamily: groldBold,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              itemSearchesData[index]
                                                  .price
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorBlack,
                                                  fontFamily: groldBold),
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
            );
          }
        },
      );

  void searchWithThrottle(String lat, String long, String keyword,
      {int? throttleTime}) {
    _timer?.cancel();
    if (keyword != previousKeyword && keyword.isNotEmpty) {
      previousKeyword = keyword;
      _timer = Timer.periodic(Duration(seconds: throttleTime ?? 4), (timer) {
        searchFuture = searchApi(lat, long, keyword);
        // print("Going to search with keyword : $keyword");
        // print("have ready");
        _timer!.cancel();
      });
    }
  }

  Future<BaseModel<SearchModel>> searchApi(
      String lat, String lang, String item) async {
    SearchModel response;
    try {
      Map<String, dynamic> body = {
        'lat': lat,
        'lang': lang,
        'item': item,
      };

      response = await ApiServices(ApiHeader().dioData()).searchApi(body);

      itemSearchesData.clear();
      shopSearchesData.clear();
      totalSearch = response.data!.items!.length + response.data!.shops!.length;
      shopSearch = response.data!.shops!.length;
      itemSearch = response.data!.items!.length;
      if (response.success == true) {
        if (response.data!.items!.isNotEmpty) {
          itemSearchesData.addAll(response.data!.items!);
        }
        if (response.data!.shops!.isNotEmpty) {
          shopSearchesData.addAll(response.data!.shops!);
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
