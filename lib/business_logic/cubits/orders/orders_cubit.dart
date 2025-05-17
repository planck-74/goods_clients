import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_state.dart';
import 'package:goods_clients/data/models/order_model.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> newOrders = [];
  List<Map<String, dynamic>> previousOrders = [];
  OrdersCubit() : super(OrdersInitial());

  Future<void> saveOrder(OrderModel order, int orderCode) async {
    emit(OrdersLoading());
    try {
      final orderRef = db.collection('orders').doc(orderCode.toString());
      await orderRef.set(order.toMap());
    } catch (e) {
      emit(OrdersError());
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    emit(OrdersLoading());
    newOrders = [];
    previousOrders = [];
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('orders').get();

      final List<Map<String, dynamic>> orders =
          querySnapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();

      if (orders.isNotEmpty) {
        for (var order in orders) {
          if (order['state'] == 'تم التوصيل' || order['state'] == 'ملغي') {
            previousOrders.add(order);
          } else {
            newOrders.add(order);
          }
        }

        emit(OrdersLoaded(newOrders, previousOrders));
      } else {
        emit(OrdersInitial());
      }

      return orders;
    } catch (e) {
      emit(OrdersError());
      rethrow;
    }
  }

  Future<void> removeOrders(String orderCode) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderCode)
          .delete();

      if (state is OrdersLoaded) {
        final updatedOrders = (state as OrdersLoaded)
            .newOrders
            .where((order) => order['orderCode'] != orderCode)
            .toList();
        emit(OrdersLoaded(updatedOrders, previousOrders));
      }
    } catch (e) {
      emit(OrdersError());
    }
  }
}
