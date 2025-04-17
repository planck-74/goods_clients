import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/location_picker.dart';
import 'package:goods_clients/presentation/screens/auth_screens/sign_pages/get_client_details.dart';
import 'package:goods_clients/presentation/screens/auth_screens/sign_pages/otp_screen.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/cart_screen.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/contact/chat_screen.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/main_market/main_market.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_bar_screen.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/edit_profile_screen.dart';
import '../presentation/screens/auth_screens/sign_pages/sign.dart';

final Map<String, WidgetBuilder> routes = {
  '/Sign': (context) => const Sign(),
  '/OtpScreen': (context) => const OtpScreen(),
  '/LocationPickerScreen': (context) => const LocationPickerScreen(),
  '/NavigatorBar': (context) => NavigatorBar(key: navigatorBarKey),
  '/MainMarket': (context) => const MainMarket(),
  '/ChatScreen': (context) => const ChatScreen(),
  '/Cart': (context) => const Cart(),
  '/EditProfile': (context) => const EditProfile(),
  '/GetClientDetails': (context) => const GetClientDetails(),
};
