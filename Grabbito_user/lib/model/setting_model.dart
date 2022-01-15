class SettingModel {
  bool? success;
  Data? data;

  SettingModel({this.success, this.data});

  SettingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? name;
  String? currencyCode;
  String? currencySymbol;
  String? userAbout;
  String? userTAndC;
  String? userPrivacy;
  String? deliveryChargeBasedOn;
  String? deliveryCharges;
  String? amountBasedOn;
  String? amount;
  String? userAppId;
  String? autoRefresh;
  String? cod;
  String? wallet;
  String? stripe;
  String? razor;
  String? paypal;
  String? paystack;
  String? flutterwave;
  String? razorKey;
  String? flutterwaveKey;
  String? paypalProductionKey;
  String? paypalEnviromentKey;
  String? paystackKey;
  String? stripePublicKey;
  String? stripeSecretKey;

  Data(
      {this.name,
      this.currencyCode,
      this.currencySymbol,
      this.userAbout,
      this.userTAndC,
      this.userPrivacy,
      this.deliveryChargeBasedOn,
      this.deliveryCharges,
      this.amountBasedOn,
      this.amount,
      this.userAppId,
      this.autoRefresh,
      this.cod,
      this.wallet,
      this.stripe,
      this.razor,
      this.paypal,
      this.paystack,
      this.flutterwave,
      this.razorKey,
      this.flutterwaveKey,
      this.paypalProductionKey,
      this.paypalEnviromentKey,
      this.paystackKey,
      this.stripePublicKey,
      this.stripeSecretKey});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    userAbout = json['user_about'];
    userTAndC = json['user_t_and_c'];
    userPrivacy = json['user_privacy'];
    deliveryChargeBasedOn = json['delivery_charge_based_on'];
    deliveryCharges = json['delivery_charges'];
    amountBasedOn = json['amount_based_on'];
    amount = json['amount'];
    userAppId = json['user_app_id'];
    autoRefresh = json['auto_refresh'];
    cod = json['cod'].toString();
    wallet = json['wallet'].toString();
    stripe = json['stripe'].toString();
    razor = json['razor'].toString();
    paypal = json['paypal'].toString();
    paystack = json['paystack'].toString();
    flutterwave = json['flutterwave'].toString();
    razorKey = json['razor_key'].toString();
    flutterwaveKey = json['flutterwave_key'].toString();
    paypalProductionKey = json['paypal_production_key'].toString();
    paypalEnviromentKey = json['paypal_enviroment_key'].toString();
    paystackKey = json['paystack_key'].toString();
    stripePublicKey = json['stripe_public_key'].toString();
    stripeSecretKey = json['stripe_secret_key'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['user_about'] = userAbout;
    data['user_t_and_c'] = userTAndC;
    data['user_privacy'] = userPrivacy;
    data['delivery_charge_based_on'] = deliveryChargeBasedOn;
    data['delivery_charges'] = deliveryCharges;
    data['amount_based_on'] = amountBasedOn;
    data['amount'] = amount;
    data['user_app_id'] = userAppId;
    data['auto_refresh'] = autoRefresh;
    data['cod'] = cod;
    data['wallet'] = wallet;
    data['stripe'] = stripe;
    data['razor'] = razor;
    data['paypal'] = paypal;
    data['paystack'] = paystack;
    data['flutterwave'] = flutterwave;
    data['razor_key'] = razorKey;
    data['flutterwave_key'] = flutterwaveKey;
    data['paypal_production_key'] = paypalProductionKey;
    data['paypal_enviroment_key'] = paypalEnviromentKey;
    data['paystack_key'] = paystackKey;
    data['stripe_public_key'] = stripePublicKey;
    data['stripe_secret_key'] = stripeSecretKey;
    return data;
  }
}
