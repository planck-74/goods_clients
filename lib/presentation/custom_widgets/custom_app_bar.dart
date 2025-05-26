import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

PreferredSize customAppBar(BuildContext context, Widget child, {List<Widget>? actions}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56.0), 
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor, 
            Color.fromARGB(255, 75, 6, 1), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        backgroundColor:
            Colors.transparent,        title: child,
        actions: actions,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    ),
  );
}
