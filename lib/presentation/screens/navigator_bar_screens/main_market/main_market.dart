import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/available/available_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/main_market/bottom_indicator.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/main_market/build_sliver_appbar%20build_sliver_appbar.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/main_market/main_market_card.dart';

class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  String selectedClassification = 'كل';
  TabController? _tabController;
  List<String> classifications = [];
  bool isLabelsLoaded = false;

  @override
  void initState() {
    super.initState();

    fetchClassificationLabels().then((labels) {
      setState(() {
        classifications = labels;
        isLabelsLoaded = true;

        _tabController =
            TabController(length: classifications.length + 1, vsync: this);
        _tabController!.addListener(() {
          if (_tabController!.indexIsChanging) return;
          setState(() {
            selectedClassification = _tabController!.index == 0
                ? 'كل'
                : classifications[_tabController!.index - 1];
          });
          context
              .read<AvailableCubit>()
              .filterProductsByClassification(selectedClassification);
        });
      });
    });
  }

  Future<List<String>> fetchClassificationLabels() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('admin_data')
        .doc('classification')
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data.values.map((value) => value.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<AvailableCubit, AvailableState>(
        builder: (context, state) {
          if (state is AvailableLoaded && state.controllersSummation > 0) {
            return const BottomIndicator();
          }
          return const SizedBox();
        },
      ),
      appBar: customAppBar(
        context,
        Row(
          children: [
            const Text(
              'أبـــو جـبة',
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: buildSearchField(searchController)),
          ],
        ),
      ),
      body: BlocBuilder<AvailableCubit, AvailableState>(
        builder: (context, state) {
          if (state is AvailableLoaded) {
            List<dynamic> productData = state.productData;

            if (!isLabelsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final labels = ['كل'] + classifications;
            return DefaultTabController(
              length: labels.length,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ClassificationTabBarDelegate(
                      tabBar: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: labels.map((label) => Tab(text: label)).toList(),
                        indicatorColor: darkBlueColor,
                        labelColor: darkBlueColor,
                        unselectedLabelColor: Colors.grey,
                      ),
                    ),
                  ),
                  if (selectedClassification == 'كل')
                    buildSliverAppbar(context),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, index) {
                        return MainMarketCard(
                          controller: context
                              .read<AvailableCubit>()
                              .controllers
                              .values
                              .toList()[index],
                          product: productData[index],
                        );
                      },
                      childCount: productData.length,
                      addAutomaticKeepAlives: true,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is AvailableLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            );
          }
          return Center(
            child: Text(
              'لاتوجد منتجات لعرضها',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }

  Widget buildSearchField(TextEditingController searchController) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: searchController,
        cursorHeight: 18,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'ابحث عن منتج',
          hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onChanged: (value) {
          context.read<AvailableCubit>().searchProducts(value);
        },
      ),
    );
  }
}

class ClassificationTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  ClassificationTabBarDelegate({required this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant ClassificationTabBarDelegate oldDelegate) =>
      false;
}
