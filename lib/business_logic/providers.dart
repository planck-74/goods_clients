import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/available/available_cubit.dart';
import 'package:goods_clients/business_logic/cubits/cart/cart_cubit.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/firestore/firestore_cubits.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/location/location_cubit.dart';
import 'package:goods_clients/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods_clients/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods_clients/business_logic/cubits/upload_client_data/upload_client_data_cubit.dart';

List<BlocProvider> providers = [
  BlocProvider<SignCubit>(
    create: (context) => SignCubit(),
  ),
  BlocProvider<ControllerCubit>(
    create: (context) => ControllerCubit(),
  ),
  BlocProvider<UploadClientDataCubit>(
    create: (context) => UploadClientDataCubit(),
  ),
  BlocProvider<AvailableCubit>(
    create: (context) => AvailableCubit(),
  ),
  BlocProvider<CartCubit>(
    create: (context) => CartCubit()..resetProductPreferences(),
  ),
  BlocProvider<GetSupplierDataCubit>(
    create: (context) => GetSupplierDataCubit(),
  ),
  BlocProvider<GetClientDataCubit>(
    create: (context) => GetClientDataCubit()..getClientData(),
  ),
  BlocProvider<FirestoreCubit>(
    create: (context) => FirestoreCubit(),
  ),
  BlocProvider<LocationCubit>(
    create: (context) => LocationCubit(),
  ),
  BlocProvider<OrdersCubit>(
    create: (context) => OrdersCubit()..fetchOrders(),
  ),
];
