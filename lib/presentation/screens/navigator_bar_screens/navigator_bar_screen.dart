
import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/cart/cart_screen.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/products.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/profile_screen.dart';
import 'contact/contact_screen.dart';
import 'orders/orders_screen.dart';

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  NavigatorBarState createState() => NavigatorBarState();
}

class NavigatorBarState extends State<NavigatorBar> {
  int selectedIndex = 0;

  final List<Widget> navigatorBarScreens = [
    const Products(),
    const Orders(),
    const Cart(),
    const ContactScreen(),
    const Profile(),
  ];

  void itemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navigatorBarScreens,
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 14,
          fixedColor: primaryColor,
          elevation: 20,
          iconSize: 32,
          selectedFontSize: 14,
          unselectedItemColor:
              Theme.of(context).secondaryHeaderColor.withOpacity(0.95),
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/products.png')),
              label: 'المنتجات',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 34,
                AssetImage('assets/icons/order.png'),
              ),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 36,
                AssetImage('assets/icons/cart.png'),
              ),
              label: 'العربة',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 34,
                AssetImage('assets/icons/telephone.png'),
              ),
              label: 'تـواصل',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 34,
                AssetImage('assets/icons/user.png'),
              ),
              label: 'الحساب',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index) => itemSelected(index),
        ),
      ),
    );
  }
}
