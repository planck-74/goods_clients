import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'fetch_trending_on_sale_products_state.dart';

class FetchTrendingOnSaleProductsCubit
    extends Cubit<FetchTrendingOnSaleProductsState> {
  List<Map<String, dynamic>> trendingProducts = [];
  List<Map<String, dynamic>> onSaleProducts = [];
  Map<String, dynamic> productData = {};
  List<dynamic> controllers = [];
  List<dynamic> controllersSummation = [];
  Function addToCart = () {};
  double totalWithOffer = 0.0;
  double total = 0.0;

  FetchTrendingOnSaleProductsCubit()
      : super(FetchTrendingOnSaleProductsInitial());

  Future<void> fetchTrendingProducts() async {
    emit(FetchTrendingOnSaleProductsLoading());
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('trending_products')
          .get();
      trendingProducts = snapshot.docs.map((doc) => doc.data()).toList();

      emit(FetchTrendingOnSaleProductsLoaded(
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
      emit(FetchTrendingOnSaleProductsError(
          'Error processing trending products: $e'));
    }
  }

  Future<void> fetchOnSaleProducts() async {
    emit(FetchTrendingOnSaleProductsLoading());
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('on_sale_products').get();
      onSaleProducts = snapshot.docs.map((doc) => doc.data()).toList();

      emit(FetchTrendingOnSaleProductsLoaded(
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
      emit(FetchTrendingOnSaleProductsError(
          'Error processing trending products: $e'));
    }
  }
}
