import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'products';

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all available products with pagination
  Future<ProductQueryResult> getAvailableProducts({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionPath)
          .where('availability', isEqualTo: true)
          .orderBy('salesCount', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot snapshot = await query.get();
      final List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) =>
              {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
          .toList();

      return ProductQueryResult(
        products: products,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length >= limit,
      );
    } catch (e) {
      print('Error fetching available products: $e');
      rethrow;
    }
  }

  // Get products by classification with pagination
  Future<ProductQueryResult> getProductsByClassification({
    required String classification,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionPath)
          .where('availability', isEqualTo: true)
          .where('classification', isEqualTo: classification)
          .orderBy('salesCount', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot snapshot = await query.get();
      final List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) =>
              {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
          .toList();

      return ProductQueryResult(
        products: products,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length >= limit,
      );
    } catch (e) {
      print('Error fetching products by classification: $e');
      rethrow;
    }
  }

  // Search products by name
  Future<ProductQueryResult> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      // Firebase doesn't support native text search
      // Using startAt and endAt for prefix search
      String searchLower = query.toLowerCase();
      String searchUpper = searchLower + '\uf8ff';

      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('availability', isEqualTo: true)
          .where('nameLowerCase', isGreaterThanOrEqualTo: searchLower)
          .where('nameLowerCase', isLessThanOrEqualTo: searchUpper)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) =>
              {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
          .toList();

      return ProductQueryResult(
        products: products,
        hasMore: false, // Simple search doesn't support pagination
      );
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  // Get trending products (most sales)
  Future<ProductQueryResult> getTrendingProducts({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('availability', isEqualTo: true)
          .orderBy('salesCount', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) =>
              {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
          .toList();

      return ProductQueryResult(
        products: products,
        hasMore: false,
      );
    } catch (e) {
      print('Error fetching trending products: $e');
      rethrow;
    }
  }

  // Get products on sale
  Future<ProductQueryResult> getOnSaleProducts({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('availability', isEqualTo: true)
          .where('isOnSale', isEqualTo: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> products = snapshot.docs
          .map((doc) =>
              {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
          .toList();

      return ProductQueryResult(
        products: products,
        hasMore: false,
      );
    } catch (e) {
      print('Error fetching sale products: $e');
      rethrow;
    }
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      return {...doc.data() as Map<String, dynamic>, 'productId': doc.id};
    } catch (e) {
      print('Error fetching product by ID: $e');
      rethrow;
    }
  }

  // Get multiple products by IDs (for cart restoration)
  Future<List<Map<String, dynamic>>> getProductsByIds(
      List<String> productIds) async {
    if (productIds.isEmpty) return [];

    try {
      final List<Map<String, dynamic>> products = [];

      // Firestore has a limit on "in" queries, so batch them if needed
      const int batchSize = 10;

      for (int i = 0; i < productIds.length; i += batchSize) {
        int end = (i + batchSize < productIds.length)
            ? i + batchSize
            : productIds.length;
        List<String> batch = productIds.sublist(i, end);

        final QuerySnapshot snapshot = await _firestore
            .collection(_collectionPath)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        products.addAll(snapshot.docs
            .map((doc) =>
                {...doc.data() as Map<String, dynamic>, 'productId': doc.id})
            .toList());
      }

      return products;
    } catch (e) {
      print('Error fetching products by IDs: $e');
      rethrow;
    }
  }

  // Load saved cart items from SharedPreferences
  Future<Map<String, int>> getSavedCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> savedItems = {};

      for (String key in prefs.getKeys()) {
        if (key.startsWith('cart_item_')) {
          String productId = key.replaceFirst('cart_item_', '');
          int quantity = prefs.getInt(key) ?? 0;

          if (quantity > 0) {
            savedItems[productId] = quantity;
          }
        }
      }

      return savedItems;
    } catch (e) {
      print('Error loading saved cart items: $e');
      return {};
    }
  }

  // Update product sales count when order is completed
  Future<void> updateProductSalesCounts(
      Map<String, int> productQuantities) async {
    try {
      final batch = _firestore.batch();

      for (var entry in productQuantities.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        final docRef = _firestore.collection(_collectionPath).doc(productId);
        batch.update(docRef, {
          'salesCount': FieldValue.increment(quantity),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error updating product sales counts: $e');
      rethrow;
    }
  }
}
