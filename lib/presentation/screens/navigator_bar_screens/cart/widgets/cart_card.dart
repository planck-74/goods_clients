import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/presentation/custom_widgets/buildProductImage.dart';
import 'package:goods_clients/presentation/custom_widgets/build_product_details.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_custom_widgets/counters.dart';

class CartCard extends StatefulWidget {
  final Map<String, dynamic> product;

  final TextEditingController controller;

  const CartCard({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> product = widget.product;
    String productId = 'product_${product['productId']}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6)),
          boxShadow: [BoxShadow(spreadRadius: 0.1, blurRadius: 0.5)],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildProductImage(product: widget.product),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProductDetails(
                          product,
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<AvailableCubit, AvailableState>(
                          builder: (context, state) {
                            int currentQty =
                                int.tryParse(widget.controller.text) ?? 0;
                            int maxOfferQty =
                                widget.product['maxOrderQuantityForOffer'] ??
                                    currentQty;

                            Widget extraCostWidget = const SizedBox();
                            if (widget.product['isOnSale'] == true &&
                                currentQty > maxOfferQty) {
                              int extraQty = currentQty - maxOfferQty;
                              int normalPrice = widget.product['price'];
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

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CounterRow(
                                  controller: widget.controller,
                                  onTapRemove: () async {
                                    widget.controller.text = '0';
                                    context
                                        .read<AvailableCubit>()
                                        .updateTotals();
                                    context
                                        .read<CartCubit>()
                                        .updateCartItemsWithInts();
                                    await context
                                        .read<CartCubit>()
                                        .removeData(productId);
                                    setState(() {
                                      context
                                          .read<AvailableCubit>()
                                          .addToCart[productId] = false;
                                    });
                                    context
                                        .read<CartCubit>()
                                        .removeFromCart(productId);
                                  },
                                  product: widget.product,
                                ),
                                extraCostWidget,
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (widget.product['isOnSale'] == true)
              Container(
                height: 20,
                width: 35,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(6)),
                  color: Colors.lightGreenAccent.withOpacity(0.5),
                ),
                child: const Center(
                  child: Text(
                    'عرض',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
