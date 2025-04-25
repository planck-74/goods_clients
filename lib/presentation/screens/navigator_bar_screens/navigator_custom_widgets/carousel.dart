import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List<String> carouselImages = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: carouselImages.length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(carouselImages[itemIndex]),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.97,
            aspectRatio: 2.0,
            initialPage: 2,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSmoothIndicator(
          activeIndex: currentIndex,
          count: carouselImages.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: Colors.green,
            dotColor: Colors.blueGrey,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 4,
          ),
        )
      ],
    );
  }
}
