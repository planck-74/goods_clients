import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';

import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods_clients/presentation/custom_widgets/overly_message.dart';

class CounterRow extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTapRemove;
  final Map product;

  const CounterRow({
    super.key,
    required this.controller,
    required this.onTapRemove,
    required this.product,
  });

  @override
  _CounterRowState createState() => _CounterRowState();
}

class _CounterRowState extends State<CounterRow> {
  late final int maxLimit;
  late final int minLimit;

  @override
  void initState() {
    super.initState();
    maxLimit = widget.product['maxOrderQuantity'] ?? 10000;
    minLimit = widget.product['minOrderQuantity'] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    int currentValue = int.tryParse(widget.controller.text) ?? minLimit;

    return Container(
      alignment: Alignment.center,
      height: 40,
      width: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2.0),
        color: Colors.transparent.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customcubidalElevatedButton(
            height: 30,
            width: 30,
            icon: Icons.add,
            iconSize: 20,
            context: context,
            backgroundColor: Colors.green,
            iconColor: Colors.white,
            onPressed: () {
              HapticFeedback.heavyImpact();
              increment();
              updateStateAndCubits();
            },
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IntrinsicWidth(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^([1-9][0-9]{0,3}|10000)?'),
                    ),
                  ],
                  onChanged: (value) {
                    validateInput(value);
                    updateStateAndCubits();
                  },
                  onEditingComplete: enforceAndValidateLimits,
                ),
              ),
            ),
          ),
          renderActionButton(currentValue),
        ],
      ),
    );
  }

  Widget renderActionButton(int currentValue) {
    return currentValue == minLimit
        ? customcubidalElevatedButton(
            height: 30,
            width: 30,
            icon: Icons.delete,
            iconSize: 18,
            context: context,
            backgroundColor: Colors.green,
            iconColor: Colors.white,
            onPressed: () {
              HapticFeedback.heavyImpact();
              widget.onTapRemove();
            },
          )
        : customcubidalElevatedButton(
            height: 30,
            width: 30,
            icon: Icons.minimize,
            iconSize: 10,
            context: context,
            backgroundColor: Colors.green,
            iconColor: Colors.white,
            onPressed: () {
              HapticFeedback.heavyImpact();
              decrement();
              updateStateAndCubits();
            },
          );
  }

  /// Attempts to increase the value, showing a message if already at max.
  void increment() {
    int currentValue = int.tryParse(widget.controller.text) ?? minLimit;
    if (currentValue >= maxLimit) {
      _showMaxLimitMessage();
    } else {
      final newValue = currentValue + 1;
      setState(() {
        widget.controller.text = newValue.toString();
      });
    }
  }

  void decrement() {
    int currentValue = int.tryParse(widget.controller.text) ?? minLimit;
    if (currentValue > minLimit) {
      setState(() {
        widget.controller.text = (currentValue - 1).toString();
      });
    }
  }

  void validateInput(String value) {
    int newValue = int.tryParse(value) ?? minLimit;
    if (newValue < minLimit) {
      widget.controller.text = minLimit.toString();
    } else if (newValue > maxLimit) {
      widget.controller.text = maxLimit.toString();
    }
  }

  void enforceAndValidateLimits() {
    int currentValue = int.tryParse(widget.controller.text) ?? minLimit;
    if (currentValue < minLimit) {
      widget.controller.text = minLimit.toString();
    } else if (currentValue > maxLimit) {
      widget.controller.text = maxLimit.toString();
    }
  }

  void _showMaxLimitMessage() {
    showCustomOverlayMessage(
      context,
      'لقد بلغت الحد الأقصي لهذا المنتج',
      textColor: Colors.grey,
      backgroundColor: Colors.yellow,
    );
  }

  void updateStateAndCubits() {
    context.read<AvailableCubit>().updateTotals();
    context.read<CartCubit>().updateCartItemsWithInts();
  }
}
