import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed; 

  const AnimatedButton({super.key, this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        if (widget.onPressed != null) {
          widget.onPressed!(); 
        }
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: screenWidth * 0.6,
        height: isPressed ? 55 : 60, 
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.red[700]
              : primaryColor, 
          borderRadius: BorderRadius.circular(12.0), 
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: isPressed ? 3 : 8,
              spreadRadius: isPressed ? 1 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          "اضف منتجات الي العربة",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
