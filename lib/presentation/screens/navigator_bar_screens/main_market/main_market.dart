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
  final ScrollController _scrollController = ScrollController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    // التحقق من حالة الـ Cubit قبل تحميل البيانات
    final availableCubit = context.read<AvailableCubit>();
    if (availableCubit.state is! AvailableLoaded) {
      availableCubit.fetchProducts();
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        context.read<AvailableCubit>().fetchMoreProducts();
      }
    });

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
            isSearching = false;
            searchController.clear();
          });
          context
              .read<AvailableCubit>()
              .filterProductsByClassification(selectedClassification);
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
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
          if (state is AvailableLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkBlueColor,
              ),
            );
          }

          if (state is AvailableLoaded) {
            if (!isLabelsLoaded) {
              return const Center(
                  child: CircularProgressIndicator(
                color: darkBlueColor,
              ));
            }

            final labels = ['كل'] + classifications;

            return DefaultTabController(
              length: labels.length,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (!isSearching)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: ClassificationTabBarDelegate(
                        tabBar: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs:
                              labels.map((label) => Tab(text: label)).toList(),
                          indicatorColor: darkBlueColor,
                          labelColor: darkBlueColor,
                          unselectedLabelColor: Colors.grey,
                        ),
                      ),
                    ),
                  if (!isSearching && selectedClassification == 'كل')
                    buildSliverAppbar(context),
                  if (isSearching)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Text(
                          'نتائج البحث',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: darkBlueColor,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: state.productData.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                isSearching
                                    ? 'لا توجد نتائج للبحث'
                                    : 'لا توجد منتجات في هذا التصنيف',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (state.isLoadingMore &&
                            index == state.productData.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                                child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: darkBlueColor,
                              ),
                            )),
                          );
                        }

                        if (index >= state.productData.length) {
                          return null;
                        }

                        final controller = context
                                    .read<AvailableCubit>()
                                    .controllers[
                                'product_${state.productData[index]['productId']}'] ??
                            TextEditingController();

                        return MainMarketCard(
                          controller: controller,
                          product: state.productData[index],
                        );
                      },
                      childCount: state.isLoadingMore
                          ? state.productData.length + 1
                          : state.productData.length,
                      addAutomaticKeepAlives: true,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AvailableError) {
            return Center(child: Text('Error: ${state.message}'));
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
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            setState(() {
              isSearching = true;
            });
            context.read<AvailableCubit>().searchProducts(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج',
          hintStyle: const TextStyle(color: Colors.blueGrey, fontSize: 16),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      isSearching = false;
                    });
                    // Return to current classification view
                    context
                        .read<AvailableCubit>()
                        .filterProductsByClassification(selectedClassification);
                  },
                )
              : null,
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              isSearching = false;
            });
            context
                .read<AvailableCubit>()
                .filterProductsByClassification(selectedClassification);
          } else if (value.length > 2) {
            // Only search when at least 3 characters are entered
            setState(() {
              isSearching = true;
            });
            context.read<AvailableCubit>().searchProducts(value);
          }
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
