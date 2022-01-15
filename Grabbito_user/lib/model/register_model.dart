class RegisterModel {
  bool? success;
  Data? data;
  String? msg;

  RegisterModel({this.success, this.data, this.msg});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  String? name;
  String? email;
  String? phone;
  String? phoneCode;
  int? status;
  String? image;
  int? verified;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? otp;
  String? fullImage;
  String? logoImg;

  Data(
      {this.name,
      this.email,
      this.phone,
      this.phoneCode,
      this.status,
      this.image,
      this.verified,
      this.updatedAt,
      this.createdAt,
      this.id,
      this.otp,
      this.fullImage,
      this.logoImg});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    status = json['status'];
    image = json['image'];
    verified = json['verified'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    otp = json['otp'];
    fullImage = json['fullImage'];
    logoImg = json['logoImg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['status'] = status;
    data['image'] = image;
    data['verified'] = verified;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['otp'] = otp;
    data['fullImage'] = fullImage;
    data['logoImg'] = logoImg;
    return data;
  }
}
