import 'package:flutter/material.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';

Widget buildProductDetails(
    Map<String, dynamic> staticData, Map<String, dynamic> dynamicData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Text(
          '${staticData['name']} '
          '${staticData['size'] != null ? '- ${staticData['size']}' : ''} '
          '${staticData['note'] != null && staticData['note'] != '' ? '(${staticData['note']})' : ''}',
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
          softWrap: true,
        ),
      ),
      const SizedBox(height: 8),
      if (dynamicData['isOnSale'] == true)
        Row(
          children: [
            Text(
              ' ${dynamicData['offerPrice'].toString()} جـ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              ' ${dynamicData['price'].toString()} جـ',
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
          ' ${dynamicData['price'].toString()} جـ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 20,
          ),
        ),
      const SizedBox(height: 6),
      if (dynamicData['maxOrderQuantityForOffer'] != null)
        Text(
          'أقصي عدد لطلب العرض: ${dynamicData['maxOrderQuantityForOffer']}',
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
            'أقصي عدد للطلب: ${dynamicData['maxOrderQuantity']}',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
          Text(
            'أقل عدد للطلب: ${dynamicData['minOrderQuantity']}',
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
