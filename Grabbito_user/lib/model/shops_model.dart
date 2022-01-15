class ShopsModel {
  bool? success;
  ShopsModelData? data;

  ShopsModel({this.success, this.data});

  ShopsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data =
        json['data'] != null ? ShopsModelData.fromJson(json['data']) : null;
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

class ShopsModelData {
  List<Shop>? shop;
  BussinessType? bussinessType;

  ShopsModelData({this.shop, this.bussinessType});

  ShopsModelData.fromJson(Map<String, dynamic> json) {
    if (json['shop'] != null) {
      shop = <Shop>[];
      json['shop'].forEach((v) {
        shop!.add(Shop.fromJson(v));
      });
    }
    bussinessType = json['bussiness_type'] != null
        ? BussinessType.fromJson(json['bussiness_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shop != null) {
      data['shop'] = shop!.map((v) => v.toJson()).toList();
    }
    if (bussinessType != null) {
      data['bussiness_type'] = bussinessType!.toJson();
    }
    return data;
  }
}

class Shop {
  int? id;
  String? name;
  String? image;
  String? lat;
  String? lang;
  String? location;
  String? estimatedTime;
  int? distance;
  int? availableNow;
  Discount? discount;
  String? bannerImage;
  String? fullImage;

  Shop(
      {this.id,
      this.name,
      this.image,
      this.lat,
      this.lang,
      this.location,
      this.estimatedTime,
      this.distance,
      this.availableNow,
      this.discount,
        this.bannerImage,
      this.fullImage});

  Shop.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    location = json['location'];
    estimatedTime = json['estimated_time'].toString();
    distance = json['distance'];
    bannerImage = json['banner_image'];
    availableNow = json['available_now'];
    discount = json['discount'] != null
        ? Discount.fromJson(json['discount'])
        : null;
    fullImage = json['fullImage'];
    print("============***************************=========="+image.toString()+"  "+fullImage.toString()+" "+bannerImage.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['lat'] = lat;
    data['lang'] = lang;
    data['location'] = location;
    data['estimated_time'] = estimatedTime;
    data['distance'] = distance;
    data['banner_image'] = bannerImage;
    data['available_now'] = availableNow;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    data['fullImage'] = fullImage;
    return data;
  }
}

class Discount {
  int? id;
  String? name;
  int? discount;
  String? type;
  String? code;

  Discount({this.id, this.name, this.discount, this.type, this.code});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    discount = json['discount'];
    type = json['type'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['discount'] = discount;
    data['type'] = type;
    data['code'] = code;
    return data;
  }
}

class BussinessType {
  int? id;
  String? name;
  String? image;
  String? bannerImage;
  String? title1;
  String? title2;
  String? fullImage;
  String? fullBannerImage;

  BussinessType(
      {this.id,
      this.name,
      this.image,
      this.bannerImage,
      this.title1,
      this.title2,
      this.fullImage,
      this.fullBannerImage});

  BussinessType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    bannerImage = json['banner_image'];
    title1 = json['title1'];
    title2 = json['title2'];
    fullImage = json['fullImage'];
    fullBannerImage = json['fullBannerImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['banner_image'] = bannerImage;
    data['title1'] = title1;
    data['title2'] = title2;
    data['fullImage'] = fullImage;
    data['fullBannerImage'] = fullBannerImage;
    return data;
  }
}
