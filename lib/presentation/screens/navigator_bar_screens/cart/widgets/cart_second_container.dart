import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class CartScreenSecondContainer extends StatelessWidget {
  final int? summation;
  final int? controllersSummation;
  final List? cartItems;

  const CartScreenSecondContainer({
    super.key,
    this.summation,
    this.controllersSummation,
    this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    final supplier = context.read<GetSupplierDataCubit>().supplier;
    final minOrderProducts = supplier?['minOrderProducts'];
    final minOrderPrice = supplier?['minOrderPrice'] ?? 3000;

    final cartItemsCount = cartItems?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.amber,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 1,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (minOrderProducts != null &&
                minOrderProducts > cartItemsCount) ...[
              Wrap(
                children: [
                  const Text(
                    '- عدد المنتجات المضافة للعربة أقل من الحد ألادني.',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ' $minOrderProducts منتجات',
                    style: const TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 12,
            ),
            if (minOrderPrice > summation) ...[
              Wrap(
                children: [
                  const Text(
                    '- إجمالي الفاتورة أقل من الحد الادني.',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$minOrderPrice جـ',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 8,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/MainMarket');
              },
              child: const Row(
                children: [
                  Text(
                    'إستكمال التسوق',
                    style: TextStyle(
                      color: Color.fromARGB(255, 73, 160, 76),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.navigate_next,
                    color: Colors.green,
                    size: 32,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
