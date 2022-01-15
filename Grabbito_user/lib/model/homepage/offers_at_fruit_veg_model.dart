class OffersAtFruitsModel {
  bool? success;
  List<OffersAtFruitData>? data;

  OffersAtFruitsModel({this.success, this.data});

  OffersAtFruitsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <OffersAtFruitData>[];
      json['data'].forEach((v) {
        data!.add(OffersAtFruitData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OffersAtFruitData {
  int? id;
  int? bussinessTypeId;
  String? name;
  String? image;
  String? lat;
  String? lang;
  int? availableNow;
  List<Discount>? discount;
  int? distance;
  List<String>? menu;
  String? fullImage;
  int? rate;

  OffersAtFruitData(
      {this.id,
      this.bussinessTypeId,
      this.name,
      this.image,
      this.lat,
      this.lang,
      this.availableNow,
      this.discount,
      this.distance,
      this.menu,
      this.fullImage,
      this.rate});

  OffersAtFruitData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bussinessTypeId = json['bussiness_type_id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    availableNow = json['available_now'];
    if (json['discount'] != null) {
      discount = <Discount>[];
      json['discount'].forEach((v) {
        discount!.add(Discount.fromJson(v));
      });
    }
    distance = json['distance'];
    menu = json['menu'].cast<String>();
    fullImage = json['fullImage'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bussiness_type_id'] = bussinessTypeId;
    data['name'] = name;
    data['image'] = image;
    data['lat'] = lat;
    data['lang'] = lang;
    data['available_now'] = availableNow;
    if (discount != null) {
      data['discount'] = discount!.map((v) => v.toJson()).toList();
    }
    data['distance'] = distance;
    data['menu'] = menu;
    data['fullImage'] = fullImage;
    data['rate'] = rate;
    return data;
  }
}

class Discount {
  int? id;
  String? type;
  int? discount;
  String? name;
  String? code;

  Discount({this.id, this.type, this.discount, this.name, this.code});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    discount = json['discount'];
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['discount'] = discount;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}
