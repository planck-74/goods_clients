import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> cartItemsWithInts = [];
  int summation = 0;
  int totalWithOffer = 0;

  void addToCart(
      Map<String, dynamic> product, TextEditingController controller) {
    cartItems.add({
      'product': product,
      'controller': controller,
    });
  }

  void emitCartInitial() {
    emit(CartInitial());
  }

  void emitCartUpdated() {
    emit(CartUpdated(cartItems, summation, cartItemsWithInts, totalWithOffer));
  }

  void updateCartItemsWithInts() {
    cartItemsWithInts = cartItems.map((item) {
      final controllerValue =
          int.tryParse(item['controller']?.text ?? '0') ?? 0;
      return {
        ...item,
        'controller': controllerValue,
      };
    }).toList();
    updateTotals();
  }

  Future<void> removeFromCart(String docId) async {
    final unprefixedProductId = docId.replaceFirst('product_', '');
    cartItems.removeWhere(
        (item) => item['product']['productId'] == unprefixedProductId);
    emit(CartInitial());
    if (cartItems.isNotEmpty) {
      updateTotals();
    }
  }

  Future<void> saveData(String docId, bool isActive) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setBool(docId, isActive);
  }

  Future<bool> loadData(String key) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? result = sharedPref.getBool(key);
    return result ?? false;
  }

  Future<void> resetProductPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const productKeyPrefix = "product_";
    for (String key in prefs.getKeys()) {
      if (key.startsWith(productKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> removeData(String docId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(docId)) {
      await prefs.remove(docId);
    }
  }

  void addReturnedOrderProducts(List<Map<String, dynamic>> orderProducts) {
    for (var orderProduct in orderProducts) {
      final int quantity = orderProduct['controller'] is int
          ? orderProduct['controller']
          : int.tryParse(orderProduct['controller']?.toString() ?? '0') ?? 0;
      final newController = TextEditingController(text: quantity.toString());
      cartItems.add({
        'product': orderProduct['product'],
        'controller': newController,
      });
    }
    updateTotals();
  }

  int calculateTotal() {
    int sum = 0;
    for (var item in cartItems) {
      int quantity = int.tryParse(item['controller']?.text ?? '0') ?? 0;
      int price = item['product']['price'] ?? 0;
      sum += price * quantity;
    }
    return sum;
  }

  int calculateTotalWithOffer() {
    int sum = 0;
    for (var item in cartItems) {
      int quantity = int.tryParse(item['controller']?.text ?? '0') ?? 0;
      int normalPrice = item['product']['price'] ?? 0;
      bool isOnSale = item['product']['isOnSale'] ?? false;
      if (isOnSale) {
        var offerRaw = item['product']['offerPrice'];
        int offerPrice = offerRaw is int
            ? offerRaw
            : (offerRaw != null ? offerRaw.toDouble().round() : normalPrice);
        int maxOfferQty =
            item['product']['maxOrderQuantityForOffer'] ?? quantity;
        if (quantity <= maxOfferQty) {
          sum += offerPrice * quantity;
        } else {
          int extraQty = quantity - maxOfferQty;
          sum += offerPrice * maxOfferQty + normalPrice * extraQty;
        }
      } else {
        sum += normalPrice * quantity;
      }
    }
    return sum;
  }

  void updateTotals() {
    summation = calculateTotal();
    totalWithOffer = calculateTotalWithOffer();
    emit(CartUpdated(cartItems, summation, cartItemsWithInts, totalWithOffer));
  }
}
