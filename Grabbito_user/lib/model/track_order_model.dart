class TrackOrderModel {
  bool? success;
  TrackOrderModelData? data;

  TrackOrderModel({this.success, this.data});

  TrackOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TrackOrderModelData.fromJson(json['data']) : null;
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

class TrackOrderModelData {
  int? id;
  int? tax;
  int? shopId;
  String? orderId;
  String? orderStatus;
  int? amount;
  int? deliveryCharge;
  int? shopDiscountPrice;
  int? promocodePrice;
  int? shopDiscountId;
  int? promocodeId;
  int? locationId;
  int? deliveryPersonId;
  String? date;
  String? time;
  Promocode? promocode;
  Shopdiscount? shopdiscount;
  List<OrderItems>? orderItems;
  Shop? shop;
  Address? address;
  Deliveryperson? deliveryperson;

  TrackOrderModelData(
      {this.id,
      this.tax,
      this.shopId,
      this.orderId,
      this.orderStatus,
      this.amount,
      this.deliveryCharge,
      this.shopDiscountPrice,
      this.promocodePrice,
      this.shopDiscountId,
      this.promocodeId,
      this.locationId,
      this.deliveryPersonId,
      this.date,
      this.time,
      this.promocode,
      this.shopdiscount,
      this.orderItems,
      this.shop,
      this.address,
      this.deliveryperson});

  TrackOrderModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tax = json['tax'];
    shopId = json['shop_id'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    amount = json['amount'];
    deliveryCharge = json['delivery_charge'];
    shopDiscountPrice = json['shop_discount_price'];
    promocodePrice = json['promocode_price'];
    shopDiscountId = json['shop_discount_id'];
    promocodeId = json['promocode_id'];
    locationId = json['location_id'];
    deliveryPersonId = json['delivery_person_id'];
    date = json['date'];
    time = json['time'];
    promocode = json['promocode'] != null ? Promocode.fromJson(json['promocode']) : null;
    shopdiscount = json['shopdiscount'] != null ? Shopdiscount.fromJson(json['shopdiscount']) : null;
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    deliveryperson = json['deliveryperson'] != null ? Deliveryperson.fromJson(json['deliveryperson']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tax'] = tax;
    data['shop_id'] = shopId;
    data['order_id'] = orderId;
    data['order_status'] = orderStatus;
    data['amount'] = amount;
    data['delivery_charge'] = deliveryCharge;
    data['shop_discount_price'] = shopDiscountPrice;
    data['promocode_price'] = promocodePrice;
    data['shop_discount_id'] = shopDiscountId;
    data['promocode_id'] = promocodeId;
    data['location_id'] = locationId;
    data['delivery_person_id'] = deliveryPersonId;
    data['date'] = date;
    data['time'] = time;
    if (promocode != null) {
      data['promocode'] = promocode!.toJson();
    }
    if (shopdiscount != null) {
      data['shopdiscount'] = shopdiscount!.toJson();
    }
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (deliveryperson != null) {
      data['deliveryperson'] = deliveryperson!.toJson();
    }
    return data;
  }
}

class Promocode {
  int? id;
  String? name;

  Promocode({this.id, this.name});

  Promocode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class OrderItems {
  int? id;
  int? orderId;
  int? item;
  int? price;
  int? qty;
  List<Custimization>? custimization;
  String? itemName;

  OrderItems({this.id, this.orderId, this.item, this.price, this.qty, this.custimization, this.itemName});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    item = json['item'];
    price = json['price'];
    qty = json['qty'];
    if (json['custimization'] != null) {
      custimization = <Custimization>[];
      json['custimization'].forEach((v) {
        custimization!.add(Custimization.fromJson(v));
      });
    }
    itemName = json['itemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['item'] = item;
    data['price'] = price;
    data['qty'] = qty;
    if (custimization != null) {
      data['custimization'] = custimization!.map((v) => v.toJson()).toList();
    }
    data['itemName'] = itemName;
    return data;
  }
}

class Custimization {
  String? mainMenu;
  CustomizationData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null ? CustomizationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_menu'] = mainMenu;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CustomizationData {
  String? name;
  String? price;

  CustomizationData({this.name, this.price});

  CustomizationData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class Shop {
  int? id;
  String? location;
  String? fullImage;
  String? fullBannerImage;
  int? rate;

  Shop({this.id, this.location, this.fullImage, this.fullBannerImage, this.rate});

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location = json['location'];
    fullImage = json['fullImage'];
    fullBannerImage = json['fullBannerImage'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['location'] = location;
    data['fullImage'] = fullImage;
    data['fullBannerImage'] = fullBannerImage;
    data['rate'] = rate;
    return data;
  }
}

class Address {
  int? id;
  String? address;

  Address({this.id, this.address});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    return data;
  }
}

class Deliveryperson {
  int? id;
  String? name;
  String? fullImage;
  String? licenseImg;
  String? nationId;

  Deliveryperson({
    this.id,
    this.name,
    this.fullImage,
    this.licenseImg,
    this.nationId,
  });

  Deliveryperson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
    licenseImg = json['license_img'];
    nationId = json['nation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['fullImage'] = fullImage;
    data['license_img'] = licenseImg;
    data['nation_id'] = nationId;

    return data;
  }
}

class Shopdiscount {
  int? id;
  String? name;
  String? code;
  String? startEndTime;
  int? minOrderAmount;
  int? minDiscountAmount;
  int? discount;
  int? shopId;
  String? type;
  int? status;
  String? createdAt;
  String? updatedAt;

  Shopdiscount(
      {this.id,
      this.name,
      this.code,
      this.startEndTime,
      this.minOrderAmount,
      this.minDiscountAmount,
      this.discount,
      this.shopId,
      this.type,
      this.status,
      this.createdAt,
      this.updatedAt});

  Shopdiscount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    startEndTime = json['start_end_time'];
    minOrderAmount = json['min_order_amount'];
    minDiscountAmount = json['min_discount_amount'];
    discount = json['discount'];
    shopId = json['shop_id'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['start_end_time'] = startEndTime;
    data['min_order_amount'] = minOrderAmount;
    data['min_discount_amount'] = minDiscountAmount;
    data['discount'] = discount;
    data['shop_id'] = shopId;
    data['type'] = type;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
