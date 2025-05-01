part of 'fetch_trending_on_sale_products_cubit.dart';

@immutable
sealed class FetchTrendingOnSaleProductsState {}

final class FetchTrendingOnSaleProductsInitial
    extends FetchTrendingOnSaleProductsState {}

final class FetchTrendingOnSaleProductsLoading
    extends FetchTrendingOnSaleProductsState {}

final class FetchTrendingOnSaleProductsLoaded
    extends FetchTrendingOnSaleProductsState {
  final List<Map<String, dynamic>> trendingProducts;
  final List<Map<String, dynamic>> onSaleProducts;
  final Map<String, dynamic> productData;
  final List<dynamic> controllers;
  final List<dynamic> controllersSummation;
  final Function addToCart;
  final double totalWithOffer;
  final double total;

  FetchTrendingOnSaleProductsLoaded({
    required this.trendingProducts,
    required this.onSaleProducts,
    required this.productData,
    required this.controllers,
    required this.controllersSummation,
    required this.addToCart,
    required this.totalWithOffer,
    required this.total,
  });
}

final class FetchTrendingOnSaleProductsError
    extends FetchTrendingOnSaleProductsState {
  final String errorMessage;

  FetchTrendingOnSaleProductsError(this.errorMessage);
}
