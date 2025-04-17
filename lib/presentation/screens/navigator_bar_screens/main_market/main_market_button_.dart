import 'package:flutter/material.dart';

Widget mainMarketButton(
  context,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/MainMarket');
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.98,
        height: 180,
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4198B1)),
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(3.14159 / 2),
                        child: SizedBox(
                            width: 20,
                            child: Image.asset('assets/icons/triangle.png')),
                      ),
                      const Text(
                        'أبــو جبـــة',
                        style: TextStyle(
                          fontSize: 32,
                          color: Color.fromARGB(255, 5, 58, 73),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 24, 0),
                  child: Text(
                    'حيث المجــد',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                )
              ],
            ),
            Positioned(
              top: 28,
              left: 0,
              child: SizedBox(
                  width: 250, child: Image.asset('assets/images/products.png')),
            ),
            Positioned(
              top: 18,
              left: 10,
              child: SizedBox(
                  width: 50,
                  child: Image.asset('assets/images/logo_discharger.png')),
            )
          ],
        ),
      ),
    ),
  );
}
