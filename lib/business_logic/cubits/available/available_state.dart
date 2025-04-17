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

  AvailableLoaded({
    required this.trendingProducts,
    required this.onSaleProducts,
    required this.productData,
    required this.controllers,
    required this.controllersSummation,
    required this.addToCart,
    required this.totalWithOffer,
    required this.total,
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
      ];
}

class AvailableError extends AvailableState {
  final String message;

  AvailableError(this.message);

  @override
  List<Object?> get props => [message];
}
