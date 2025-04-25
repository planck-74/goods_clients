import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/main_market/main_market_button_.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_custom_widgets/carousel.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/navigator_custom_widgets/products_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  // var fbm = FirebaseMessaging.instance;

  @override
  void initState() {
    // fbm.getToken().then((token) {});
    context.read<AvailableCubit>().fetchCombinedProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          context,
          GestureDetector(
            onTap: () {},
            child: const Text(
              'المنتجات',
              style: TextStyle(color: whiteColor),
            ),
          )),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AvailableCubit>()
            ..dataFetched = false
            ..combinedProducts.clear()
            ..fetchCombinedProducts();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Carousel(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.green,
                            Colors.lightGreen,
                            Colors.teal
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: const Text(
                          'عالم V7 المدهش',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // مهم تكون بيضا عشان تبان مع الشيدر
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Image(image: AssetImage('assets/icons/soda.gif')),
                    ],
                  ),
                ),
              ),
              BlocBuilder<AvailableCubit, AvailableState>(
                builder: (context, state) {
                  return state is AvailableLoaded
                      ? ProductsCard(products: state.v7Products)
                      : SizedBox(
                          height: 240,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return const Skeletonizer(
                                    enableSwitchAnimation: true,
                                    enabled: true,
                                    child: ProductsCardSkeleton());
                              }),
                        );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Text(
                        'تــرنــد',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Image(image: AssetImage('assets/animations/fire.gif')),
                      Text(
                        '(الأكثر مبيعـاً)',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<AvailableCubit, AvailableState>(
                builder: (context, state) {
                  return state is AvailableLoaded
                      ? ProductsCard(products: state.trendingProducts)
                      : SizedBox(
                          height: 240,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return const Skeletonizer(
                                    enableSwitchAnimation: true,
                                    enabled: true,
                                    child: ProductsCardSkeleton());
                              }),
                        );
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'أحدث العروض',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                        height: 30,
                        width: 30,
                        child: Image(
                            image:
                                AssetImage('assets/animations/discount.gif'))),
                  ],
                ),
              ),
              BlocBuilder<AvailableCubit, AvailableState>(
                builder: (context, state) {
                  return state is AvailableLoaded
                      ? ProductsCard(products: state.onSaleProducts)
                      : SizedBox(
                          height: 240,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return const Skeletonizer(
                                    enableSwitchAnimation: true,
                                    enabled: true,
                                    child: ProductsCardSkeleton());
                              }),
                        );
                },
              ),
              mainMarketButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
