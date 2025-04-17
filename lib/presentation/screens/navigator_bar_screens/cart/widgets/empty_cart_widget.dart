import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/animited_button.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 380,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/animations/animited_cart.gif',
                  ),
                ),
              ),
              AnimatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/MainMarket');
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
