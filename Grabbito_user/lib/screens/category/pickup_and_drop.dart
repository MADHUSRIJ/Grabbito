import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/constant/common_validations.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/single_shop_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/cart/payment_method_screen.dart';
import 'package:grabbito/screens/set_location/select_address_from_map.dart';
import 'package:grabbito/utilities/size_config.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';

class PickupAndDrop extends StatefulWidget {
  @override
  _PickupAndDropState createState() => _PickupAndDropState();
}

class _PickupAndDropState extends State<PickupAndDrop> {
  bool _loading = false;
  String imageUrl = '', title = '', slogan = '', pickupPageName = '';
  final _formKey = GlobalKey<FormState>();
  TextEditingController pickupAddressController = TextEditingController();
  TextEditingController deliveryAddressController = TextEditingController();
  TextEditingController deliveryManInstructionController =
      TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController selectedItem = TextEditingController();
  List<Menu> menus = [];
  double pickupLat = 0.0;
  double pickupLong = 0.0;
  double dropLat = 0.0;
  double dropLong = 0.0;
  late int selectedId;
  bool isSelectedId = false;
  Map<String, dynamic> passPaymentData = {};
  double finalTotalAmount = 0.0, finalWeight = 0.0, finalTax = 0.0;
  int finalCategoryId = 0, finalShopId = 0;
  int taxInPercentage = 0;

  @override
  void initState() {
    super.initState();
    pickupAndDropShopApi();
    imageUrl = PreferenceUtils.getString(PreferenceNames.pickupShopBanner);
    title = PreferenceUtils.getString(PreferenceNames.pickupShopTitle);
    slogan = PreferenceUtils.getString(PreferenceNames.pickupShopSlogan);
    pickupPageName = PreferenceUtils.getString(PreferenceNames.pickupShopName);
    if (PreferenceUtils.getString(PreferenceNames.pickupAddress) != 'N/A') {
      pickupAddressController.text =
          PreferenceUtils.getString(PreferenceNames.pickupAddress);
    }
    if (PreferenceUtils.getString(PreferenceNames.dropAddress) != 'N/A') {
      deliveryAddressController.text =
          PreferenceUtils.getString(PreferenceNames.dropAddress);
    }
    pickupLat = PreferenceUtils.getDouble(PreferenceNames.pickupLat);
    pickupLong = PreferenceUtils.getDouble(PreferenceNames.pickupLong);
    dropLat = PreferenceUtils.getDouble(PreferenceNames.dropLat);
    dropLong = PreferenceUtils.getDouble(PreferenceNames.dropLong);
    // print('all data pickup ${pickupAddressController.text} drop ${deliveryAddressController.text} plat $pickupLat plong $pickupLong dlat $dropLat dlong $dropLong');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 1.0,
      color: Colors.transparent.withOpacity(0.2),
      progressIndicator: SpinKitFadingCircle(color: colorRed),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      imageUrl != ""
                          ? Container(
                              width: SizeConfig.screenWidth,
                              color: Colors.white,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                                imageUrl: imageUrl,
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(color: colorRed),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/no_image.png"),
                              ),
                            )
                          : SizedBox(
                              height: 1,
                              width: 1,
                            ),
                      Positioned(
                        left: 20,
                        top: 100,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: groldThin,
                              color: colorWhite,
                              fontSize: 40,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 30,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            slogan,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: groldReg,
                                color: colorWhite,
                                fontSize: 12,
                                letterSpacing: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                pickupPageName,
                style: TextStyle(
                    fontFamily: groldBold,
                    color: colorWhite,
                    fontSize: 18),
              ),
              expandedHeight: 220,
              collapsedHeight: kToolbarHeight,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildRestaurant(context);
                },
                addSemanticIndexes: true,
                childCount: 1, // 1000 list items
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildRestaurant(BuildContext context) => Container(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: colorButton)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, pickupAddressText).toString(),
                      style:
                          TextStyle(fontFamily: groldReg, fontSize: 14),
                    ),
                    TextFormField(
                      controller: pickupAddressController,
                      readOnly: true,
                      onTap: () {
                        PreferenceUtils.setString(
                            PreferenceNames.checkManageLocationPath,
                            "fromPickup");
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectMapAddress()));
                        // Navigator.pushNamed(context, setLocationRoute);
                      },
                      maxLines: 2,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ValidationConstants.kValidatePickup,
                      style:
                          TextStyle(fontFamily: groldXBold, fontSize: 16),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            getTranslated(context, tapToSelectPickupAddress)
                                .toString(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: colorButton)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, deliveryAddressText).toString(),
                      style:
                          TextStyle(fontFamily: groldReg, fontSize: 14),
                    ),
                    TextFormField(
                      controller: deliveryAddressController,
                      onTap: () {
                        PreferenceUtils.setString(
                            PreferenceNames.checkManageLocationPath,
                            "fromDrop");
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectMapAddress()));
                        // Navigator.pushNamed(context, setLocationRoute);
                      },
                      readOnly: true,
                      maxLines: 2,
                      validator: ValidationConstants.kValidateDrop,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style:
                          TextStyle(fontFamily: groldXBold, fontSize: 16),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              getTranslated(context, tapToSelectDeliveryAddress)
                                  .toString(),
                          suffixIcon: Icon(Icons.search)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 0.5, color: colorButton),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, pickupContentText).toString(),
                        style:
                            TextStyle(fontFamily: groldReg, fontSize: 14),
                      ),
                      TextFormField(
                        controller: selectedItem,
                        enabled: false,
                        style: TextStyle(
                            fontFamily: groldXBold, fontSize: 16),
                        keyboardType: TextInputType.text,
                        autovalidateMode: AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              getTranslated(context, selectPickupContentText)
                                  .toString(),
                          suffixIcon: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showModalBottomSheets(context);
                },
              ),
              Container(
                margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: colorButton)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${getTranslated(context, packageWeightText).toString()} (kg)",
                      style:
                          TextStyle(fontFamily: groldReg, fontSize: 14),
                    ),
                    TextFormField(
                      controller: weightController,
                      maxLines: 1,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ValidationConstants.kValidateWeight,
                      style:
                          TextStyle(fontFamily: groldXBold, fontSize: 16),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: getTranslated(context, weightOfPackageText)
                            .toString(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 20, left: 20, top: 20),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 0.5, color: colorButton)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, instructionsForDeliveryman)
                          .toString(),
                      style:
                          TextStyle(fontFamily: groldReg, fontSize: 14),
                    ),
                    TextFormField(
                      controller: deliveryManInstructionController,
                      maxLines: 2,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style:
                          TextStyle(fontFamily: groldXBold, fontSize: 16),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            getTranslated(context, instructionsForDeliveryman)
                                .toString(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 15,
                ),
                child: Text(
                  '${getTranslated(context, pickupScreenDesc).toString()} $appName ${getTranslated(context, pickupScreenDesc2).toString()}',
                  style: TextStyle(
                      color: colorDivider,
                      fontFamily: groldReg,
                      fontSize: 11),
                ),
              ),
              SizedBox(height: 5),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.030),
                child: MaterialButton(
                  height: 45,
                  minWidth: SizeConfig.screenWidth! / 1.2,
                  color: colorButton,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    getTranslated(context, confirmOrder).toString(),
                    style: TextStyle(fontFamily: groldBold, fontSize: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isSelectedId) {
                        if (PreferenceUtils.getBool(
                                PreferenceNames.checkLogin) ==
                            true) {
                          setState(() {
                            _loading = true;
                          });
                          //for totalamount
                          ///distance wise set amount
                          if (PreferenceUtils.getString(
                                  PreferenceNames.amountBaseOnSetting) ==
                              "distance") {
                            List<ChargesModel> decodeAmount = [];
                            String localAmountArray = PreferenceUtils.getString(
                                PreferenceNames.amountSetting);
                            var deliveryCharge = json.decode(localAmountArray);
                            decodeAmount = (deliveryCharge as List)
                                .map((i) => ChargesModel.fromJson(i))
                                .toList();

                            double totalDistance = calculateDistance(
                                pickupLat, pickupLong, dropLat, dropLong);

                            String strFinalDeliveryCharge1 = '';
                            for (int i = 0; i < decodeAmount.length; i++) {
                              if (totalDistance >=
                                      double.parse(decodeAmount[i].minValue!) &&
                                  totalDistance <=
                                      double.parse(decodeAmount[i].maxValue!)) {
                                strFinalDeliveryCharge1 =
                                    decodeAmount[i].charges!;
                                break;
                              }
                            }
                            if (strFinalDeliveryCharge1 == '') {
                              var max = decodeAmount.reduce((current, next) =>
                                  int.parse(current.charges!) >
                                          int.parse(next.charges!)
                                      ? current
                                      : next);
                              finalTotalAmount =
                                  double.parse(max.charges!.toString());
                            } else if (totalDistance < 1) {
                              finalTotalAmount = 0.0;
                            } else {
                              finalTotalAmount =
                                  double.parse(strFinalDeliveryCharge1);
                            }
                          }

                          ///weight wise set amount
                          else {
                            List<ChargesModel> decodeAmount = [];
                            String localAmountArray = PreferenceUtils.getString(
                                PreferenceNames.amountSetting);
                            var deliveryCharge = json.decode(localAmountArray);
                            decodeAmount = (deliveryCharge as List)
                                .map((i) => ChargesModel.fromJson(i))
                                .toList();

                            double tempWeight =
                                double.parse(weightController.text);

                            String strFinalDeliveryCharge1 = '';
                            for (int i = 0; i < decodeAmount.length; i++) {
                              if (tempWeight >=
                                      double.parse(decodeAmount[i].minValue!) &&
                                  tempWeight <=
                                      double.parse(decodeAmount[i].maxValue!)) {
                                strFinalDeliveryCharge1 =
                                    decodeAmount[i].charges!;
                                break;
                              }
                            }
                            if (strFinalDeliveryCharge1 == '') {
                              var max = decodeAmount.reduce((current, next) =>
                                  int.parse(current.charges!) >
                                          int.parse(next.charges!)
                                      ? current
                                      : next);
                              finalTotalAmount =
                                  double.parse(max.charges!.toString());
                            } else if (tempWeight < 1) {
                              finalTotalAmount = 0.0;
                            } else {
                              finalTotalAmount =
                                  double.parse(strFinalDeliveryCharge1);
                            }
                          }

                          finalTax = finalTotalAmount * taxInPercentage / 100;
                          finalShopId = PreferenceUtils.getInt(
                              PreferenceNames.pickupShopId);
                          finalWeight = double.parse(weightController.text);
                          passPaymentData = {
                            "amount": finalTotalAmount,
                            "category_id": finalCategoryId,
                            "weight": finalWeight,
                            "shop_id": finalShopId,
                            "tax": finalTax,
                            "pickup_location": pickupAddressController.text,
                            "pick_lat": pickupLat,
                            "pick_lang": pickupLong,
                            "dropup_location": deliveryAddressController.text,
                            "drop_lat": dropLat,
                            "drop_lang": dropLong,
                            "note": deliveryManInstructionController.text,
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(
                                fromWhere: "fromPickup",
                                paymentData: passPaymentData,
                              ),
                            ),
                          );
                          setState(() {
                            _loading = false;
                          });
                        } else {
                          CommonFunction.toastMessage(
                              getTranslated(context, pleaseLogin).toString());
                        }
                      } else {
                        CommonFunction.toastMessage(
                            getTranslated(context, providePackageContent)
                                .toString());
                      }
                    }
                  },
                  splashColor: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      );

  Future<dynamic> showModalBottomSheets(BuildContext context) {
    int? value;
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, myState) => Container(
              margin: EdgeInsets.all(20),
              height: SizeConfig.screenHeight,
              child: ListView(
                children: [
                  Wrap(
                    children: [
                      Text(
                        getTranslated(context, selectPickupContentText)
                            .toString(),
                        style: TextStyle(
                            fontFamily: groldXBold,
                            color: colorBlack,
                            fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        itemCount: menus.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          return RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: index,
                            groupValue: value,
                            activeColor: colorPrimary,
                            onChanged: (dynamic val) {
                              myState(() {
                                value = val;
                                selectedId = val;
                              });
                            },
                            title: Text(
                              menus[index].name.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: groldReg,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              height: 45,
                              minWidth: SizeConfig.screenWidth! * 0.3,
                              color: colorDivider,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                getTranslated(context, cancel).toString(),
                                style: TextStyle(
                                    fontFamily: groldBold, fontSize: 16),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              splashColor: Colors.redAccent,
                            ),
                            MaterialButton(
                              height: 45,
                              minWidth: SizeConfig.screenWidth! * 0.3,
                              color: colorButton,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                getTranslated(context, addButtonText)
                                    .toString(),
                                style: TextStyle(
                                    fontFamily: groldBold, fontSize: 16),
                              ),
                              onPressed: () {
                                finalCategoryId = menus[selectedId].id!.toInt();
                                selectedItem.text =
                                    menus[selectedId].name.toString();
                                isSelectedId = true;
                                Navigator.pop(context);
                              },
                              splashColor: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<BaseModel<SingleShopModel>> pickupAndDropShopApi() async {
    SingleShopModel response;
    try {
      setState(() {
        _loading = true;
      });
      int passShopId = PreferenceUtils.getInt(PreferenceNames.pickupShopId);
      response = await ApiServices(ApiHeader().dioData()).singleShopApi(
          passShopId,
          PreferenceUtils.getDouble(PreferenceNames.latOfSetLocation)
              .toString(),
          PreferenceUtils.getDouble(PreferenceNames.longOfSetLocation)
              .toString());

      if (response.success == true) {
        if (response.data!.menu!.isNotEmpty) {
          menus.addAll(response.data!.menu!);
        }
        taxInPercentage = int.parse(response.data!.tax!);
      } else {}
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
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
