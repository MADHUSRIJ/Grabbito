class SinglePackageOrder {
  bool? success;
  Data? data;

  SinglePackageOrder({this.success, this.data});

  SinglePackageOrder.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? packageId;
  int? shopId;
  int? categoryId;
  int? userId;
  int? amount;
  int? tax;
  String? paymentType;
  String? paymentStatus;
  String? pickupLocation;
  String? dropupLocation;
  String? orderStatus;
  int? weight;
  String? cancelReason;
  String? cancelBy;
  String? completedDate;
  int? deliveryPersonId;
  String? date;
  String? time;
  Deliveryperson? deliveryperson;
  Category? category;

  Data(
      {this.id,
        this.packageId,
        this.shopId,
        this.categoryId,
        this.userId,
        this.amount,
        this.tax,
        this.paymentType,
        this.paymentStatus,
        this.pickupLocation,
        this.dropupLocation,
        this.orderStatus,
        this.weight,
        this.cancelReason,
        this.cancelBy,
        this.completedDate,
        this.deliveryPersonId,
        this.date,
        this.time,
        this.deliveryperson,
        this.category});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    shopId = json['shop_id'];
    categoryId = json['category_id'];
    userId = json['user_id'];
    amount = json['amount'];
    tax = json['tax'];
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
    pickupLocation = json['pickup_location'];
    dropupLocation = json['dropup_location'];
    orderStatus = json['order_status'];
    weight = json['weight'];
    cancelReason = json['cancel_reason'];
    cancelBy = json['cancel_by'];
    completedDate = json['completed_date'];
    deliveryPersonId = json['delivery_person_id'];
    date = json['date'];
    time = json['time'];
    deliveryperson = json['deliveryperson'] != null
        ? Deliveryperson.fromJson(json['deliveryperson'])
        : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['shop_id'] = shopId;
    data['category_id'] = categoryId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['tax'] = tax;
    data['payment_type'] = paymentType;
    data['payment_status'] = paymentStatus;
    data['pickup_location'] = pickupLocation;
    data['dropup_location'] = dropupLocation;
    data['order_status'] = orderStatus;
    data['weight'] = weight;
    data['cancel_reason'] = cancelReason;
    data['cancel_by'] = cancelBy;
    data['completed_date'] = completedDate;
    data['delivery_person_id'] = deliveryPersonId;
    data['date'] = date;
    data['time'] = time;
    if (deliveryperson != null) {
      data['deliveryperson'] = deliveryperson!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}

class Deliveryperson {
  int? id;
  String? name;
  String? phone;
  String? image;
  String? fullImage;

  Deliveryperson({this.id, this.name, this.phone, this.image, this.fullImage});

  Deliveryperson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['image'] = image;
    data['fullImage'] = fullImage;
    return data;
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  Category.fromJson(Map<String, dynamic> json) {
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
