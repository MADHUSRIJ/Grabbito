class SingleShopModel {
  bool? success;
  SingleShopModelData? data;

  SingleShopModel({this.success, this.data});

  SingleShopModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? SingleShopModelData.fromJson(json['data'])
        : null;
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

class SingleShopModelData {
  int? id;
  String? name;
  String? location;
  String? lat;
  String? lang;
  String? image;
  String? bannerImage;
  String? tax;
  String? forTwoPerson;
  String? estimatedTime;
  String? type;
  int? distance;
  List<Discount>? discount;
  List<Menu>? menu;
  String? fullImage;
  String? fullBannerImage;
  int? rate;

  SingleShopModelData(
      {this.id,
      this.name,
      this.location,
      this.lat,
      this.lang,
      this.image,
      this.bannerImage,
      this.tax,
      this.forTwoPerson,
      this.estimatedTime,
      this.type,
      this.distance,
      this.discount,
      this.menu,
      this.fullImage,
      this.fullBannerImage,
      this.rate});

  SingleShopModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    lat = json['lat'];
    lang = json['lang'];
    image = json['image'];
    bannerImage = json['banner_image'];
    tax = json['tax'].toString();
    forTwoPerson = json['for_two_person'].toString();
    estimatedTime = json['estimated_time'].toString();

    type = json['type'];
    distance = json['distance'];
    if (json['discount'] != null) {
      discount = <Discount>[];
      json['discount'].forEach((v) {
        discount!.add(Discount.fromJson(v));
      });
    }
    if (json['menu'] != null) {
      menu = <Menu>[];
      json['menu'].forEach((v) {
        menu!.add(Menu.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
    fullBannerImage = json['fullBannerImage'];
    rate = json['rate'];
    print("**********************==================****************"+fullBannerImage.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['lat'] = lat;
    data['lang'] = lang;
    data['image'] = image;
    data['banner_image'] = bannerImage;
    data['tax'] = tax;
    data['for_two_person'] = forTwoPerson;
    data['estimated_time'] = estimatedTime;
    data['type'] = type;
    data['distance'] = distance;
    if (discount != null) {
      data['discount'] = discount!.map((v) => v.toJson()).toList();
    }
    if (menu != null) {
      data['menu'] = menu!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = fullImage;
    data['fullBannerImage'] = fullBannerImage;
    data['rate'] = rate;
    return data;
  }
}

class Discount {
  int? id;
  String? name;
  String? code;
  int? minOrderAmount;
  int? minDiscountAmount;
  String? type;
  int? discount;
  String? startDate;
  String? endDate;

  Discount(
      {this.id,
      this.name,
      this.code,
      this.minOrderAmount,
      this.minDiscountAmount,
      this.type,
      this.discount,
      this.startDate,
      this.endDate});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    minOrderAmount = json['min_order_amount'];
    minDiscountAmount = json['min_discount_amount'];
    type = json['type'];
    discount = json['discount'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['min_order_amount'] = minOrderAmount;
    data['min_discount_amount'] = minDiscountAmount;
    data['type'] = type;
    data['discount'] = discount;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class Menu {
  int? id;
  String? name;
  List<Submenu>? submenu;

  Menu({this.id, this.name, this.submenu});

  Menu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['submenu'] != null) {
      submenu = <Submenu>[];
      json['submenu'].forEach((v) {
        submenu!.add(Submenu.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (submenu != null) {
      data['submenu'] = submenu!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Submenu {
  int? id;
  String? name;
  String? price;
  String? image;
  String? description;
  String? unit;
  String? unitId;
  String? type;
  List<Custimization>? custimization;
  bool? isAdded = false;
  bool? isRepeatCustomization = false;
  int count = 0;
  int itemQty = 0;
  String? fullImage;
  Units? units;

  Submenu(
      {this.id,
      this.name,
      this.price,
      this.image,
      this.description,
      this.unit,
      this.unitId,
      this.type,
      this.custimization,
      this.isAdded,
      required this.count,
      this.fullImage,
      this.isRepeatCustomization,
      this.units});

  Submenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'].toString();
    image = json['image'];
    description = json['description'];
    unit = json['unit'];
    unitId = json['unit_id'].toString();
    type = json['type'];
    if (json['custimization'] != null) {
      custimization = <Custimization>[];
      json['custimization'].forEach((v) {
        custimization!.add(Custimization.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
    units = json['units'] != null ? Units.fromJson(json['units']) : null;
    print("SINGLE SHOP FULL IMAGE"+fullImage.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['image'] = image;
    data['description'] = description;
    data['unit'] = unit;
    data['unit_id'] = unitId;
    data['type'] = type;
    if (custimization != null) {
      data['custimization'] =
          custimization!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = fullImage;
    if (units != null) {
      data['units'] = units!.toJson();
    }
    return data;
  }
}

class Custimization {
  int? id;
  String? name;
  int? categoryId;
  int? subcategoryId;
  String? custimization;
  int? status;

  Custimization(
      {this.id,
      this.name,
      this.categoryId,
      this.subcategoryId,
      this.custimization,
      this.status});

  Custimization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    custimization = json['custimization'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category_id'] = categoryId;
    data['subcategory_id'] = subcategoryId;
    data['custimization'] = custimization;
    data['status'] = status;
    return data;
  }
}

class Units {
  int? id;
  String? name;

  Units({this.id, this.name});

  Units.fromJson(Map<String, dynamic> json) {
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
