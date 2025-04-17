import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'available_state.dart';

class AvailableCubit extends Cubit<AvailableState> {
  AvailableCubit() : super(AvailableInitial());

  List<Map<String, dynamic>> trendingProducts = [];
  List<Map<String, dynamic>> onSaleProducts = [];
  List<QueryDocumentSnapshot> availableProducts = [];

  List<Map<String, dynamic>> productData = [];

  List<Map<String, dynamic>> allProducts = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, bool> addToCart = {};

  int controllersSummation = 0;
  bool dataFetched = false;
  List<Map<String, dynamic>> combinedProducts = [];
  int totalWithOffer = 0;
  int total = 0;

  int calculateTotal() {
    int sum = 0;
    for (var entry in controllers.entries) {
      int quantity = int.tryParse(entry.value.text) ?? 0;

      final product = allProducts.firstWhereOrNull(
        (prod) =>
            prod['staticData']['productId'].toString() ==
            entry.key.replaceFirst('product_', ''),
      );
      if (product != null) {
        int price = product['dynamicData']['price'] ?? 0;
        sum += price * quantity;
      }
    }
    return sum;
  }

  int calculateTotalWithOffer() {
    int sum = 0;
    for (var entry in controllers.entries) {
      int quantity = int.tryParse(entry.value.text) ?? 0;
      final product = allProducts.firstWhereOrNull(
        (prod) =>
            prod['staticData']['productId'].toString() ==
            entry.key.replaceFirst('product_', ''),
      );
      if (product != null) {
        int normalPrice = product['dynamicData']['price'] ?? 0;
        var offerRaw = product['dynamicData']['offerPrice'];
        int offerPrice = offerRaw is int
            ? offerRaw
            : (offerRaw != null ? offerRaw.toDouble().round() : normalPrice);
        bool isOnSale = product['dynamicData']['isOnSale'] ?? false;
        if (isOnSale) {
          int maxOfferQty =
              product['dynamicData']['maxOrderQuantityForOffer'] ?? quantity;
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
    }
    return sum;
  }

  void updateTotals() {
    controllersSummation = 0;
    for (var entry in controllers.entries) {
      controllersSummation += int.tryParse(entry.value.text) ?? 0;
    }
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
    ));
  }

  Future<void> fetchCombinedProducts() async {
    if (dataFetched) return;
    emit(AvailableLoading());
    try {
      final userProducts = await available(storeId);
      if (userProducts == null || userProducts.isEmpty) {
        emit(AvailableError('No available products found.'));
        return;
      }
      for (var userProduct in userProducts) {
        var dynamicData = userProduct.data() as Map<String, dynamic>;
        String productId = dynamicData['productId'];
        var staticProduct = await fetchStaticProduct(productId);
        if (staticProduct != null && staticProduct.exists) {
          var staticData = staticProduct.data() as Map<String, dynamic>;
          combinedProducts.add({
            'dynamicData': dynamicData,
            'staticData': staticData,
          });
          String controllerKey = 'product_${staticData['productId']}';
          var controller = TextEditingController(text: '0');
          controllers[controllerKey] = controller;
          addToCart[controllerKey] = false;
          if (dynamicData['isOnSale'] == true) {
            onSaleProducts.add({
              'dynamicData': dynamicData,
              'staticData': staticData,
            });
          }
        }
      }

      allProducts = List.from(combinedProducts);

      productData = List.from(allProducts);
      dataFetched = true;
      emit(AvailableLoaded(
        trendingProducts: trendingProducts,
        onSaleProducts: onSaleProducts,
        productData: productData,
        controllers: controllers,
        controllersSummation: controllersSummation,
        addToCart: addToCart,
        totalWithOffer: totalWithOffer,
        total: total,
      ));
      fetchTrendingProducts();
    } catch (e) {
      emit(AvailableError('Failed to fetch products: $e'));
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>?> available(
      String storeId) async {
    if (storeId.isEmpty) return null;
    try {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');
      QuerySnapshot querySnapshot =
          await productsRef.where('availability', isEqualTo: true).get();
      availableProducts = querySnapshot.docs;
      return availableProducts;
    } catch (e) {
      emit(AvailableError('Error fetching available products: $e'));
      return null;
    }
  }

  Future<DocumentSnapshot?> fetchStaticProduct(String productId) async {
    try {
      final CollectionReference ref =
          FirebaseFirestore.instance.collection('products');
      final QuerySnapshot snapshot =
          await ref.where('productId', isEqualTo: productId).get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    } catch (e) {
      emit(AvailableError('Error fetching static product: $e'));
      return null;
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      productData = List.from(allProducts);
    } else {
      productData = allProducts.where((product) {
        String productName =
            product['staticData']['name']?.toString().toLowerCase() ?? "";
        return productName.contains(query.toLowerCase());
      }).toList();
    }
    emit(AvailableLoaded(
      trendingProducts: trendingProducts,
      onSaleProducts: onSaleProducts,
      productData: productData,
      controllers: controllers,
      controllersSummation: controllersSummation,
      addToCart: addToCart,
      totalWithOffer: totalWithOffer,
      total: total,
    ));
  }

  void filterProductsByClassification(String classification) {
    if (classification == 'كل') {
      productData = List.from(allProducts);
    } else {
      productData = allProducts.where((product) {
        return product['staticData']['classification'] == classification;
      }).toList();
    }
    emit(AvailableLoaded(
      trendingProducts: trendingProducts,
      onSaleProducts: onSaleProducts,
      productData: productData,
      controllers: controllers,
      controllersSummation: controllersSummation,
      addToCart: addToCart,
      totalWithOffer: totalWithOffer,
      total: total,
    ));
  }

  Future<void> fetchTrendingProducts() async {
    emit(AvailableLoading());
    try {
      if (allProducts.isEmpty) {
        emit(AvailableError('No products available.'));
        return;
      }
      trendingProducts = List.from(allProducts)
        ..sort((a, b) {
          int salesCountA = a['staticData']?['salesCount'] ?? 0;
          int salesCountB = b['staticData']?['salesCount'] ?? 0;
          return salesCountB.compareTo(salesCountA);
        });
      trendingProducts = trendingProducts.take(10).toList();
      emit(AvailableLoaded(
        trendingProducts: trendingProducts,
        onSaleProducts: onSaleProducts,
        productData: productData,
        controllers: controllers,
        controllersSummation: controllersSummation,
        addToCart: addToCart,
        totalWithOffer: totalWithOffer,
        total: total,
      ));
    } catch (e) {
      emit(AvailableError('Error processing trending products: $e'));
    }
  }

  void markProductAdded(String productId) {
    addToCart[productId] = true;
    _emitLoadedState();
  }

  void markProductRemoved(String productId) {
    addToCart[productId] = false;
    _emitLoadedState();
  }

  void _emitLoadedState() {
    if (state is AvailableLoaded) {
      final current = state as AvailableLoaded;
      emit(AvailableLoaded(
        trendingProducts: current.trendingProducts,
        onSaleProducts: current.onSaleProducts,
        productData: productData,
        controllers: controllers,
        controllersSummation: controllersSummation,
        addToCart: addToCart,
        totalWithOffer: totalWithOffer,
        total: total,
      ));
    }
  }

  @override
  Future<void> close() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    return super.close();
  }
}
