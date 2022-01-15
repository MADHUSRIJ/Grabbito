class OrderHistoryModel {
  bool? success;
  Data? data;

  OrderHistoryModel({this.success, this.data});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
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
  List<PastOrder>? pastOrder;
  List<UpcomingOrder>? upcomingOrder;
  List<PickDropup>? pickDropup;

  Data({this.pastOrder, this.upcomingOrder, this.pickDropup});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['past_order'] != null) {
      pastOrder = <PastOrder>[];
      json['past_order'].forEach((v) {
        pastOrder!.add(PastOrder.fromJson(v));
      });
    }
    if (json['upcoming_order'] != null) {
      upcomingOrder = <UpcomingOrder>[];
      json['upcoming_order'].forEach((v) {
        upcomingOrder!.add(UpcomingOrder.fromJson(v));
      });
    }
    if (json['pick_dropup'] != null) {
      pickDropup = <PickDropup>[];
      json['pick_dropup'].forEach((v) {
        pickDropup!.add(PickDropup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pastOrder != null) {
      data['past_order'] = pastOrder!.map((v) => v.toJson()).toList();
    }
    if (upcomingOrder != null) {
      data['upcoming_order'] = upcomingOrder!.map((v) => v.toJson()).toList();
    }
    if (pickDropup != null) {
      data['pick_dropup'] = pickDropup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PastOrder {
  int? id;
  String? orderId;
  int? shopId;
  int? amount;
  String? date;
  String? time;
  int? locationId;
  String? orderStatus;
  List<OrderItems>? orderItems;
  Address? address;
  Shop? shop;
  int? deliveryPersonId;
  Driver? driver;

  PastOrder(
      {this.id,
      this.orderId,
      this.shopId,
      this.amount,
      this.date,
      this.time,
      this.locationId,
      this.orderStatus,
      this.orderItems,
      this.address,
      this.shop,
      this.deliveryPersonId,
      this.driver});

  PastOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    shopId = json['shop_id'];
    amount = json['amount'];
    date = json['date'];
    time = json['time'];
    locationId = json['location_id'];
    orderStatus = json['order_status'];
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    deliveryPersonId = json['delivery_person_id'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['shop_id'] = shopId;
    data['amount'] = amount;
    data['date'] = date;
    data['time'] = time;
    data['location_id'] = locationId;
    data['order_status'] = orderStatus;
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    data['delivery_person_id'] = deliveryPersonId;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}

class UpcomingOrder {
  int? id;
  String? orderId;
  int? shopId;
  int? amount;
  String? date;
  String? time;
  int? locationId;
  String? orderStatus;
  List<OrderItems>? orderItems;
  Address? address;
  Shop? shop;
  int? deliveryPersonId;
  Driver? driver;

  UpcomingOrder(
      {this.id,
      this.orderId,
      this.shopId,
      this.amount,
      this.date,
      this.time,
      this.locationId,
      this.orderStatus,
      this.orderItems,
      this.address,
      this.shop});

  UpcomingOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    shopId = json['shop_id'];
    amount = json['amount'];
    date = json['date'];
    time = json['time'];
    locationId = json['location_id'];
    orderStatus = json['order_status'];
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    deliveryPersonId = json['delivery_person_id'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['shop_id'] = shopId;
    data['amount'] = amount;
    data['date'] = date;
    data['time'] = time;
    data['location_id'] = locationId;
    data['order_status'] = orderStatus;
    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    data['delivery_person_id'] = deliveryPersonId;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}

class PickDropup {
  int? id;
  String? packageId;
  int? shopId;
  int? categoryId;
  int? userId;
  int? amount;
  String? pickupLocation;
  String? pickLat;
  String? pickLang;
  String? dropupLocation;
  String? dropLat;
  String? dropLang;
  String? orderStatus;
  String? paymentToken;
  String? note;
  int? deliveryPersonId;
  String? createdAt;
  Driver? driver;
  Shop? shop;
  Category? category;

  PickDropup(
      {this.id,
      this.packageId,
      this.shopId,
      this.categoryId,
      this.userId,
      this.amount,
      this.pickupLocation,
      this.pickLat,
      this.pickLang,
      this.dropupLocation,
      this.dropLat,
      this.dropLang,
      this.orderStatus,
      this.paymentToken,
      this.note,
      this.deliveryPersonId,
      this.createdAt,
      this.driver,
      this.shop,
      this.category});

  PickDropup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    shopId = json['shop_id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    amount = json['amount'];
    pickupLocation = json['pickup_location'];
    pickLat = json['pick_lat'];
    pickLang = json['pick_lang'];
    dropupLocation = json['dropup_location'];
    dropLat = json['drop_lat'];
    dropLang = json['drop_lang'];
    orderStatus = json['order_status'];
    paymentToken = json['payment_token'];
    note = json['note'];
    deliveryPersonId = json['delivery_person_id'];
    createdAt = json['created_at'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['shop_id'] = shopId;
    data['category_id'] = categoryId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['pickup_location'] = pickupLocation;
    data['pick_lat'] = pickLat;
    data['pick_lang'] = pickLang;
    data['dropup_location'] = dropupLocation;
    data['drop_lat'] = dropLat;
    data['drop_lang'] = dropLang;
    data['order_status'] = orderStatus;
    data['payment_token'] = paymentToken;
    data['note'] = note;
    data['delivery_person_id'] = deliveryPersonId;
    data['created_at'] = createdAt;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? fullImage;

  Category({this.id, this.name, this.fullImage});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['fullImage'] = fullImage;
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
  CustomisationData? data;

  Custimization({this.mainMenu, this.data});

  Custimization.fromJson(Map<String, dynamic> json) {
    mainMenu = json['main_menu'];
    data = json['data'] != null ? CustomisationData.fromJson(json['data']) : null;
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

class CustomisationData {
  String? name;
  String? price;

  CustomisationData({this.name, this.price});

  CustomisationData.fromJson(Map<String, dynamic> json) {
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

class Address {
  int? id;
  String? address;
  String? lat;
  String? lang;

  Address({this.id, this.address, this.lat, this.lang});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
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

class Driver {
  int? id;
  String? lat;
  String? lang;
  String? name;
  String? phone;
  String? phoneCode;
  String? image;
  String? fullImage;

  Driver({this.id, this.lat, this.lang, this.name, this.phone, this.phoneCode, this.image, this.fullImage});

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    lang = json['lang'];
    name = json['name'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['lang'] = lang;
    data['name'] = name;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['image'] = image;
    data['fullImage'] = fullImage;
    return data;
  }
}
