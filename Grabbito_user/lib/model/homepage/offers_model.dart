class OffersModel {
  bool? success;
  List<OfferModelData>? data;

  OffersModel({this.success, this.data});

  OffersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <OfferModelData>[];
      json['data'].forEach((v) {
        data!.add(OfferModelData.fromJson(v));
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

class OfferModelData {
  int? id;
  String? name;
  String? code;
  String? description;
  String? type;
  int? discount;

  OfferModelData(
      {this.id,
      this.name,
      this.code,
      this.description,
      this.type,
      this.discount});

  OfferModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    description = json['description'];
    type = json['type'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['description'] = description;
    data['type'] = type;
    data['discount'] = discount;
    return data;
  }
}
