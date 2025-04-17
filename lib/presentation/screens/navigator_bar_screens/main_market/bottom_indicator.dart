import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class BottomIndicator extends StatefulWidget {
  const BottomIndicator({super.key});

  @override
  State<BottomIndicator> createState() => _BottomIndicatorState();
}

class _BottomIndicatorState extends State<BottomIndicator> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
      builder: (context, state) {
        if (state is GetSupplierDataSuccess) {
          int minOrderPrice = state.suppliers[0]['minOrderPrice'];
          return BlocBuilder<AvailableCubit, AvailableState>(
            builder: (context, state) {
              if (state is AvailableLoaded) {
                int summation = state.totalWithOffer;
                int total = state.total;
                int a = total - summation;

                double indicatorValue =
                    minOrderPrice > 0 ? (summation) / minOrderPrice : 0.0;

                Color indicatorColor = indicatorValue >= 1
                    ? const Color.fromARGB(255, 103, 236, 107)
                    : Colors.amber;

                return Stack(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      minHeight: 80,
                      value: indicatorValue,
                      color: indicatorColor,
                    ),
                    SizedBox(
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الحد الأدنى :  $minOrderPrice',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .secondaryHeaderColor
                                        .withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'إجمالي الفاتورة : $summation',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .secondaryHeaderColor
                                        .withOpacity(0.8),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Image.asset('assets/icons/cash.png'),
                                ),
                                Column(
                                  children: [
                                    const Text('وفرنالك 🎉'),
                                    Text(
                                      '${a.toString()} جـ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                navigatorBarKey.currentState?.itemSelected(2);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  color: whiteColor,
                                ),
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset('assets/icons/cart.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }
}
