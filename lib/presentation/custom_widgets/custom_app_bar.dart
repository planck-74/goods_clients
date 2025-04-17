import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

PreferredSize customAppBar(BuildContext context, Widget child) {
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
            Colors.transparent, 

        title: child,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    ),
  );
}
