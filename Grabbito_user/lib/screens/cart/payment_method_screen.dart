import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconly/iconly.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/book_order_model.dart';
import 'package:grabbito/model/booking_order_for_package.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/cart/stripe_payment.dart';
import 'package:grabbito/screens/cart/track_order_screen.dart';
import 'package:grabbito/screens/cart/track_order_screen_for_pickup.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String fromWhere;
  final Map<String, dynamic> paymentData;
  const PaymentMethodScreen({
    required this.fromWhere,
    required this.paymentData,
  });
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final dbHelper = DatabaseHelper.instance;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int? value;
  bool paypal = false;
  bool razorPay = false;
  bool stripe = false;
  bool cod = false;
  bool _loading = false;
  String fromWhere = '';
  late Razorpay _razorpay;
  String razorPayKey = PreferenceUtils.getString(PreferenceNames.razorPayKey);
  String userContactNumber =
          PreferenceUtils.getString(PreferenceNames.loggedInUserPhoneNumber),
      userName = PreferenceUtils.getString(PreferenceNames.loggedInUserName),
      userEmail =
          PreferenceUtils.getString(PreferenceNames.loggedInUserEmailId);

  //for payment data
  late Map<String, dynamic> paymentData;
  String payableAmount = "";
  @override
  void initState() {
    super.initState();
    fromWhere = widget.fromWhere;
    paymentData = widget.paymentData;
    payableAmount = paymentData["amount"].toString();
    //set all keys
    String p = PreferenceUtils.getString(PreferenceNames.paypalAvailable.toString());
    if( p == "1"){
      paypal = true;
    }
    else{
      paypal = false;
    }
    String r = PreferenceUtils.getString(PreferenceNames.razorPayAvailable.toString());
    if( r == "1"){
      razorPay = true;
    }
    else{
      razorPay = false;
    }
    String s = PreferenceUtils.getString(PreferenceNames.stripeAvailable.toString());
    if(s == "1"){
      stripe = true;
    }
    else{
      stripe = false;
    }
    String c = PreferenceUtils.getString(PreferenceNames.codAvailable.toString());

    if(c == "1"){
      cod = true;
    }
    else{
      cod = false;
    }
    //razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        backgroundColor: colorWhite,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, paymentMethodTitle).toString(),
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
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, totalPayableAmount)
                                  .toString() +
                              " :-",
                          style: TextStyle(
                            fontFamily: groldReg,
                            color: colorBlack,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${PreferenceUtils.getString(PreferenceNames.currencySymbolSetting)} $payableAmount',
                          style: TextStyle(
                            fontFamily: groldBold,
                            color: colorBlack,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: razorPay,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                          child: RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: 1,
                        groupValue: value,
                        activeColor: colorPrimary,
                        onChanged: (dynamic val) {
                          setState(() {
                            value = val;
                          });
                        },
                        title: Row(
                          children: [
                            SizedBox(width: 15),
                            Image.asset('assets/images/razorpay.png'),
                            SizedBox(width: 10),
                            Text(
                              getTranslated(context, razorpayText).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: groldReg,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ),
                  Visibility(
                    visible: stripe,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                          child: RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: 2,
                        groupValue: value,
                        activeColor: colorPrimary,
                        onChanged: (dynamic val) {
                          setState(() {
                            value = val;
                          });
                        },
                        title: Row(
                          children: [
                            SizedBox(width: 15),
                            Image.asset('assets/images/stripe.png'),
                            SizedBox(width: 10),
                            Text(
                              getTranslated(context, stripeText).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: groldReg,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ),
                  Visibility(
                    visible: cod,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                          child: RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: 3,
                        groupValue: value,
                        activeColor: colorPrimary,
                        onChanged: (dynamic val) {
                          setState(() {
                            value = val;
                          });
                        },
                        title: Row(
                          children: [
                            SizedBox(width: 15),
                            Icon(Icons.payment,color: Colors.green,size: 24,),
                            SizedBox(width: 10),
                            Text(
                              getTranslated(context, cashOnDeliveryText)
                                  .toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: groldReg,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 30,
              right: 30,
              child: MaterialButton(
                height: kBottomNavigationBarHeight,
                color: colorOrange,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                  getTranslated(context, proceedAndPayText).toString(),
                  style: TextStyle(fontFamily: groldReg, fontSize: 18),
                ),
                onPressed: () {
                  ///paypal
                  if (value == 0) {
                    if (fromWhere == "fromFoodAndGrocery") {
                      ///remove pref keys when payment complete
                    } else if (fromWhere == "fromPickup") {
                      //remove pikup,drop,plat,plong,dlat,dlong from pref uti
                      PreferenceUtils.remove(PreferenceNames.pickupAddress);
                      PreferenceUtils.remove(PreferenceNames.dropAddress);
                      PreferenceUtils.remove(PreferenceNames.pickupLat);
                      PreferenceUtils.remove(PreferenceNames.pickupLong);
                      PreferenceUtils.remove(PreferenceNames.dropLat);
                      PreferenceUtils.remove(PreferenceNames.dropLong);
                    }
                    CommonFunction.toastMessage(
                        "currently paypal payment method is not working");
                  }

                  /// razorpay
                  else if (value == 1) {
                    razorpayMethod();
                  }

                  ///stripe
                  else if (value == 2) {
                    Navigator.push(
                        context,
                        Transitions(
                          transitionType: TransitionType.slideUp,
                          curve: Curves.bounceInOut,
                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                          widget: StripePaymentScreen(
                            fromWhere: fromWhere,
                            paymentData: paymentData,
                          ),
                        ));
                  }

                  ///cod
                  else if (value == 3) {
                    if (fromWhere == "fromFoodAndGrocery") {
                      ///remove pref keys when payment complete
                      paymentData.addAll({
                        "payment_type": "COD",
                        "payment_status": 0,
                      });
                      bookOrder(paymentData);
                    } else if (fromWhere == "fromPickup") {
                      PreferenceUtils.remove(PreferenceNames.pickupAddress);
                      PreferenceUtils.remove(PreferenceNames.dropAddress);
                      PreferenceUtils.remove(PreferenceNames.pickupLat);
                      PreferenceUtils.remove(PreferenceNames.pickupLong);
                      PreferenceUtils.remove(PreferenceNames.dropLat);
                      PreferenceUtils.remove(PreferenceNames.dropLong);
                      paymentData.addAll({
                        "payment_type": "COD",
                        "payment_status": 0,
                      });

                      /// set payment in razorpay, stripe and cod
                      pickupAndDropPayment(paymentData);
                    }
                  }

                  ///not selected any payment
                  else {
                    CommonFunction.toastMessage(
                        getTranslated(context, selectPaymentMethod).toString());
                  }
                  // Navigator.pushNamed(context, trackOrderScreenRoute);
                },
                splashColor: Colors.redAccent,
              ),
            )
          ],
        ),
      ),
    );
  }

  //razorpay
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (fromWhere == "fromFoodAndGrocery") {
      ///remove pref keys when payment complete
      paymentData.addAll({
        "payment_type": "RAZORPAY",
        "payment_token": response.paymentId!,
        "payment_status": 1
      });
      bookOrder(paymentData);
    } else if (fromWhere == "fromPickup") {
      //remove pikup,drop,plat,plong,dlat,dlong from pref uti
      PreferenceUtils.remove(PreferenceNames.pickupAddress);
      PreferenceUtils.remove(PreferenceNames.dropAddress);
      PreferenceUtils.remove(PreferenceNames.pickupLat);
      PreferenceUtils.remove(PreferenceNames.pickupLong);
      PreferenceUtils.remove(PreferenceNames.dropLat);
      PreferenceUtils.remove(PreferenceNames.dropLong);
      paymentData.addAll({
        "payment_type": "RAZORPAY",
        "payment_token": response.paymentId!,
        "payment_status": 1
      });
      pickupAndDropPayment(paymentData);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CommonFunction.toastMessage(
        "ERROR: " + response.code.toString() + " - " + response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CommonFunction.toastMessage("EXTERNAL_WALLET: " + response.walletName!);
  }

  Future<void> razorpayMethod() async {
    double razorpayAmount = 0.0;
    double convertToDouble = double.parse(payableAmount);
    razorpayAmount = convertToDouble * 100;

    var options = {
      'key': razorPayKey,
      'amount': razorpayAmount,
      'name': userName,
      'prefill': {'contact': userContactNumber, 'email': userEmail},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<BaseModel<SendPackage>> pickupAndDropPayment(
      Map<String, dynamic> updatedPaymentData) async {
    SendPackage response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData())
          .pickupAndDropPayment(updatedPaymentData);

      if (response.success == true) {
        Navigator.pushAndRemoveUntil(
            context,
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: TrackOrderScreenForPickup(
                bookOrderPassingData: response.data!,
              ),
            ),
            (route) => false);
        CommonFunction.toastMessage(response.msg!);
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

  Future<BaseModel<BookOrderModel>> bookOrder(
      Map<String, dynamic> updatedPaymentData) async {
    BookOrderModel response;
    try {
      setState(() {
        _loading = true;
      });
      response = await ApiServices(ApiHeader().dioData())
          .bookOrder(updatedPaymentData);
      if (response.success == true) {
        _deleteTable();
        ScopedModel.of<CartModel>(context, rebuildOnChange: true).clearCart();
        if (response.package != null) {
          Navigator.pushAndRemoveUntil(
            context,
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: TrackOrderScreen(
                bookOrderPassingDataPickup: response.package,
                bookOrderPassingData: response.data!,
                whichOrder: 'pickupOrder',
              ),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: TrackOrderScreen(
                bookOrderPassingData: response.data!,
                whichOrder: 'regularOrder',
              ),
            ),
            (route) => false,
          );
        }

        CommonFunction.toastMessage(response.msg.toString());
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

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }
}
