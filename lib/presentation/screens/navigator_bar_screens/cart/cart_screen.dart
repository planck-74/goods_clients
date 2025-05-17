import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_state.dart';
import 'package:goods_clients/business_logic/cubits/firestore/firestore_cubits.dart';
import 'package:goods_clients/business_logic/cubits/firestore/firestore_state.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/widgets/cart_bottom_button.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/widgets/cart_card.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/widgets/cart_first_container.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/widgets/cart_second_container.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/widgets/empty_cart_widget.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  void initState() {
    super.initState();
    context.read<GetSupplierDataCubit>().getSupplierData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 247, 250, 1.0),
      bottomNavigationBar: const CartBottomButton(),
      appBar: customAppBar(
          context,
          const Text(
            'عربة التسوق',
            style: TextStyle(color: whiteColor),
          )),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartUpdated) {
            List<Map<String, dynamic>> cartItems = state.cartItems;
            return BlocBuilder<FirestoreCubit, FirestoreState>(
              builder: (context, state) {
                if (state is FirestoreLoaded) {
                  return const EmptyCartWidget();
                }
                return Column(
                  children: [
                    BlocBuilder<AvailableCubit, AvailableState>(
                      builder: (context, state) {
                        if (state is AvailableLoaded) {
                          final supplier =
                              context.read<GetSupplierDataCubit>().supplier;
                          final minOrderProducts =
                              supplier?['minOrderProducts'] ?? 0;
                          final minOrderPrice = supplier?['minOrderPrice'] ?? 0;
                          final cartItemsCount = cartItems.length;
                          final totalWithOffer =
                              context.read<AvailableCubit>().totalWithOffer;
                          return Column(
                            children: [
                              const CartScreenFirstContainer(),
                              if ((minOrderPrice > totalWithOffer) ||
                                  (minOrderProducts > cartItemsCount))
                                CartScreenSecondContainer(
                                  summation: totalWithOffer,
                                  controllersSummation:
                                      state.controllersSummation,
                                  cartItems: cartItems,
                                ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> cartItem = cartItems[index];

                          return CartCard(
                            product: cartItem['product'],
                            controller: cartItem['controller'],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }
          if (state is CartInitial) {
            return const EmptyCartWidget();
          }
          return const SizedBox();
        },
      ),
    );
  }
}
