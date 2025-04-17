import 'package:bloc/bloc.dart';
import 'package:goods_clients/business_logic/cubits/firestore/firestore_state.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> saveClient(ClientModel client) async {
    emit(FirestoreLoading());
    try {
      await db.collection('clients').doc(client.uid).set(client.toMap());
      emit(FirestoreLoaded());
    } catch (e) {
      emit(FirestoreError());
    }
  }
}
