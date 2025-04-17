import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods_clients/business_logic/cubits/location/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationState());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> fetchGovernorates() async {
    print('Fetching governorates...');
    final snapshot = await firestore
        .collection('admin_data')
        .doc('locations')
        .collection('governments')
        .get();

    final data = snapshot.docs.map((doc) {
      print('Found governorate: ${doc.id}');
      return doc.id;
    }).toList();

    print('Fetched governorates: $data');
    emit(state.copyWith(governorates: data));
  }

  Future<void> fetchCities(String governorate) async {
    print('Fetching cities for governorate: $governorate');
    final snapshot = await firestore
        .collection('admin_data')
        .doc('locations')
        .collection('governments')
        .doc(governorate)
        .collection('cities')
        .get();
    final data = snapshot.docs.map((doc) => doc['name'] as String).toList();
    print('Fetched cities for $governorate: $data');
    emit(state.copyWith(cities: data, selectedGovernorate: governorate));
  }

  Future<void> fetchNeighborhoods(String governorate, String city) async {
    print('Fetching neighborhoods for $governorate > $city');
    final snapshot = await firestore
        .collection('admin_data')
        .doc('locations')
        .collection('governments')
        .doc(governorate)
        .collection('cities')
        .doc(city)
        .collection('neighborhoods')
        .get();
    final data = snapshot.docs.map((doc) => doc['name'] as String).toList();
    print('Fetched neighborhoods for $governorate > $city: $data');
    emit(state.copyWith(neighborhoods: data, selectedCity: city));
  }

  void selectNeighborhood(String neighborhood) {
    print('Neighborhood selected: $neighborhood');
    emit(state.copyWith(selectedNeighborhood: neighborhood));
  }
}
