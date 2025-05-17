import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';

Future<void> addToCart(
  BuildContext context,
  TextEditingController controller,
  String productId,
  Map<String, dynamic> product,
  bool mounted,
) async {
  context.read<AvailableCubit>().addToCart[productId] = true;

  try {
    print(product);
    HapticFeedback.heavyImpact();

    controller.text = '${product['minOrderQuantity'] ?? '1'}';

    await context.read<CartCubit>().saveData(productId, true);

    if (!mounted) return;

    context.read<CartCubit>().addToCart(
          product,
          controller,
        );
    context.read<CartCubit>().updateCartItemsWithInts();
    context.read<AvailableCubit>().updateTotals();
  } catch (e) {
    if (!mounted) return;

    context.read<AvailableCubit>().addToCart[productId] = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل في الإضافة إلى العربة: $e')),
    );
  }
}
