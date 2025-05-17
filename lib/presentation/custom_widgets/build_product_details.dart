import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

Widget buildProductDetails(Map<String, dynamic> product) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Text(
          '${product['name']} '
          '${product['size'] != null ? '- ${product['size']}' : ''} '
          '${product['note'] != null && product['note'] != '' ? '(${product['note']})' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
          softWrap: true,
        ),
      ),
      const SizedBox(height: 8),
      if (product['isOnSale'] == true)
        Row(
          children: [
            Text(
              ' ${product['offerPrice'].toString()} جـ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              ' ${product['price'].toString()} جـ',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        )
      else
        Text(
          ' ${product['price'].toString()} جـ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 20,
          ),
        ),
      const SizedBox(height: 6),
      if (product['maxOrderQuantityForOffer'] != null)
        Text(
          'أقصي عدد لطلب العرض: ${product['maxOrderQuantityForOffer']}',
          style: const TextStyle(
            color: darkBlueColor,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 9,
        children: [
          Text(
            'أقصي عدد للطلب: ${product['maxOrderQuantity']}',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
          Text(
            'أقل عدد للطلب: ${product['minOrderQuantity']}',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
        ],
      )
    ],
  );
}
