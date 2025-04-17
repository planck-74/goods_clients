import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/presentation/custom_widgets/buildProductImage.dart';
import 'package:goods_clients/presentation/custom_widgets/build_add_to_cart.dart';
import 'package:goods_clients/presentation/custom_widgets/build_product_details.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_custom_widgets/counters.dart';

class MainMarketCard extends StatefulWidget {
  final TextEditingController controller;
  final Map<String, dynamic> product;
  const MainMarketCard({
    super.key,
    required this.controller,
    required this.product,
  });

  @override
  State<MainMarketCard> createState() => _MainMarketCardState();
}

class _MainMarketCardState extends State<MainMarketCard> {
  @override
  Widget build(BuildContext context) {
    final dynamicData = widget.product['dynamicData'] as Map<String, dynamic>;
    final staticData = widget.product['staticData'] as Map<String, dynamic>;
    late final String productId = 'product_${staticData['productId']}';

    final controller = context.read<AvailableCubit>().controllers[productId] ??
        TextEditingController(text: '1000');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6)),
          boxShadow: [BoxShadow(spreadRadius: 0.1, blurRadius: 0.5)],
        ),
        child: Stack(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProductImage(
                staticData: staticData,
                height: 160,
                width: 100,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildProductDetails(staticData, dynamicData),
                      const SizedBox(height: 6),
                      BlocBuilder<AvailableCubit, AvailableState>(
                        builder: (context, state) {
                          if (state is AvailableLoaded) {
                            int currentQty =
                                int.tryParse(widget.controller.text) ?? 0;
                            int maxOfferQty =
                                dynamicData['maxOrderQuantityForOffer'] ??
                                    currentQty;

                            Widget extraCostWidget = const SizedBox();
                            if (dynamicData['isOnSale'] == true &&
                                currentQty > maxOfferQty) {
                              int extraQty = currentQty - maxOfferQty;
                              int normalPrice = dynamicData['price'];
                              extraCostWidget = Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'تم اختيار $extraQty منتجات بالسعر الأصلي ('
                                  '${normalPrice.toString()} جـ ). ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }
                            final isAddedToCart =
                                state.addToCart[productId] ?? false;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  child: isAddedToCart
                                      ? CounterRow(
                                          controller: widget.controller,
                                          onTapRemove: () => removeFromCart(
                                            context,
                                            controller,
                                            productId,
                                          ),
                                          dynamicData: dynamicData,
                                        )
                                      : GestureDetector(
                                          onTap: () => addToCart(
                                              context,
                                              controller,
                                              productId,
                                              dynamicData,
                                              staticData,
                                              mounted),
                                          child: addButton(),
                                        ),
                                ),
                                extraCostWidget
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (dynamicData['isOnSale'] == true) ...[
            Container(
              height: 20,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(6)),
                  color: Colors.lightGreenAccent.withOpacity(0.5)),
              child: const Center(
                child: Text(
                  'عرض',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ]
        ]),
      ),
    );
  }

  Future<void> removeFromCart(
      BuildContext context, TextEditingController controller, productId) async {
    controller.text = '0';
    context.read<AvailableCubit>().updateTotals();
    context.read<CartCubit>().updateCartItemsWithInts();

    try {
      await context.read<CartCubit>().removeData(productId);

      if (!mounted) return;

      setState(() {
        context.read<AvailableCubit>().addToCart[productId] = false;
      });

      context.read<CartCubit>().removeFromCart(productId);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from cart: $e')),
      );
    }
  }
}
