import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:grabbito/constant/color_constant.dart';
import 'package:grabbito/routes/custome_router.dart';
import 'package:grabbito/routes/route_names.dart';
import 'package:grabbito/utilities/database_helper.dart';
import 'package:grabbito/utilities/preference_consts.dart';

import 'constant/common_function.dart';
import 'localization/language_localization.dart';
import 'localization/localization_constant.dart';
import 'model/cart_model.dart';
import 'model/setting_model.dart';
import 'network/api_header.dart';
import 'network/api_service.dart';
import 'network/base_model.dart';
import 'network/server_error.dart';
import 'utilities/preference_utility.dart';

final dbHelper = DatabaseHelper.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: true,
    systemNavigationBarContrastEnforced: true,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  await PreferenceUtils.init();
  //error purpose
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error!',
        style: TextStyle(color: Colors.red),
        textDirection: TextDirection.ltr,
      ),
    );
  };

  //for stripe
  // Stripe.publishableKey = PreferenceUtils.getString(PreferenceNames.stripePublicKey);
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // Stripe.urlScheme = 'flutterstripe';
  // await Stripe.instance.applySettings();

  runApp(MyApp(
    model: CartModel(),
  ));

}

class MyApp extends StatefulWidget {
  final CartModel model;

  const MyApp({Key? key, required this.model}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool navigate = false;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _queryFirst(context, widget.model);
    settingData();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
          setState(() {
            _locale = local;
          })
        });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (PreferenceUtils.getBool(PreferenceNames.onBoardDone) != true) {
      if (PreferenceUtils.getBool(PreferenceNames.onBoardDoneFirst) != true) {
        navigate = true;
      } else {
        navigate = false;
      }
    } else {
      navigate = false;
    }
    if (_locale == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ScopedModel<CartModel>(
        model: widget.model,
        child: MaterialApp(
          title: 'grabbito',
          locale: _locale,
          supportedLocales: const [
            Locale(english, 'US'),
            Locale(spanish, 'ES'),
            Locale(arabic, 'AE'),
          ],
          localizationsDelegates: const [
            LanguageLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocal, supportedLocales) {
            for (var local in supportedLocales) {
              if (local.languageCode == deviceLocal!.languageCode &&
                  local.countryCode == deviceLocal.countryCode) {
                return deviceLocal;
              }
            }
            return supportedLocales.first;
          },
          theme: ThemeData(
              colorScheme: ColorScheme(
                  primary: colorPrimary,
                  primaryVariant: primaryVariant,
                  secondary: secondary,
                  secondaryVariant: secondaryVariant,
                  surface: surface,
                  background: background,
                  error: error,
                  onPrimary: onPrimary,
                  onSecondary: onSecondary,
                  onSurface: onSurface,
                  onBackground: onBackground,
                  onError: onError,
                  brightness: Brightness.light),
              primaryColor: colorPrimary,
              appBarTheme: AppBarTheme(elevation: 1,systemOverlayStyle: SystemUiOverlayStyle(
                //systemNavigationBarColor: Colors.white,
                statusBarBrightness: Brightness.dark,
                //systemNavigationBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
              )),
              dividerColor: Colors.transparent),
          debugShowCheckedModeBanner: false,
          initialRoute: navigate == true ? onBoardRoute : loginRoute,
          // initialRoute: myRoute,
          onGenerateRoute: CustomRouter.allRoutes,
        ),
      );
    }
  }

  void _queryFirst(BuildContext context, CartModel? model) async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    for (var row in allRows) {
      print(row);
    }
    for (int i = 0; i < allRows.length; i++) {
      model!.addProduct(Product(
        id: allRows[i]['pro_id'],
        restaurantsName: allRows[i]['restName'],
        title: allRows[i]['pro_name'],
        imgUrl: allRows[i]['pro_image'],
        type: allRows[i]['pro_type'],
        price: double.parse(allRows[i]['pro_price']),
        qty: allRows[i]['pro_qty'],
        restaurantsId: allRows[i]['restId'],
        restaurantImage: allRows[i]['restImage'],
        restaurantAddress: allRows[i]['restAddress'],
        restaurantKm: allRows[i]['restKm'],
        restaurantEstimatedTime: allRows[i]['restEstimateTime'],
        foodCustomization: allRows[i]['pro_customization'],
        isRepeatCustomization: allRows[i]['isRepeatCustomization'],
        tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
        itemQty: allRows[i]['itemQty'],
        isCustomization: allRows[i]['isCustomization'],
      ));
    }
  }

  Future<BaseModel<SettingModel>> settingData() async {
    SettingModel response;
    try {
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
          PreferenceUtils.setString(PreferenceNames.razorPayAvailable.toString(), "1");
        } else {
          PreferenceUtils.setString(PreferenceNames.razorPayAvailable.toString(), "0");
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
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSingleToken(String appId) async {
    String? userId = '';
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    var status = await (OneSignal.shared.getDeviceState());
    userId = status!.userId;
    print("pushtoken1:$userId");
    if (PreferenceUtils.getString(PreferenceNames.onesignalPushToken)
        .isNotEmpty) {
      if (userId != null) {
        PreferenceUtils.setString(PreferenceNames.onesignalPushToken, userId);
      } else {
        PreferenceUtils.setString(PreferenceNames.onesignalPushToken, '');
      }
    }
  }
}
