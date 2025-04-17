abstract class CartState {}

class CartInitial extends CartState {}

class CartUpdated extends CartState {
  final List<Map<String, dynamic>> cartItems;
  final int summation;
  final List<Map<String, dynamic>> cartItemsWithInts;
  final int totalWithOffer;

  CartUpdated(
    this.cartItems,
    this.summation,
    this.cartItemsWithInts,
    this.totalWithOffer,
  );
}
