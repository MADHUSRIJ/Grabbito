class OffersAtRestaurantModel {
  bool? success;
  List<OffersAtRestaurantData>? data;

  OffersAtRestaurantModel({this.success, this.data});

  OffersAtRestaurantModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      print("JSON DATA"+json['data'].toString());
      data = <OffersAtRestaurantData>[];
      json['data'].forEach((v) {
        data!.add(OffersAtRestaurantData.fromJson(v));
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

class OffersAtRestaurantData {
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

  OffersAtRestaurantData(
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

  OffersAtRestaurantData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bussinessTypeId = json['bussiness_type_id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    availableNow = json['available_now'];

    if (json['discount'] != null) {
      print("JSON DISCOUNT"+json['discount'].toString());
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
  int? minAmount;
  String? createdAt;

  Discount({this.id, this.type, this.discount, this.name, this.code,this.minAmount,this.createdAt});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    discount = json['discount'];
    name = json['name'];
    code = json['code'];
    minAmount = json['min_order_amount'];

    print("======= DISCOUNT 118 "+id.toString()+" "+name.toString());

  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['discount'] = discount;
    data['name'] = name;
    data['code'] = code;
    data['min_order_amount'] = minAmount;
    print("=============");
    print(data.toString());
    return data;
  }
}
