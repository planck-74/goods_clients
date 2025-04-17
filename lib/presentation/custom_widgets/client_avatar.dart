import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_state.dart';
import 'package:goods_clients/data/models/client_model.dart';

Widget clientAvatar() {
  return Center(
    child: CircleAvatar(
      radius: 72,
      backgroundColor: Colors.black,
      child: BlocBuilder<GetClientDataCubit, GetClientDataState>(
        builder: (context, state) {
          if (state is GetClientDataSuccess) {
            ClientModel client = ClientModel.fromMap(state.client);
            return CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(client.imageUrl),
            );
          }
          return const CircleAvatar(
            radius: 70,
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        },
      ),
    ),
  );
}
