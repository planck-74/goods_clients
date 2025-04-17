import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_state.dart';

class CartScreenFirstContainer extends StatelessWidget {
  const CartScreenFirstContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        int total = 0;
        int cartItems = 0;
        if (state is CartUpdated) {
          total = state.totalWithOffer;
          cartItems = state.cartItems.length;
        }
        return Container(
          height: 34,
          color: const Color.fromARGB(255, 221, 221, 221),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: Text(
                  ' الإجمالي  $total',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              const VerticalDivider(
                indent: 10,
                endIndent: 10,
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 38.0),
                child: Text(
                  ' $cartItems منتجات',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
