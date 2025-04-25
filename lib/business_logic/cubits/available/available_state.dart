import 'package:flutter/material.dart';

abstract class AvailableState {}

class AvailableInitial extends AvailableState {}

class AvailableLoading extends AvailableState {}

class AvailableLoaded extends AvailableState {
  final List<Map<String, dynamic>> trendingProducts;
  final List<Map<String, dynamic>> onSaleProducts;
  final List<Map<String, dynamic>> productData;
  final Map<String, TextEditingController> controllers;
  final int controllersSummation;
  final Map<String, bool> addToCart;
  final int totalWithOffer;
  final int total;
  final List<Map<String, dynamic>> v7Products; // ✅ أضف هذا

  AvailableLoaded({
    required this.trendingProducts,
    required this.onSaleProducts,
    required this.productData,
    required this.controllers,
    required this.controllersSummation,
    required this.addToCart,
    required this.totalWithOffer,
    required this.total,
    this.v7Products = const [], // ✅ قيمة افتراضية
  });

  @override
  List<Object?> get props => [
        trendingProducts,
        onSaleProducts,
        productData,
        controllers,
        controllersSummation,
        addToCart,
        totalWithOffer,
        total,
        v7Products,
      ];
}

class AvailableError extends AvailableState {
  final String message;

  AvailableError(this.message);

  @override
  List<Object?> get props => [message];
}
