import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

Widget buildProductImage({
  required Map<String, dynamic>? product,
  double? height,
  double? width,
}) {
  return SizedBox(
    height: height ?? 100,
    width: width ?? 100,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: product != null &&
              product.containsKey('imageUrl') &&
              product['imageUrl'] != null &&
              product['imageUrl'].isNotEmpty
          ? CachedNetworkImage(
              imageUrl: product['imageUrl'],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                  child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: darkBlueColor,
                ),
              )),
              errorWidget: (context, url, error) =>
                  Image.asset('assets/images/app_logo_black.png'),
            )
          : Image.asset('assets/images/app_logo_black.png'),
    ),
  );
}
