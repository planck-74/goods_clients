import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_progress_indicator.dart';

Widget customcubidalElevatedButton(
    {IconData? icon,
    required BuildContext context,
    required Color backgroundColor,
    Color? iconColor,
    required VoidCallback onPressed,
    Widget? child,
    double? iconSize,
    double? elevation,
    double? height,
    double? width}) {
  return SizedBox(
    height: height ?? 50,
    width: width ?? 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(0),
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: child ??
          Icon(
            icon,
            color: iconColor,
            size: iconSize ?? 32,
          ),
    ),
  );
}

Widget customElevatedButtonRectangle(
    {required double width,
    required BuildContext context,
    required Widget child,
    double? screenHeight,
    Color? color,
    Color? colorBorderSide,
    VoidCallback? onPressed}) {
  return SizedBox(
    height: screenHeight ?? 50,
    width: MediaQuery.of(context).size.width * width,
    child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(color),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                      color: colorBorderSide ?? Colors.transparent))),
        ),
        child: child),
  );
}

Widget customOutlinedButton(
    {required double width,
    required double height,
    Color? backgroundColor,
    required BuildContext context,
    VoidCallback? onPressed,
    required Widget child}) {
  return SizedBox(
    width: width,
    height: height,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: backgroundColor ?? Theme.of(context).hoverColor,
        side: BorderSide(
          color: Theme.of(context).secondaryHeaderColor,
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Center(child: child),
    ),
  );
}

Widget addButton() {
  return Container(
    key: const ValueKey("add_button"),
    height: 40,
    width: 120,
    decoration: const BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, color: Colors.white, size: 24),
        SizedBox(width: 4),
        Text(
          'إضافة',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    ),
  );
}

Widget rectangleElevatedButton({
  required screenWidth,
  formKey,
  required onPressed,
}) {
  return SizedBox(
    height: 50,
    width: screenWidth * 0.95,
    child: BlocBuilder<SignCubit, SignState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: const BorderSide(color: primaryColor),
              ),
            ),
            backgroundColor: const WidgetStatePropertyAll(primaryColor),
          ),
          child: state is SignLoading
              ? customCircularProgressIndicator(
                  context: context, color: Colors.white)
              : const Text(
                  'تاكيد',
                  style: TextStyle(color: whiteColor),
                ),
        );
      },
    ),
  );
}

Widget biggerRectangleElevatedButton(
    {required double height,
    text,
    required double screenWidth,
    double? elevation,
    sideColor,
    fontSize,
    formKey,
    onPressed,
    child,
    color}) {
  return SizedBox(
    height: height,
    width: screenWidth,
    child: BlocBuilder<SignCubit, SignState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: WidgetStatePropertyAll(elevation),
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(color: sideColor ?? primaryColor),
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(color ?? primaryColor),
          ),
          child: child ??
              Text(
                text ?? '',
                style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize ?? 24),
              ),
        );
      },
    ),
  );
}
