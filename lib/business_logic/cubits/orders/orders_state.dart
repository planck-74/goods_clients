abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  List<Map<String, dynamic>> newOrders;
  List<Map<String, dynamic>> previousOrders;

  OrdersLoaded(this.newOrders, this.previousOrders);
}

class OrdersError extends OrdersState {
  OrdersError();
}
