class ShowAllLocationModel {
  bool? success;
  List<ShowAllLocationData>? data;

  ShowAllLocationModel({this.success, this.data});

  ShowAllLocationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ShowAllLocationData>[];
      json['data'].forEach((v) {
        data!.add(ShowAllLocationData.fromJson(v));
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

class ShowAllLocationData {
  int? id;
  String? userId;
  String? address;
  String? lat;
  String? lang;
  String? landmark;
  String? locationType;

  ShowAllLocationData(
      {this.id,
      this.userId,
      this.address,
      this.lat,
      this.lang,
      this.landmark,
      this.locationType});

  ShowAllLocationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'].toString();
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    landmark = json['landmark'];
    locationType = json['location_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['address'] = address;
    data['lat'] = lat;
    data['lang'] = lang;
    data['landmark'] = landmark;
    data['location_type'] = locationType;
    return data;
  }
}
