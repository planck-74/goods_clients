import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/presentation/custom_widgets/buildProductImage.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_custom_widgets/counters.dart';

class ProductsCard extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductsCard({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailableCubit, AvailableState>(
      builder: (context, state) {
        if (state is AvailableLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productId =
                        'product_${product['staticData']['productId']}';
                    final controller =
                        context.read<AvailableCubit>().controllers[productId] ??
                            TextEditingController(text: '1000');

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 200),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 6, 0, 4),
                                child: Text(
                                  'ابــو جبــــــــة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 14, 103, 151),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: buildProductImage(
                                  height: 100,
                                  staticData: product['staticData'],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${product['staticData']['name']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                      if (product['staticData']['size'] !=
                                          null) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            '- ${product['staticData']['size']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                      if (product['staticData']['note'] !=
                                              null &&
                                          product['staticData']['note'] != '')
                                        Text(
                                          '(${product['staticData']['note']})',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                          ),
                                          softWrap: true,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (product['dynamicData']['isOnSale'] == false)
                                Text(
                                  '${product['dynamicData']['price'].toString()} جـ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              if (product['dynamicData']['isOnSale'] == true)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${product['dynamicData']['offerPrice'].toString()} جـ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${product['dynamicData']['price'].toString()} جـ',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                              AddToCartButton(
                                product: product,
                                controller: controller,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

class AddToCartButton extends StatefulWidget {
  final Map<String, dynamic> product;
  final TextEditingController controller;

  const AddToCartButton({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  @override
  Widget build(BuildContext context) {
    final productId = 'product_${widget.product['staticData']['productId']}';

    return BlocBuilder<AvailableCubit, AvailableState>(
      builder: (context, state) {
        bool isAddedToCart = false;
        if (state is AvailableLoaded) {
          isAddedToCart = state.addToCart[productId] ?? false;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isAddedToCart
              ? CounterRow(
                  key: const ValueKey("counter_row"),
                  controller: widget.controller,
                  dynamicData: widget.product['dynamicData'],
                  onTapRemove: () async {
                    widget.controller.text = '0';
                    context.read<AvailableCubit>().updateTotals();
                    context.read<CartCubit>().updateCartItemsWithInts();

                    await context.read<CartCubit>().removeData(productId);
                    setState(() {
                      context.read<AvailableCubit>().addToCart[productId] =
                          false;
                    });
                    context.read<CartCubit>().removeFromCart(productId);
                  },
                )
              : GestureDetector(
                  onTap: () => _addToCart(context, widget.product, productId),
                  child: Container(
                    key: const ValueKey("add_button"),
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 25),
                        SizedBox(width: 4),
                        Text(
                          'إضافة',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _addToCart(BuildContext context, Map<String, dynamic> product,
      String productId) async {
    HapticFeedback.heavyImpact();

    final availableCubit = context.read<AvailableCubit>();
    final cartCubit = context.read<CartCubit>();

    availableCubit.markProductAdded(productId);

    try {
      widget.controller.text =
          '${product['dynamicData']['minOrderQuantity'] ?? '1'}';
      await cartCubit.saveData(productId, true);
      cartCubit.addToCart({
        'staticData': product['staticData'],
        'dynamicData': product['dynamicData'],
        'controller': widget.controller,
      });
      cartCubit.updateCartItemsWithInts();
      availableCubit.updateTotals();
    } catch (e) {
      availableCubit.markProductRemoved(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }
}

class ProductsCardSkeleton extends StatelessWidget {
  const ProductsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: Container(
        padding: const EdgeInsets.all(6),
        height: 240,
        width: 200,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
              child: Container(
                height: 12,
                width: 80,
                color: Colors.blueGrey,
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              clipBehavior: Clip.hardEdge,
              child: Container(
                height: 100,
                width: 150,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 14,
                    width: 40,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            Container(
              height: 18,
              width: 60,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              clipBehavior: Clip.hardEdge,
              child: Container(
                height: 40,
                width: 100,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
