class BusinessTypesModel {
  bool? success;
  List<BusinessTypesData>? data;

  BusinessTypesModel({this.success, this.data});

  BusinessTypesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <BusinessTypesData>[];
      json['data'].forEach((v) {
        data!.add(BusinessTypesData.fromJson(v));
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

class BusinessTypesData {
  int? id;
  String? name;
  String? image;
  String? fullImage;

  BusinessTypesData({this.id, this.name, this.image, this.fullImage});

  BusinessTypesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['fullImage'] = fullImage;
    return data;
  }
}
