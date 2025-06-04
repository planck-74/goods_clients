import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepository {
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> onSaleProducts = [];
  List<Map<String, dynamic>> trendingProducts = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> addToCart = {};

  ProductRepository();

  Future<List<Map<String, dynamic>>> fetchProducts({
    String classification = 'كل',
    String? searchQuery,
  }) async {
    allProducts = [];

    Query query = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .where('availability', isEqualTo: true);

    if (classification != 'كل') {
      query = query.where('classification', isEqualTo: classification);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .orderBy('name')
          .startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    } else {
      query = query.orderBy('name');
    }

    final snap = await query.get();
    allProducts = snap.docs
        .map((doc) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            if (!data.containsKey('minOrderQuantity') ||
                data['minOrderQuantity'] == null) {
              data['minOrderQuantity'] = 1;
            }
            return data;
          } else if (data is Map) {
            // Convert Map<dynamic, dynamic> to Map<String, dynamic>
            final fixed = <String, dynamic>{};
            data.forEach((key, value) {
              fixed[key.toString()] = value;
            });
            if (!fixed.containsKey('minOrderQuantity') ||
                fixed['minOrderQuantity'] == null) {
              fixed['minOrderQuantity'] = 1;
            }
            return fixed;
          }
          return <String, dynamic>{};
        })
        .toList()
        .cast<Map<String, dynamic>>();

    // تهيئة التحكم للمنتجات
    _initControllersForProducts(allProducts);

    return allProducts;
  }

  Future<List<Map<String, dynamic>>> fetchOnSaleProducts() async {
    final snap = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .where('availability', isEqualTo: true)
        .where('isOnSale', isEqualTo: true)
        .orderBy('offerPrice')
        .limit(20)
        .get();

    onSaleProducts = snap.docs.map((doc) => doc.data()).toList();

    // تهيئة التحكم للمنتجات المخفضة
    _initControllersForProducts(onSaleProducts);

    return onSaleProducts;
  }

  Future<List<Map<String, dynamic>>> fetchTrendingProducts() async {
    final snap = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .where('availability', isEqualTo: true)
        .orderBy('salesCount', descending: true)
        .limit(20)
        .get();

    trendingProducts = snap.docs.map((doc) => doc.data()).toList();

    // تهيئة التحكم للمنتجات الرائجة
    _initControllersForProducts(trendingProducts);

    return trendingProducts;
  }

  void _initControllersForProducts(List<Map<String, dynamic>> products) {
    for (var product in products) {
      final productId = 'product_${product['productId']}';
      setController(productId, (product['minOrderQuantity'] ?? '1').toString());
    }
  }

  void setController(String key, String value) {
    controllers.putIfAbsent(key, () => TextEditingController());
    controllers[key]!.text = value;
  }

  void setAddToCart(String key, bool value) {
    addToCart[key] = value;
  }

  int calculateTotal() {
    int sum = 0;
    controllers.forEach((key, controller) {
      int qty = int.tryParse(controller.text) ?? 0;
      Map<String, dynamic> prod = _findProductById(key);

      if (prod.isNotEmpty) {
        sum += (prod['price'] as int? ?? 0) * qty;
      }
    });
    return sum;
  }

  int calculateTotalWithOffer() {
    int sum = 0;
    controllers.forEach((key, controller) {
      int qty = int.tryParse(controller.text) ?? 0;
      Map<String, dynamic> prod = _findProductById(key);

      if (prod.isNotEmpty) {
        int normal = prod['price'] as int? ?? 0;
        bool isOnSale = prod['isOnSale'] as bool? ?? false;
        int offer = isOnSale ? (prod['offerPrice'] as int? ?? normal) : normal;

        if (isOnSale) {
          int maxQty = prod['maxOrderQuantityForOffer'] as int? ?? qty;
          if (qty <= maxQty) {
            sum += offer * qty;
          } else {
            sum += offer * maxQty + normal * (qty - maxQty);
          }
        } else {
          sum += normal * qty;
        }
      }
    });
    return sum;
  }

  Map<String, dynamic> _findProductById(String key) {
    // البحث عن المنتج في جميع القوائم
    Map<String, dynamic> product = allProducts.firstWhere(
      (p) => 'product_${p['productId']}' == key,
      orElse: () => {},
    );

    if (product.isEmpty) {
      product = onSaleProducts.firstWhere(
        (p) => 'product_${p['productId']}' == key,
        orElse: () => {},
      );
    }

    if (product.isEmpty) {
      product = trendingProducts.firstWhere(
        (p) => 'product_${p['productId']}' == key,
        orElse: () => {},
      );
    }

    return product;
  }

  Future<void> saveCartState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // حفظ حالة العربة (أضيف إلى العربة أم لا)
    for (var entry in addToCart.entries) {
      await prefs.setBool(entry.key, entry.value);
    }

    // حفظ كميات المنتجات
    for (var entry in controllers.entries) {
      await prefs.setString('${entry.key}_qty', entry.value.text);
    }
  }

  Future<void> loadCartState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // تحميل حالة العربة
    for (var key in controllers.keys) {
      addToCart[key] = prefs.getBool(key) ?? false;

      // استرجاع الكمية المحفوظة إن وجدت
      String? savedQty = prefs.getString('${key}_qty');
      if (savedQty != null) {
        controllers[key]?.text = savedQty;
      }
    }
  }

  Future<void> resetProductPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const productKeyPrefix = "product_";

    for (String key in prefs.getKeys()) {
      if (key.startsWith(productKeyPrefix)) {
        await prefs.remove(key);
        await prefs.remove('${key}_qty');
      }
    }

    // إعادة تعيين المتغيرات المحلية أيضًا
    controllers.clear();
    addToCart.clear();
  }
}
