import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String clientId;
  final int itemCount;
  final int total;
  final int totalWithOffer;
  final Timestamp date;
  final String state;
  final int orderCode;
  final List products;

  OrderModel({
    required this.totalWithOffer,
    required this.total,
    required this.clientId,
    required this.itemCount,
    required this.state,
    required this.orderCode,
    required this.date,
    required this.products,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      total: map['total'] ?? 0,
      totalWithOffer: map['total'] ?? 0,
      clientId: map['clientId'] ?? '',
      itemCount: map['itemCount'] ?? '',
      state: map['state'] ?? '',
      orderCode: map['orderCode'] is int ? map['orderCode'] : 0,
      date: map['date'] is Timestamp ? map['date'] : Timestamp.now(),
      products: map['products'] is List ? map['products'] : [],
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'total': total,
      'totalWithOffer': totalWithOffer,
      'itemCount': itemCount,
      'state': state,
      'orderCode': orderCode,
      'date': date,
      'products': products,
    };
  }
}
