import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grabbito/screens/settings/settings_screen.dart';
import 'package:iconly/iconly.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/book_order_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/cart/track_order_screen.dart';
import 'package:grabbito/screens/home/comp/home_widget.dart';
import 'package:grabbito/screens/offers/offers_widget.dart';
import 'package:grabbito/screens/profile/profile_widget.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class HomeScreen extends StatefulWidget {
  final int passToCurrentIndex;
  HomeScreen(this.passToCurrentIndex);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> _backStack = [0];
  int _currentIndex = 0;
  bool isOrdered = false;
  late BookOrderData currentOrderData;
  late Package currentOrderPackage;
  DateTime currentBackPressTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    CommonFunction.checkForPermission();
    _currentIndex = widget.passToCurrentIndex;
    if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == true) {
      liveOrderTrack();
    }
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
    SizeConfig().init(context);
    navigateTo(_currentIndex);
    List<Widget> _fragments = [
      MainPage(
        isTrackOrderPadding: isOrdered,
      ),
      OffersPage(),
      ProfilePage(),
      SettingsScreen(),
    ];
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
      child: WillPopScope(
        onWillPop: customPop,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                child: _fragments[_currentIndex],
              ),
              isOrdered == true &&
                      _currentIndex == 0 &&
                      PreferenceUtils.getString(
                              PreferenceNames.addressOfSetLocation) !=
                          'N/A'
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        height: ScreenUtil().setHeight(70),
                        width: SizeConfig.screenWidth,
                        color: Color(0xFF203049).withOpacity(0.5),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: ScreenUtil().setHeight(56),
                                        width: ScreenUtil().setWidth(95),
                                        child: Card(
                                            margin: EdgeInsets.zero,
                                            elevation: 5,
                                            child: CircleAvatar(
                                              backgroundColor: colorOrange,
                                              radius: 16.0,
                                              child: Icon(
                                                IconlyBold.home,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)))),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(10)),
                                        child: Text(
                                          "${getTranslated(context, orderIsText).toString()}${currentOrderData.orderStatus}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: colorWhite,
                                              fontSize: 13,
                                              fontFamily: groldBold),
                                        ),
                                      )
                                    ],
                                  ),
                                  CircleAvatar(
                                    backgroundColor: colorWhite,
                                    radius: 25,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color: colorBlue,
                                      ),
                                      onPressed: () {
                                        if (currentOrderPackage.id != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TrackOrderScreen(
                                                bookOrderPassingDataPickup:
                                                    currentOrderPackage,
                                                bookOrderPassingData:
                                                    currentOrderData,
                                                whichOrder: "pickupOrder",
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TrackOrderScreen(
                                                bookOrderPassingData:
                                                    currentOrderData,
                                                whichOrder: "regularOrder",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
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
          bottomNavigationBar: BottomAppBar(
            elevation: 10,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          _currentIndex = 0;
                          navigateTo(_currentIndex);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            _currentIndex == 0
                                ? CircleAvatar(
                                    backgroundColor: colorOrange,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyBold.home,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyLight.home,
                                      color: colorWidgetBg,
                                      size: 25.0,
                                    ),
                                  ),
                            SizedBox(
                              height: 2,
                            ),
                            _currentIndex == 0
                                ? Text("Home",
                                    style: TextStyle(
                                        fontFamily: groldReg,
                                        color: colorOrange,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14))
                                : Text("Home",
                                    style: TextStyle(
                                        fontFamily: groldReg,
                                        color: colorWidgetBg,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          _currentIndex = 1;
                          navigateTo(_currentIndex);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            _currentIndex == 1
                                ? CircleAvatar(
                                    backgroundColor: colorOrange,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyBold.discount,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyLight.discount,
                                      color: colorWidgetBg,
                                      size: 25.0,
                                    ),
                                  ),
                            SizedBox(
                              height: 2,
                            ),
                            _currentIndex == 1
                                ? Text("Promo",
                                style: TextStyle(
                                    fontFamily: groldReg,
                                    color: colorOrange,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                                : Text("Promo",
                                style: TextStyle(
                                    fontFamily: groldReg,
                                    color: colorWidgetBg,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          _currentIndex = 2;
                          navigateTo(_currentIndex);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            _currentIndex == 2
                                ? CircleAvatar(
                              backgroundColor: colorOrange,
                              radius: 16.0,
                              child: Icon(
                                IconlyLight.document,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            )
                                : CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 16.0,
                              child: Icon(
                                IconlyLight.document,
                                color: colorWidgetBg,
                                size: 25.0,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            _currentIndex == 2
                                ? Text("Orders",
                                style: TextStyle(
                                    fontFamily: groldReg,
                                    color: colorOrange,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                                : Text("Orders",
                                style: TextStyle(
                                    fontFamily: groldReg,
                                    color: colorWidgetBg,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          _currentIndex = 3;
                          navigateTo(_currentIndex);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            _currentIndex == 3
                                ? CircleAvatar(
                                    backgroundColor: colorOrange,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyBold.profile,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 16.0,
                                    child: Icon(
                                      IconlyLight.profile,
                                      color: colorWidgetBg,
                                      size: 25.0,
                                    ),
                                  ),
                            SizedBox(
                              height: 2,
                            ),
                            _currentIndex == 3
                                ? Text("Me",
                                style: TextStyle(
                                    fontFamily: groldReg,
                                    color: colorOrange,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                                : Text("Me",
                                style: TextStyle(
                                  fontFamily: groldReg,
                                    color: colorWidgetBg,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateTo(int index) {
    if (index == 1) {
      if (PreferenceUtils.getBool(PreferenceNames.checkLogin) == false) {
        CommonFunction.toastMessage(
            getTranslated(context, loginPlease).toString());
      } else {
        _backStack.add(index);
        setState(() {
          _currentIndex = index;
        });
      }
    } else {
      _backStack.add(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<bool> customPop() {
    if (_currentIndex == 0) {
      DateTime now = DateTime.now();
      if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(
          msg: getTranslated(context, pressExit).toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return Future.value(false);
      }
      return Future.value(true);
    } else {
      navigateTo(0);
      return Future.value(false);
    }
  }

  Future<BaseModel<BookOrderModel>> liveOrderTrack() async {
    BookOrderModel response;
    try {
      response = await ApiServices(ApiHeader().dioData()).trackLiveOrder();
      if (response.success == true && response.data!.id != null ||
          response.package!.id != null) {
        setState(() {
          isOrdered = true;
          currentOrderData = response.data!;
          currentOrderPackage = response.package!;
          // print(currentOrderData.orderStatus! + 'new');
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
