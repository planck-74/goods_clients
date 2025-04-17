import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/orders/new_orders.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/orders/previous_orders.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: customAppBar(
          context,
          const Text(
            'الطلبات',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 40,
              color: Colors.white, 
              child: const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.blueGrey,
                indicatorColor: Colors.blueGrey,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'الفواتير الحالية'),
                  Tab(text: 'الفواتير السابقة'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  NewOrders(),
                  PreviousOrders(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
