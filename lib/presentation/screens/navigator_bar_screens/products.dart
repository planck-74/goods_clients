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
  // ScrollController للتحكم في السكرول وإضافة مؤشرات التحديث
  final ScrollController _scrollController = ScrollController();

  // متغير لحفظ حالة التحديث
  bool _isRefreshing = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // تحرير الموارد عند إغلاق الشاشة
    super.dispose();
  }

  // دالة لتحميل البيانات أول مرة وعند التحديث
  void _loadData() {
    context.read<AvailableCubit>().fetchProducts();
    context.read<AvailableCubit>().fetchOnSaleProducts();
  }

  // تعديل دالة _onRefresh في _ProductsState

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await context.read<AvailableCubit>().fetchProducts(forceRefresh: true);
    await context.read<AvailableCubit>().fetchOnSaleProducts();

    setState(() {
      _isRefreshing = false;
    });
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
        onRefresh: _onRefresh,
        color: primaryColor, // لون مؤشر التحديث مطابق للون الرئيسي
        backgroundColor: Colors.white,
        displacement: 40.0, // المسافة التي ينزل بها المؤشر
        strokeWidth: 3.0, // عرض دائرة التحميل
        child: SingleChildScrollView(
          controller: _scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(), // مهم للسماح بالسحب حتى لو كان المحتوى صغير
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض مؤشر تحميل صغير أثناء التحديث
              if (_isRefreshing)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("جاري التحديث...",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
              const Carousel(),
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
              mainMarketButton(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
