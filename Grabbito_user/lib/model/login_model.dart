class LoginModel {
  bool? success;
  Data? data;
  String? message;

  LoginModel({this.success, this.data, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  String? phoneCode;
  String? phone;
  String? image;
  String? status;
  String? verified;
  String? createdAt;
  String? updatedAt;
  String? token;
  String? fullImage;
  String? logoImg;

  Data(
      {this.id,
      this.name,
      this.email,
      this.phoneCode,
      this.phone,
      this.image,
      this.status,
      this.verified,
      this.createdAt,
      this.updatedAt,
      this.token,
      this.fullImage,
      this.logoImg});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneCode = json['phone_code'];
    phone = json['phone'];
    image = json['image'];
    status = json['status'].toString();
    verified = json['verified'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
    fullImage = json['fullImage'];
    logoImg = json['logoImg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone_code'] = phoneCode;
    data['phone'] = phone;
    data['image'] = image;
    data['status'] = status;
    data['verified'] = verified;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['token'] = token;
    data['fullImage'] = fullImage;
    data['logoImg'] = logoImg;
    return data;
  }
}
