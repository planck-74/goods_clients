import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_state.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class BottomIndicatorCart extends StatefulWidget {
  const BottomIndicatorCart({super.key});

  @override
  State<BottomIndicatorCart> createState() => _BottomIndicatorCartState();
}

class _BottomIndicatorCartState extends State<BottomIndicatorCart> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
      builder: (context, state) {
        if (state is GetSupplierDataSuccess) {
          int minOrderPrice = state.suppliers[0]['minOrderPrice'];
          int minOrderProducts = state.suppliers[0]['minOrderProducts'];
          return BlocBuilder<AvailableCubit, AvailableState>(
            builder: (context, state) {
              if (state is AvailableLoaded) {
                int summation = state.totalWithOffer;

                double indicatorValue =
                    minOrderPrice > 0 ? (summation) / minOrderPrice : 0.0;

                Color indicatorColor = indicatorValue >= 1
                    ? const Color.fromARGB(255, 255, 213, 87)
                    : const Color.fromARGB(255, 255, 213, 87);

                return Stack(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      minHeight: 60,
                      value: indicatorValue,
                      color: indicatorColor,
                    ),
                    SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: BlocBuilder<CartCubit, CartState>(
                          builder: (context, state) {
                            if (state is CartUpdated) {
                              return Text(
                                minOrderPrice <= summation &&
                                        state.cartItems.length !=
                                            minOrderProducts
                                    ? 'ضيف ${minOrderProducts - state.cartItems.length} أصناف تاني'
                                    : 'محتاج تملي العربة شوية',
                                style: const TextStyle(
                                    color: darkBlueColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              );
                            }
                            return const Text('لسه شوية...');
                          },
                        )),
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
