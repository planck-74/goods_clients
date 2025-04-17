import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';

Future<void> addToCart(BuildContext context, TextEditingController controller,
    productId, dynamicData, staticData, mounted) async {
  context.read<AvailableCubit>().addToCart[productId] = true;

  try {
    HapticFeedback.heavyImpact();

    controller.text = '${dynamicData['minOrderQuantity'] ?? '1'}';

    await context.read<CartCubit>().saveData(productId, true);

    if (!mounted) return;

    context.read<CartCubit>().addToCart({
      'staticData': staticData,
      'dynamicData': dynamicData,
      'controller': controller,
    });

    context.read<CartCubit>().updateCartItemsWithInts();
    context.read<AvailableCubit>().updateTotals();
  } catch (e) {
    if (!mounted) return;

    context.read<AvailableCubit>().addToCart[productId] = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add to cart: $e')),
    );
  }
}
