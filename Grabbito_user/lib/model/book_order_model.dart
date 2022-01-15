class BookOrderModel {
  bool? success;
  BookOrderData? data;
  Package? package;
  String? msg;
  BookOrderModel({this.success, this.data, this.msg, this.package});

  BookOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? BookOrderData.fromJson(json['data']) : null;
    msg = json['msg'];
    package = json['package'] != null ? Package.fromJson(json['package']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (package != null) {
      data['package'] = package!.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class BookOrderData {
  int? id;
  String? orderId;
  String? orderStatus;
  int? shopId;
  int? locationId;
  Address? address;
  Shop? shop;
  Driver? driver;

  BookOrderData(
      {this.id, this.orderId, this.shopId, this.locationId, this.orderStatus, this.address, this.driver, this.shop});

  BookOrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    shopId = json['shop_id'];
    locationId = json['location_id'];
    orderStatus = json['order_status'];
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['shop_id'] = shopId;
    data['location_id'] = locationId;
    data['order_status'] = orderStatus;
    if (address != null) {
      data['address'] = address!.toJson();
    }
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

  Driver({this.id, this.name, this.image, this.lat, this.lang, this.phone, this.phoneCode, this.fullImage});

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    fullImage = json['fullImage'];
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
    return data;
  }
}

class Address {
  int? id;
  String? lat;
  String? lang;

  Address({this.id, this.lat, this.lang});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['lang'] = lang;
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

  Shop({this.id, this.name, this.lat, this.lang, this.fullImage, this.fullBannerImage, this.rate});

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

class Package {
  int? id;
  String? packageId;
  int? shopId;
  int? categoryId;
  int? userId;
  int? amount;
  int? tax;
  String? paymentType;
  String? paymentStatus;
  String? pickupLocation;
  String? pickLat;
  String? pickLang;
  String? dropupLocation;
  String? dropLat;
  String? dropLang;
  int? ownerCommission;
  int? adminCommission;
  String? orderStatus;
  int? weight;
  String? note;
  int? deliveryPersonId;
  String? createdAt;
  String? updatedAt;
  Driver? driver;
  Shop? shop;

  Package(
      {this.id,
      this.packageId,
      this.shopId,
      this.categoryId,
      this.userId,
      this.amount,
      this.tax,
      this.paymentType,
      this.paymentStatus,
      this.pickupLocation,
      this.pickLat,
      this.pickLang,
      this.dropupLocation,
      this.dropLat,
      this.dropLang,
      this.ownerCommission,
      this.adminCommission,
      this.orderStatus,
      this.weight,
      this.note,
      this.deliveryPersonId,
      this.createdAt,
      this.updatedAt,
      this.driver,
      this.shop});

  Package.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    shopId = json['shop_id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    amount = json['amount'];
    tax = json['tax'];
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
    pickupLocation = json['pickup_location'];
    pickLat = json['pick_lat'];
    pickLang = json['pick_lang'];
    dropupLocation = json['dropup_location'];
    dropLat = json['drop_lat'];
    dropLang = json['drop_lang'];
    ownerCommission = json['owner_commission'];
    adminCommission = json['admin_commission'];
    orderStatus = json['order_status'];
    weight = json['weight'];
    note = json['note'];
    deliveryPersonId = json['delivery_person_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['shop_id'] = shopId;
    data['category_id'] = categoryId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['tax'] = tax;
    data['payment_type'] = paymentType;
    data['payment_status'] = paymentStatus;
    data['pickup_location'] = pickupLocation;
    data['pick_lat'] = pickLat;
    data['pick_lang'] = pickLang;
    data['dropup_location'] = dropupLocation;
    data['drop_lat'] = dropLat;
    data['drop_lang'] = dropLang;
    data['owner_commission'] = ownerCommission;
    data['admin_commission'] = adminCommission;
    data['order_status'] = orderStatus;
    data['weight'] = weight;
    data['note'] = note;
    data['delivery_person_id'] = deliveryPersonId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    return data;
  }
}
