import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/app_strings.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/constant/common_function.dart';
import 'package:grabbito/localization/localization_constant.dart';
import 'package:grabbito/model/book_order_model.dart' as bookingModelLib;
import 'package:grabbito/model/booking_order_for_package.dart';
import 'package:grabbito/model/cart_model.dart';
import 'package:grabbito/network/api_header.dart';
import 'package:grabbito/network/api_service.dart';
import 'package:grabbito/network/base_model.dart';
import 'package:grabbito/network/server_error.dart';
import 'package:grabbito/screens/cart/track_order_screen.dart';
import 'package:grabbito/screens/cart/track_order_screen_for_pickup.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';
import 'package:grabbito/utilities/preference_utility.dart';
import 'package:grabbito/utilities/transition.dart';

//new
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class StripePaymentScreen extends StatefulWidget {
  final String fromWhere;
  final Map<String, dynamic> paymentData;

  StripePaymentScreen({required this.fromWhere, required this.paymentData});

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final dbHelper = DatabaseHelper.instance;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _loading = false;
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String? stripeToken = '';
  String stripePublicKey = '';
  late Map<String, dynamic> paymentData;

  //new
  CardFieldInputDetails? _card;

  TokenData? tokenData;

  @override
  void initState() {
    super.initState();
    paymentData = widget.paymentData;
    stripePublicKey =
        PreferenceUtils.getString(PreferenceNames.stripePublicKey);
    setStripePublishKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: colorWhite,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getTranslated(context, stripePaymentScreenTitle).toString(),
          style: TextStyle(
              fontFamily: groldBlack, color: colorBlack, fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 1.0,
        color: Colors.transparent.withOpacity(0.2),
        progressIndicator: SpinKitFadingCircle(color: colorRed),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardField(
                autofocus: false,
                onCardChanged: (card) {
                  setState(() {
                    _card = card;
                  });
                },
              ),
              LoadingButton(
                  onPressed:
                      _card?.complete == true ? _handleCreateTokenPress : null,
                  text:
                      getTranslated(context, stripePaymentComplete).toString()),
            ],
          ),
        ),
      ),
    );
  }

  Future _handleCreateTokenPress() async {
    setState(() {
      _loading = true;
    });
    if (_card == null) {
      return;
    }

    try {
      final tokenData = await Stripe.instance
          .createToken(
            CreateTokenParams(type: TokenType.Card),
          )
          .onError((error, stackTrace) => setError(error));
      setState(() {
        this.tokenData = tokenData;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Success: The token was created successfully!')));
      if (tokenData.id.isNotEmpty) {
        stripeToken = tokenData.id;
        CommonFunction.toastMessage(
            getTranslated(context, stripePaymentDone).toString());
        if (widget.fromWhere == "fromFoodAndGrocery") {
          ///remove pref keys when payment complete
          paymentData.addAll({
            "payment_type": "STRIPE",
            "payment_token": stripeToken,
            "payment_status": 1
          });
          bookOrder(paymentData);
        } else if (widget.fromWhere == "fromPickup") {
          PreferenceUtils.remove(PreferenceNames.pickupAddress);
          PreferenceUtils.remove(PreferenceNames.dropAddress);
          PreferenceUtils.remove(PreferenceNames.pickupLat);
          PreferenceUtils.remove(PreferenceNames.pickupLong);
          PreferenceUtils.remove(PreferenceNames.dropLat);
          PreferenceUtils.remove(PreferenceNames.dropLong);
          paymentData.addAll({
            "payment_type": "STRIPE",
            "payment_token": stripeToken,
            "payment_status": 1
          });
          pickupAndDropPayment(paymentData);
        }
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  Future<void> setStripePublishKey() async {
    Stripe.publishableKey = stripePublicKey;
    await Stripe.instance.applySettings();
  }

  setError(dynamic error) {
    showDialog(
      builder: (context) => AlertDialog(
        title: Text('Payment Error'),
        content: Text('something went wrong'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok'),
          )
        ],
      ),
      context: context,
    );
    setState(() {
      print(error.toString());
    });
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
      }
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

  Future<BaseModel<bookingModelLib.BookOrderModel>> bookOrder(
      Map<String, dynamic> updatedPaymentData) async {
    bookingModelLib.BookOrderModel response;
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
              (route) => false);
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
              (route) => false);
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

//new
class LoadingButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String text;

  const LoadingButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: MaterialButton(
            height: kBottomNavigationBarHeight,
            color: colorButton,
            textColor: Colors.white,
            splashColor: Colors.redAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed:
                (_isLoading || widget.onPressed == null) ? null : _loadFuture,
            child: _isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                : Text(
                    widget.text,
                    style: TextStyle(fontFamily: groldBold, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error $e')));
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
