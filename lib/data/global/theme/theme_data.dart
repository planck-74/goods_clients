import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_bar_screen.dart';

const Color primaryColor = Color.fromARGB(255, 190, 30, 19);
const Color darkBlueColor = Color(0xFF012340);
const Color lightBackgroundColor = Colors.white;
const Color whiteColor = Colors.white;
const Color scaffoldBackgroundColor = Color.fromARGB(255, 232, 232, 232);
String storeId = 'cafb6e90-0ab1-11f0-b25a-8b76462b3bd5';
// String clientId = FirebaseAuth.instance.currentUser!.uid;
String supplierId = 'w3Px6Xg8mnUgqJXknJDG9zpbL4Q2';

final GlobalKey<NavigatorBarState> navigatorBarKey =
    GlobalKey<NavigatorBarState>();
ThemeData getThemeData() {
  return ThemeData(
    cardTheme: const CardTheme(
      color: whiteColor,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: whiteColor),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    textSelectionTheme: const TextSelectionThemeData(
        cursorColor: darkBlueColor, selectionHandleColor: darkBlueColor),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: darkBlueColor, fontSize: 16),
      border: OutlineInputBorder(),
      focusedBorder: InputBorder.none,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle:
          TextStyle(color: darkBlueColor, fontSize: 18, fontFamily: 'Cairo'),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: darkBlueColor, fontSize: 12),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darkBlueColor,
            width: 2.0,
          ),
        ),
      ),
    ),
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    secondaryHeaderColor: darkBlueColor,
    hoverColor: Colors.blueGrey[200],
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      iconTheme: IconThemeData(color: whiteColor),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor,
      height: 50,
    ),
    fontFamily: 'Cairo',
    textTheme: TextTheme(
      headlineLarge: _textStyle(
        color: darkBlueColor,
        fontSize: 32,
      ),
      headlineMedium: _textStyle(color: darkBlueColor, fontSize: 14),
      headlineSmall: _textStyle(color: darkBlueColor, fontSize: 12),
      bodyLarge: _textStyle(
        color: darkBlueColor,
        fontSize: 24,
      ),
      bodyMedium: _textStyle(
        color: darkBlueColor,
        fontSize: 18,
      ),
      bodySmall: _textStyle(
        color: darkBlueColor,
        fontSize: 12,
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: darkBlueColor),
  );
}

TextStyle _textStyle(
    {required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}
