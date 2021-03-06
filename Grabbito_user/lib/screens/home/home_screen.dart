import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const HomeScreen(this.passToCurrentIndex);
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                        child: GestureDetector(
                          onTap: () {
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: colorOrange
                            ),
                            height: 60,
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width - 30,
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 180,
                                      width: 95,
                                      child: Icon(
                                        IconlyBold.bag_2,
                                        color: colorWhite,
                                        size: 25.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 10),
                                      child: Text(
                                        "${getTranslated(context, orderIsText).toString()}${currentOrderData.orderStatus}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: colorWhite,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: groldReg),
                                      ),
                                    )
                                  ],
                                ),
                                Icon(
                                  Icons.track_changes,
                                  color: colorWhite,
                                  size: 25,
                                )
                              ],
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
