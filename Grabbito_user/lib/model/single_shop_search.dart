class SingleShopSearchModel {
  bool? success;
  List<SingleShopSearchModelData>? data;

  SingleShopSearchModel({this.success, this.data});

  SingleShopSearchModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SingleShopSearchModelData>[];
      json['data'].forEach((v) {
        data!.add(SingleShopSearchModelData.fromJson(v));
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

class SingleShopSearchModelData {
  int? id;
  int? shopId;
  int? categoryId;
  int? unitId;
  String? unit;
  String? image;
  String? name;
  String? type;
  int? price;
  int? status;
  String? description;
  String? createdAt;
  String? updatedAt;
  List<Customization>? custimization;
  String? fullImage;
  bool? isAdded = false;
  bool? isRepeatCustomization = false;
  int count = 0;
  int itemQty = 0;

  SingleShopSearchModelData({
    this.id,
    this.shopId,
    this.categoryId,
    this.unitId,
    this.unit,
    this.image,
    this.name,
    this.type,
    this.price,
    this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.custimization,
    this.isAdded,
    required this.count,
    this.fullImage,
    this.isRepeatCustomization,
  });

  SingleShopSearchModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shop_id'];
    categoryId = json['category_id'];
    unitId = json['unit_id'];
    unit = json['unit'];
    image = json['image'];
    name = json['name'];
    type = json['type'];
    price = json['price'];
    status = json['status'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['custimization'] != null) {
      custimization = <Customization>[];
      json['custimization'].forEach((v) {
        custimization!.add(Customization.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shop_id'] = shopId;
    data['category_id'] = categoryId;
    data['unit_id'] = unitId;
    data['unit'] = unit;
    data['image'] = image;
    data['name'] = name;
    data['type'] = type;
    data['price'] = price;
    data['status'] = status;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (custimization != null) {
      data['custimization'] =
          custimization!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = fullImage;
    return data;
  }
}

class Customization {
  int? id;
  String? name;
  int? categoryId;
  int? subcategoryId;
  String? custimization;
  int? status;

  Customization(
      {this.id,
      this.name,
      this.categoryId,
      this.subcategoryId,
      this.custimization,
      this.status});

  Customization.fromJson(Map<String, dynamic> json) {
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
