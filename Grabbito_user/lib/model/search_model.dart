class SearchModel {
  bool? success;
  Data? data;

  SearchModel({this.success, this.data});

  SearchModel.fromJson(Map<String, dynamic> json) {
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
  String? lat;
  String? lang;
  String? item;
  List<Shops>? shops;
  List<Items>? items;

  Data({this.lat, this.lang, this.item, this.shops, this.items});

  Data.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lang = json['lang'];
    item = json['item'];
    if (json['shops'] != null) {
      shops = <Shops>[];
      json['shops'].forEach((v) {
        shops!.add(Shops.fromJson(v));
      });
    }
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lang'] = lang;
    data['item'] = item;
    if (shops != null) {
      data['shops'] = shops!.map((v) => v.toJson()).toList();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Shops {
  int? id;
  String? name;
  String? image;
  String? lat;
  String? lang;
  String? location;
  int? estimatedTime;
  int? bussinessTypeId;
  int? distance;
  List<Menu>? menu;
  String? fullImage;

  Shops(
      {this.id,
      this.name,
      this.image,
      this.lat,
      this.lang,
      this.location,
      this.bussinessTypeId,
      this.estimatedTime,
      this.distance,
      this.menu,
      this.fullImage});

  Shops.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    lat = json['lat'];
    lang = json['lang'];
    location = json['location'];
    bussinessTypeId = json['bussiness_type_id'];
    estimatedTime = json['estimated_time'];
    distance = json['distance'];
    if (json['menu'] != null) {
      menu = <Menu>[];
      json['menu'].forEach((v) {
        menu!.add(Menu.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['lat'] = lat;
    data['lang'] = lang;
    data['location'] = location;
    data['bussiness_type_id'] = bussinessTypeId;
    data['estimated_time'] = estimatedTime;
    data['distance'] = distance;
    if (menu != null) {
      data['menu'] = menu!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = fullImage;
    return data;
  }
}

class Menu {
  int? id;
  String? name;

  Menu({this.id, this.name});

  Menu.fromJson(Map<String, dynamic> json) {
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

class Items {
  int? id;
  int? shopId;
  String? name;
  int? price;
  String? image;
  String? description;
  String? unit;
  int? unitId;
  int? bussinessTypeId;
  String? fullImage;

  Items(
      {this.id,
      this.shopId,
      this.name,
      this.price,
      this.image,
      this.description,
      this.unit,
      this.unitId,
      this.bussinessTypeId,
      this.fullImage});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shop_id'];
    name = json['name'];
    price = json['price'];
    image = json['image'];
    description = json['description'];
    unit = json['unit'];
    unitId = json['unit_id'];
    bussinessTypeId = json['bussiness_type_id'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shop_id'] = shopId;
    data['name'] = name;
    data['price'] = price;
    data['image'] = image;
    data['description'] = description;
    data['unit'] = unit;
    data['unit_id'] = unitId;
    data['bussiness_type_id'] = bussinessTypeId;
    data['fullImage'] = fullImage;
    return data;
  }
}
