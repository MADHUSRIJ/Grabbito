class SendPackage {
  bool? success;
  String? msg;
  SendPackageData? data;

  SendPackage({this.success, this.msg, this.data});

  SendPackage.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null
        ? SendPackageData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SendPackageData {
  int? id;
  String? packageId;
  int? shopId;
  String? orderStatus;
  String? pickLat;
  String? pickLang;
  String? dropLat;
  String? dropLang;
  Shop? shop;
  Driver? driver;

  SendPackageData(
      {this.id,
      this.packageId,
      this.shopId,
      this.orderStatus,
      this.pickLat,
      this.pickLang,
      this.dropLat,
      this.dropLang,
      this.driver,
      this.shop});

  SendPackageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    shopId = json['shop_id'];
    orderStatus = json['order_status'];
    pickLat = json['pick_lat'];
    pickLang = json['pick_lang'];
    dropLat = json['drop_lat'];
    dropLang = json['drop_lang'];
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    driver =
        json['driver'] != null ? Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['shop_id'] = shopId;
    data['order_status'] = orderStatus;
    data['pick_lat'] = pickLat;
    data['pick_lang'] = pickLang;
    data['drop_lat'] = dropLat;
    data['drop_lang'] = dropLang;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}

class Driver {
  int? id;
  String? name;
  String? image;
  String? lat;
  String? lang;
  String? phone;
  String? phoneCode;
  String? fullImage;
  String? licenseImg;
  String? nationId;
  String? deliveryzone;

  Driver(
      {this.id,
      this.name,
      this.image,
      this.lat,
      this.lang,
      this.phone,
      this.phoneCode,
      this.fullImage,
      this.licenseImg,
      this.nationId,
      this.deliveryzone});

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    fullImage = json['fullImage'];
    licenseImg = json['license_img'];
    nationId = json['nation_id'];
    deliveryzone = json['deliveryzone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['lat'] = lat;
    data['lang'] = lang;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['fullImage'] = fullImage;
    data['license_img'] = licenseImg;
    data['nation_id'] = nationId;
    data['deliveryzone'] = deliveryzone;
    return data;
  }
}

class Shop {
  int? id;
  String? name;
  String? lat;
  String? lang;
  String? fullImage;
  String? fullBannerImage;
  int? rate;

  Shop(
      {this.id,
      this.name,
      this.lat,
      this.lang,
      this.fullImage,
      this.fullBannerImage,
      this.rate});

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = json['lat'];
    lang = json['lang'];
    fullImage = json['fullImage'];
    fullBannerImage = json['fullBannerImage'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['lat'] = lat;
    data['lang'] = lang;
    data['fullImage'] = fullImage;
    data['fullBannerImage'] = fullBannerImage;
    data['rate'] = rate;
    return data;
  }
}
