import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  List<Product> cart = [];
  double totalCartValue = 0;

  int get total => cart.length;
  int totalQty = 0;
  int? restId;
  String? restName;

  void addProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    print(index);

    cart.add(product);
    calculateTotal();
    notifyListeners();
  }

  int getTotalQty() {
    totalQty = 0;
    for (var f in cart) {
      totalQty += f.qty!;
    }
    return totalQty;
  }

  int? getRestId() {
    for (var f in cart) {
      restId = f.restaurantsId;
    }
    return restId;
  }

  String? getRestName() {
    for (var f in cart) {
      restName = f.restaurantsName;
    }
    return restName;
  }

  void removeProduct(id) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].qty = 1;
    cart.removeWhere((item) => item.id == id);
    calculateTotal();
    notifyListeners();
  }

  void updateProduct(id, qty) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].qty = qty;
    if (cart[index].qty == 0) removeProduct(id);
    calculateTotal();
    notifyListeners();
  }

  void updateProductPrice(id, price, qty) {
    int index = cart.indexWhere((i) => i.id == id);
    cart[index].price = price * qty;
    cart[index].tempPrice = price;

    notifyListeners();
  }

  void clearCart() {
    for (var f in cart) {
      f.qty = 1;
    }
    cart = [];
    totalCartValue = 0;
    notifyListeners();
  }

  void calculateTotal() {
    totalCartValue = 0;
    for (var f in cart) {
      totalCartValue += f.price! * f.qty!;
    }
  }
}

class Product {
  int? id;
  String? title;
  String? imgUrl;
  String? type;
  double? price;
  int? qty;
  int? restaurantsId;
  String? restaurantsName;
  String? restaurantImage;
  String? restaurantAddress;
  String? restaurantKm;
  String? restaurantEstimatedTime;
  String? foodCustomization;
  int? isRepeatCustomization;
  int? isCustomization;
  int? itemQty;
  double? tempPrice;

  Product({
    this.id,
    this.title,
    this.price,
    this.qty,
    this.imgUrl,
    this.type,
    this.restaurantsId,
    this.restaurantsName,
    this.restaurantImage,
    this.foodCustomization,
    this.isRepeatCustomization,
    this.isCustomization,
    this.itemQty,
    this.tempPrice,
    this.restaurantAddress,
    this.restaurantKm,
    this.restaurantEstimatedTime,
  });
}
