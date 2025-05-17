import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String name;
  final String description;
  final String barcode;
  final String classification;
  final int price;
  final bool isOnSale;
  final int offerPrice;
  final bool availability;
  final int maxOrderQuantityForOffer;
  final int salesCount;
  final String imageUrl;
  final Map<String, dynamic> additionalData;

  const Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.barcode,
    required this.classification,
    required this.price,
    required this.isOnSale,
    required this.offerPrice,
    required this.availability,
    required this.maxOrderQuantityForOffer,
    required this.salesCount,
    required this.imageUrl,
    required this.additionalData,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      barcode: map['barcode'] ?? '',
      classification: map['classification'] ?? '',
      price: map['price'] as int? ?? 0,
      isOnSale: map['isOnSale'] as bool? ?? false,
      offerPrice: map['offerPrice'] as int? ?? 0,
      availability: map['availability'] as bool? ?? true,
      maxOrderQuantityForOffer: map['maxOrderQuantityForOffer'] as int? ?? 999,
      salesCount: map['salesCount'] as int? ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      // Store any additional fields to support future fields
      additionalData: Map<String, dynamic>.from(map)
        ..removeWhere((key, value) => [
              'productId',
              'name',
              'description',
              'barcode',
              'classification',
              'price',
              'isOnSale',
              'offerPrice',
              'availability',
              'maxOrderQuantityForOffer',
              'salesCount',
              'imageUrl',
            ].contains(key)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'barcode': barcode,
      'classification': classification,
      'price': price,
      'isOnSale': isOnSale,
      'offerPrice': offerPrice,
      'availability': availability,
      'maxOrderQuantityForOffer': maxOrderQuantityForOffer,
      'salesCount': salesCount,
      'imageUrl': imageUrl,
      ...additionalData,
    };
  }

  // Calculate effective price (with offer applied if applicable)
  int calculateEffectivePrice(int quantity) {
    if (!isOnSale) return price * quantity;

    if (quantity <= maxOrderQuantityForOffer) {
      return offerPrice * quantity;
    } else {
      // Apply offer for max offer quantity, regular price for the rest
      return offerPrice * maxOrderQuantityForOffer +
          price * (quantity - maxOrderQuantityForOffer);
    }
  }

  // Calculate savings compared to regular price
  int calculateSavings(int quantity) {
    if (!isOnSale) return 0;

    int regularTotal = price * quantity;
    int offerTotal = calculateEffectivePrice(quantity);
    return regularTotal - offerTotal;
  }

  // Get discount percentage
  double get discountPercentage {
    if (!isOnSale || price == 0) return 0.0;
    return ((price - offerPrice) / price) * 100;
  }

  @override
  List<Object?> get props => [
        productId,
        name,
        description,
        barcode,
        classification,
        price,
        isOnSale,
        offerPrice,
        availability,
        maxOrderQuantityForOffer,
        salesCount,
        imageUrl,
      ];
}

// Class to hold query results with pagination info
class ProductQueryResult {
  final List<Map<String, dynamic>> products;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  ProductQueryResult({
    required this.products,
    this.lastDocument,
    this.hasMore = false,
  });
}
