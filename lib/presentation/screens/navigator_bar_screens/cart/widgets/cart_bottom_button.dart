import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_state.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/data/models/order_model.dart';
import 'package:goods_clients/presentation/custom_widgets/bottom_indicator_cart.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods_clients/services/sound_effects.dart';

class CartBottomButton extends StatelessWidget {
  const CartBottomButton({super.key});

  int generateRandom6DigitNumber() {
    var random = Random();
    return random.nextInt(90000000) + 10000000;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartCubit = context.read<CartCubit>();

        if (state is CartUpdated) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 3,
                offset: const Offset(0, -4),
              ),
            ]),
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state is CartUpdated) {
                    final cartItemsWithInts = state.cartItemsWithInts;
                    int cartItemsCount = state.cartItems.length;
                    List cartItems = state.cartItems;

                    final supplier =
                        context.read<GetSupplierDataCubit>().supplier;
                    final minOrderProducts = supplier?['minOrderProducts'] ?? 0;
                    final minOrderPrice = supplier?['minOrderPrice'] ?? 0;

                    return BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        if (state is CartUpdated) {
                          final totalWithOffer = state.totalWithOffer;
                          final total = state.total;
                          return (totalWithOffer >= minOrderPrice) &&
                                  (cartItemsCount >= minOrderProducts)
                              ? biggerRectangleElevatedButton(
                                  sideColor: Colors.green,
                                  color: Colors.green,
                                  child: BlocBuilder<OrdersCubit, OrdersState>(
                                    builder: (context, state) {
                                      if (state is OrdersLoading) {
                                        return customCircularProgressIndicator(
                                            color: whiteColor,
                                            height: 18,
                                            width: 18,
                                            context: context);
                                      }
                                      return const Text(
                                        'اطلب الآن',
                                        style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      );
                                    },
                                  ),
                                  onPressed: () async {
                                    final availableCubit =
                                        context.read<AvailableCubit>();
                                    final ordersCubit =
                                        context.read<OrdersCubit>();

                                    int orderCode =
                                        generateRandom6DigitNumber();
                                    DateTime now = DateTime.now();
                                    Timestamp timestampNow =
                                        Timestamp.fromDate(now);

                                    await ordersCubit.saveOrder(
                                      OrderModel(
                                        state: 'جاري التاكيد',
                                        orderCode: orderCode,
                                        date: timestampNow,
                                        products: cartItemsWithInts,
                                        clientId: FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '0',
                                        itemCount: cartItems.length,
                                        total: total,
                                        totalWithOffer: totalWithOffer,
                                      ),
                                      orderCode,
                                    );
                                    SoundEffects.playOrderConfirmed();

                                    Future.delayed(const Duration(seconds: 0),
                                        () async {
                                      cartItems.clear();
                                      if (context.mounted) {
                                        cartCubit.emitCartInitial();
                                        cartCubit.resetProductPreferences();

                                        for (var entry in availableCubit
                                            .controllers.entries) {
                                          entry.value.text = '0';
                                          availableCubit.addToCart[entry.key] =
                                              false;
                                        }

                                        availableCubit.updateTotals();

                                        if (context.mounted) {
                                          await ordersCubit.fetchOrders();
                                        }
                                      }
                                    });
                                  },
                                  screenWidth:
                                      MediaQuery.of(context).size.width,
                                  formKey: '',
                                  height: 0,
                                  text: 'أطلب الأن',
                                )
                              : const BottomIndicatorCart();
                        }
                        return const SizedBox();
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
