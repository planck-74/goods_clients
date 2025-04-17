import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';

SliverAppBar buildSliverAppbar(
  BuildContext context,
) {
  return SliverAppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    expandedHeight: 160,
    floating: false,
    pinned: false,
    flexibleSpace: FlexibleSpaceBar(
      background: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
            builder: (context, state) {
              return _buildContent(state);
            },
          ),
        ),
      ),
    ),
  );
}

Widget _buildContent(GetSupplierDataState state) {
  if (state is GetSupplierDataLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  } else if (state is GetSupplierDataSuccess) {
    return _buildSuccessContent(state);
  } else if (state is GetSupplierDataError) {
    return Center(
      child: Text('Error: ${state.message}'),
    );
  } else {
    return const Center(
      child: Text('No data available'),
    );
  }
}

Widget _buildSuccessContent(GetSupplierDataSuccess state) {
  String imageUrl = state.suppliers[0]['imageUrl'];
  String address =
      '${state.suppliers[0]['town']},${state.suppliers[0]['government']}';

  int minOrderPrice = state.suppliers[0]['minOrderPrice'];

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(imageUrl),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('العنوان : ', address),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 42,
              color: Colors.amber,
            ),
            const SizedBox(height: 4),
            _buildRow('التقييم : ', '9.8/10'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 42,
              color: Colors.amber,
            ),
            const SizedBox(height: 4),
            _buildRow('مدة التوصيل : ', '12 ساعة'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 72,
              color: Colors.amber,
            ),
            const SizedBox(height: 4),
            _buildRow('الحد الأدني : ', '${minOrderPrice.toString()}جـ '),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 62,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ],
  );
}

Widget _buildRow(String title, String value) {
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 14,
        ),
      ),
    ],
  );
}
