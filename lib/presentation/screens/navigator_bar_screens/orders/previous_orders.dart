import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_state.dart';
import 'package:goods_clients/data/functions/data_formater.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

Map<String, dynamic> convertOrderProductToCartProduct(
    Map<String, dynamic> orderProduct) {
  final int quantity = orderProduct['controller'] is int
      ? orderProduct['controller']
      : int.tryParse(orderProduct['controller']?.toString() ?? '0') ?? 0;
  return {
    'product': orderProduct,
    'controller': TextEditingController(text: quantity.toString()),
  };
}

class PreviousOrders extends StatefulWidget {
  const PreviousOrders({super.key});

  @override
  State<PreviousOrders> createState() => _PreviousOrdersState();
}

class _PreviousOrdersState extends State<PreviousOrders> {
  Future<void> _refreshOrders() async {
    context.read<OrdersCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoaded) {
              // ترتيب الطلبات حسب التاريخ من الأحدث إلى الأقدم
              List orders = List.from(state.previousOrders);
              orders.sort((a, b) {
                // الحصول على قيم التاريخ
                dynamic dateA = a['date'];
                dynamic dateB = b['date'];

                // التعامل مع Timestamp أو Unix timestamp
                DateTime timeA;
                DateTime timeB;

                if (dateA is int) {
                  timeA = DateTime.fromMillisecondsSinceEpoch(dateA);
                } else if (dateA != null &&
                    dateA.runtimeType.toString().contains('Timestamp')) {
                  timeA = dateA.toDate();
                } else {
                  try {
                    timeA = DateTime.parse(dateA.toString());
                  } catch (e) {
                    return 0;
                  }
                }

                if (dateB is int) {
                  timeB = DateTime.fromMillisecondsSinceEpoch(dateB);
                } else if (dateB != null &&
                    dateB.runtimeType.toString().contains('Timestamp')) {
                  timeB = dateB.toDate();
                } else {
                  try {
                    timeB = DateTime.parse(dateB.toString());
                  } catch (e) {
                    return 0;
                  }
                }

                // ترتيب تنازلي (الأحدث أولاً)
                return timeB.compareTo(timeA);
              });

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  Map<String, dynamic> order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Card(
                        elevation: 4.0,
                        shadowColor: Colors.black,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      ' رقم الفاتورة: #${orders[index]['orderCode']}',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        DateFormatter.formatTimestamp(
                                            orders[index]['date']),
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'ملخص الطلب',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                    Column(
                                      children: List.generate(
                                        orders[index]['products'].length,
                                        (i) {
                                          int productPrice = 0;
                                          var product =
                                              orders[index]['products'][i];

                                          int price =
                                              product['product']['price'] ?? 0;
                                          int? offerPrice =
                                              product['product']['offerPrice'];
                                          int? maxOrderQuantityForOffer =
                                              product['product']
                                                  ['maxOrderQuantityForOffer'];
                                          int unitsNumber =
                                              product['controller'];

                                          if (offerPrice != null &&
                                              maxOrderQuantityForOffer !=
                                                  null) {
                                            int offerUnits = (unitsNumber >
                                                    maxOrderQuantityForOffer)
                                                ? maxOrderQuantityForOffer
                                                : unitsNumber;
                                            int normalUnits = (unitsNumber >
                                                    maxOrderQuantityForOffer)
                                                ? (unitsNumber -
                                                    maxOrderQuantityForOffer)
                                                : 0;

                                            productPrice =
                                                (offerUnits * offerPrice) +
                                                    (normalUnits * price);
                                          } else {
                                            productPrice = unitsNumber * price;
                                          }

                                          return Row(
                                            children: [
                                              Container(
                                                height: 36,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(3)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$unitsNumber✘',
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product['product']
                                                              ['name'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      product['product']
                                                              ['size'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.blueGrey,
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 6),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '$productPrice جـ',
                                                      style: const TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(height: 24),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'إجمالـي الفاتورة',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${order['totalWithOffer']}جـ',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    color: Colors.green),
                                              ),
                                              if (order['total'] !=
                                                  order['totalWithOffer']) ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'بدلاً من  ${order['total']}',
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 14,
                                                        color: Colors.blueGrey),
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: orders[index]['state'] == 'ملغي'
                                      ? Colors.red.withOpacity(0.9)
                                      : Colors.green.withOpacity(0.9),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(6)),
                                ),
                                child: Center(
                                  child: Text(
                                    orders[index]['state'],
                                    style: const TextStyle(
                                        color: whiteColor, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text(
                'لا توجد طلبات سابقة',
                style: TextStyle(fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }
}
