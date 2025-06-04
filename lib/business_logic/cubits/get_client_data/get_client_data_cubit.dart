import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_state.dart';

class GetClientDataCubit extends Cubit<GetClientDataState> {
  GetClientDataCubit() : super(GetClientDataInitial());
  Map<String, dynamic>? client;

  Future<void> getClientData() async {
    try {
      emit(GetClientDataLoading());

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? clientData = documentSnapshot.data();
        client = {
          'name': clientData?['name'],
          'government': clientData?['government'],
          'town': clientData?['town'],
          'category': clientData?['category'],
          'geoPoint': clientData?['geoPoint'],
          'phoneNumber': clientData?['phoneNumber'],
          'secondPhoneNumber': clientData?['secondPhoneNumber'],
          'businessName': clientData?['businessName'],
          'imageUrl': clientData?['imageUrl'],
        };

        Future.delayed(const Duration(seconds: 3), () {
          emit(GetClientDataSuccess(client!));
        });
      } else {
        emit(GetClientDataError('المستخدم غير موجود'));
      }
    } catch (e) {
      emit(GetClientDataError(e.toString()));
    }
  }

  void clearClientData() {
    client = null;
    emit(GetClientDataInitial());
  }
}
