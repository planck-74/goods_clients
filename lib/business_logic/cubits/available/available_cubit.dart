import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'available_state.dart';

class AvailableCubit extends Cubit<AvailableState> {
  AvailableCubit() : super(AvailableInitial());
  final int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool isFetchingMore = false;
  bool hasMore = true;
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> onSaleProducts = [];
  List<Map<String, dynamic>> trendingProducts = [];
  bool isLoadingMore = false;
  String currentClassification = 'كل';

  List<Map<String, dynamic>> productData = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> addToCart = {};

  int controllersSummation = 0;
  int total = 0;
  int totalWithOffer = 0;

  bool dataFetched = false;

  // دالة للتحقق مما إذا كانت البيانات قد تم تحميلها بالفعل
  bool get isDataLoaded {
    return dataFetched &&
        (state is AvailableLoaded) &&
        currentClassification == 'كل';
  }

  int calculateTotal() {
    int sum = 0;
    for (var entry in controllers.entries) {
      int qty = int.tryParse(entry.value.text) ?? 0;
      final prod = allProducts.firstWhereOrNull((p) =>
          p['productId'].toString() == entry.key.replaceFirst('product_', ''));
      if (prod != null) {
        sum += (prod['price'] as int? ?? 0) * qty;
      }
    }
    return sum;
  }

  int calculateTotalWithOffer() {
    int sum = 0;
    for (var entry in controllers.entries) {
      int qty = int.tryParse(entry.value.text) ?? 0;
      final prod = allProducts.firstWhereOrNull((p) =>
          p['productId'].toString() == entry.key.replaceFirst('product_', ''));
      if (prod != null) {
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
    }
    return sum;
  }

  void updateTotals() {
    controllersSummation = controllers.values
        .map((c) => int.tryParse(c.text) ?? 0)
        .fold(0, (a, b) => a + b);
    total = calculateTotal();
    totalWithOffer = calculateTotalWithOffer();

    emit(AvailableLoaded(
        trendingProducts: trendingProducts,
        onSaleProducts: onSaleProducts,
        productData: productData,
        controllers: controllers,
        controllersSummation: controllersSummation,
        addToCart: addToCart,
        totalWithOffer: totalWithOffer,
        total: total,
        isLoadingMore: isFetchingMore));
  }

  // حفظ حالة المنتجات المضافة للسلة قبل التحديث
  Map<String, bool> _preserveCartState() {
    return Map<String, bool>.from(addToCart);
  }

  // استعادة حالة المنتجات المضافة للسلة بعد التحديث
  void _restoreCartState(Map<String, bool> savedCartState) {
    // نحدث حالة السلة مع الحفاظ على القيم السابقة
    savedCartState.forEach((key, isAdded) {
      if (isAdded && addToCart.containsKey(key)) {
        addToCart[key] = true;
      }
    });
  }

  // حفظ قيم المنتجات (الكميات) قبل التحديث
  Map<String, String> _preserveControllerValues() {
    Map<String, String> values = {};
    controllers.forEach((key, controller) {
      values[key] = controller.text;
    });
    return values;
  }

  // استعادة قيم المنتجات (الكميات) بعد التحديث
  void _restoreControllerValues(Map<String, String> savedValues) {
    savedValues.forEach((key, value) {
      if (controllers.containsKey(key)) {
        controllers[key]!.text = value;
      }
    });
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state is AvailableLoaded &&
        currentClassification == 'كل') {
      return;
    }

    final savedCartState = _preserveCartState();
    final savedControllerValues = _preserveControllerValues();

    emit(AvailableLoading());

    allProducts.clear();
    productData.clear();
    lastDocument = null;
    hasMore = true;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true)
          .orderBy('name')
          .limit(pageSize)
          .get();

      if (snap.docs.isEmpty) {
        emit(AvailableError('لا توجد منتجات متاحة.'));
        return;
      }

      lastDocument = snap.docs.last;

      // هنا: احتفظ بالـ controllers القديمة أو أنشئ جديدة إذا لم تكن موجودة
      for (var doc in snap.docs) {
        final data = doc.data();
        final key = 'product_${data['productId']}';

        controllers.putIfAbsent(key, () => TextEditingController());
        controllers[key]!.text = savedControllerValues[key] ?? '0';

        addToCart.putIfAbsent(key, () => savedCartState[key] ?? false);

        allProducts.add(data);
        if (data['isOnSale'] == true) onSaleProducts.add(data);
      }

      productData = List.from(allProducts);
      dataFetched = true;
      currentClassification = 'كل';

      await fetchTrendingProducts();
      await fetchOnSaleProducts();
      updateTotals();
    } catch (e) {
      emit(AvailableError('فشل في تحميل المنتجات: $e'));
    }
  }

  Future<void> fetchProductsByClassification(String classification,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && classification == currentClassification) return;

    final savedCartState = _preserveCartState();
    final savedControllerValues = _preserveControllerValues();

    emit(AvailableLoading());

    allProducts.clear();
    productData.clear();
    lastDocument = null;
    hasMore = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true);

      if (classification != 'كل') {
        query = query.where('classification', isEqualTo: classification);
      }

      final snap = await query.orderBy('name').limit(pageSize).get();

      if (snap.docs.isEmpty) {
        currentClassification = classification;
        emit(AvailableLoaded(
          trendingProducts: trendingProducts,
          onSaleProducts: onSaleProducts,
          productData: const [],
          controllers: controllers,
          controllersSummation: 0,
          addToCart: addToCart,
          totalWithOffer: 0,
          total: 0,
          isLoadingMore: false,
        ));
        return;
      }

      lastDocument = snap.docs.last;

      // هنا أيضاً نحتفظ بالكنترولرات القديمة أو ننشئ جديدة
      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final key = 'product_${data['productId']}';

        controllers.putIfAbsent(key, () => TextEditingController());
        controllers[key]!.text = savedControllerValues[key] ?? '0';

        addToCart.putIfAbsent(key, () => savedCartState[key] ?? false);

        allProducts.add(data);
        if (data['isOnSale'] == true) onSaleProducts.add(data);
      }

      productData = List.from(allProducts);
      currentClassification = classification;
      updateTotals();
    } catch (e) {
      emit(AvailableError('فشل في تحميل المنتجات حسب التصنيف: $e'));
    }
  }

  // Search products by name from Firebase
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      if (currentClassification == 'كل') {
        fetchProducts();
      } else {
        fetchProductsByClassification(currentClassification);
      }
      return;
    }

    // حفظ حالة السلة والكميات قبل التحديث
    final savedCartState = _preserveCartState();
    final savedControllerValues = _preserveControllerValues();

    emit(AvailableLoading());

    // Reset pagination
    lastDocument = null;
    hasMore = true;

    try {
      // We can't directly search by substring in Firestore
      // This uses a prefix search on the lowercased name field
      // For more advanced search, consider using Algolia or a custom search solution
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true)
          .orderBy('name')
          .startAt([query.toLowerCase()])
          .endAt(['${query.toLowerCase()}\uf8ff'])
          .limit(pageSize)
          .get();

      // Reset products
      allProducts = [];
      productData = [];

      // إعادة تعيين قواميس controllers و addToCart
      Map<String, TextEditingController> newControllers = {};
      Map<String, bool> newAddToCart = {};

      if (snap.docs.isEmpty) {
        controllers = newControllers;
        addToCart = newAddToCart;

        emit(AvailableLoaded(
            trendingProducts: trendingProducts,
            onSaleProducts: onSaleProducts,
            productData: const [],
            controllers: controllers,
            controllersSummation: 0,
            addToCart: addToCart,
            totalWithOffer: 0,
            total: 0,
            isLoadingMore: false));
        return;
      }

      lastDocument = snap.docs.last;

      for (var doc in snap.docs) {
        final data = doc.data();
        final pid = data['productId'].toString();
        final key = 'product_$pid';

        // إنشاء controller جديد مع قيمة افتراضية أو استخدام القيمة المحفوظة
        newControllers[key] =
            TextEditingController(text: savedControllerValues[key] ?? '0');

        // إنشاء حالة سلة جديدة مع القيمة الافتراضية false أو استخدام الحالة المحفوظة
        newAddToCart[key] = savedCartState[key] ?? false;

        allProducts.add(data);
        if (data['isOnSale'] == true) onSaleProducts.add(data);
      }

      // استبدال القواميس القديمة بالقواميس الجديدة
      controllers = newControllers;
      addToCart = newAddToCart;

      productData = List.from(allProducts);
      updateTotals();
    } catch (e) {
      emit(AvailableError('فشل في البحث عن المنتجات: $e'));
    }
  }

  // This method now calls the Firebase fetch method with support for forced refresh
  void filterProductsByClassification(String cls, {bool forceRefresh = false}) {
    fetchProductsByClassification(cls, forceRefresh: forceRefresh);
  }

  void markProductAdded(String key) {
    addToCart[key] = true;
    updateTotals();
  }

  void markProductRemoved(String key) {
    addToCart[key] = false;
    updateTotals();
  }

  @override
  Future<void> close() {
    for (var c in controllers.values) {
      c.dispose();
    }
    return super.close();
  }

  Future<void> fetchMoreProducts() async {
    if (isFetchingMore || !hasMore || lastDocument == null) return;

    // حفظ حالة السلة والكميات قبل التحديث
    final savedCartState = _preserveCartState();
    final savedControllerValues = _preserveControllerValues();

    isFetchingMore = true;
    updateTotals();

    try {
      Query query = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true);

      // Apply classification filter if not "all"
      if (currentClassification != 'كل') {
        query = query.where('classification', isEqualTo: currentClassification);
      }

      // Add ordering, pagination and limit
      query = query
          .orderBy('name')
          .startAfterDocument(lastDocument!)
          .limit(pageSize);

      final snap = await query.get();

      if (snap.docs.isEmpty) {
        hasMore = false;
        isFetchingMore = false;
        return;
      }

      lastDocument = snap.docs.last;

      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final pid = data['productId'].toString();
        final key = 'product_$pid';

        // إضافة controller جديد للمنتج مع قيمة افتراضية أو استخدام القيمة المحفوظة
        controllers[key] =
            TextEditingController(text: savedControllerValues[key] ?? '0');

        // إضافة حالة سلة جديدة للمنتج مع القيمة الافتراضية false أو استخدام الحالة المحفوظة
        addToCart[key] = savedCartState[key] ?? false;

        allProducts.add(data);
        if (data['isOnSale'] == true) onSaleProducts.add(data);
      }

      productData = List.from(allProducts);
      updateTotals();
    } catch (e) {
      emit(AvailableError('فشل في تحميل المزيد من المنتجات: $e'));
    }

    isFetchingMore = false;
  }

  Future<void> fetchOnSaleProducts({bool forceRefresh = false}) async {
    Map<String, bool> savedCartState = {};
    Map<String, String> savedControllerValues = {};

    if (forceRefresh) {
      savedCartState = _preserveCartState();
      savedControllerValues = _preserveControllerValues();
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true)
          .where('isOnSale', isEqualTo: true)
          .orderBy('offerPrice')
          .limit(20)
          .get();

      onSaleProducts = snap.docs.map((doc) {
        final data = doc.data();
        final pid = data['productId'].toString();
        final key = 'product_$pid';

        // تأكد من وجود controller و addToCart
        controllers.putIfAbsent(
          key,
          () => TextEditingController(
              text: forceRefresh ? (savedControllerValues[key] ?? '0') : '0'),
        );
        addToCart.putIfAbsent(
          key,
          () => forceRefresh ? (savedCartState[key] ?? false) : false,
        );

        // إضافة المنتج إذا لم يكن موجودًا مسبقًا
        if (!allProducts.any((p) => p['productId'] == pid)) {
          allProducts.add(data);
          if (currentClassification == 'كل' ||
              currentClassification == data['classification']) {
            productData.add(data);
          }
        }

        return data;
      }).toList();

      updateTotals();
    } catch (e) {
      onSaleProducts = [];
      print('خطأ في تحميل العروض: $e');
    }
  }

  Future<void> fetchTrendingProducts({bool forceRefresh = false}) async {
    Map<String, bool> savedCartState = {};
    Map<String, String> savedControllerValues = {};

    if (forceRefresh) {
      savedCartState = _preserveCartState();
      savedControllerValues = _preserveControllerValues();
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('availability', isEqualTo: true)
          .orderBy('salesCount', descending: true)
          .limit(20)
          .get();

      trendingProducts = snap.docs.map((doc) {
        final data = doc.data();
        final pid = data['productId'].toString();
        final key = 'product_$pid';

        controllers.putIfAbsent(
          key,
          () => TextEditingController(
              text: forceRefresh ? (savedControllerValues[key] ?? '0') : '0'),
        );
        addToCart.putIfAbsent(
          key,
          () => forceRefresh ? (savedCartState[key] ?? false) : false,
        );

        return data;
      }).toList();
    } catch (e) {
      trendingProducts = [];
      print('خطأ في تحميل المنتجات الأكثر مبيعًا: $e');
    }
  }

  // دالة لتحديث جميع البيانات دفعة واحدة - مفيدة لعملية التحديث بالسحب
  Future<void> refreshAllData() async {
    // حفظ حالة السلة والكميات قبل التحديث الكامل
    final savedCartState = _preserveCartState();
    final savedControllerValues = _preserveControllerValues();

    emit(AvailableLoading());

    try {
      // تحديث كل البيانات بالترتيب
      await fetchProducts(forceRefresh: true);
      await fetchTrendingProducts(forceRefresh: true);
      await fetchOnSaleProducts(forceRefresh: true);

      // استعادة حالة السلة والكميات بعد التحديث
      _restoreCartState(savedCartState);
      _restoreControllerValues(savedControllerValues);

      // تحديث الواجهة
      updateTotals();
    } catch (e) {
      emit(AvailableError('فشل في تحديث البيانات: $e'));
    }
  }
}
