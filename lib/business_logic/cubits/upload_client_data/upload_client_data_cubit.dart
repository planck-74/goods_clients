import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/firestore/firestore_cubits.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/upload_client_data/upload_client_data_state.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/services/auth_service.dart';
import 'package:goods_clients/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadClientDataCubit extends Cubit<UploadClientDataState> {
  UploadClientDataCubit() : super(UploadClientDataInitial());
  XFile? image;
  final uuid = const Uuid();

  Future<void> pickImage() async {
    try {
      emit(ImageLoading());
      final ImagePicker picker = ImagePicker();
      image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        emit(ImageLoaded(File(image!.path)));
      } else {
        emit(ImageError('No image selected'));
      }
    } catch (e) {
      emit(ImageError('Failed to pick image: $e'));
    }
  }

  Future<void> uploadClientData(BuildContext context) async {
    print(00);
    if (state is! ImageLoaded) {
      print(1122578678);

      emit(UploadClientDataError('No image available for upload.'));
      return;
    }

    try {
      print(22);

      final imageFile = (state as ImageLoaded).image;
      final firestoreCubit = context.read<FirestoreCubit>();
      final controllerCubit = context.read<ControllerCubit>();
      final currentUser = FirebaseAuth.instance.currentUser;

      emit(UploadClientDataloading());

      final downloadUrl = await StorageServices.uploadImage(
        context: context,
        imageFile: imageFile,
      );

      if (downloadUrl.isEmpty) {
        print(33);

        emit(
            UploadClientDataError('Failed to upload image. Please try again.'));
        return;
      }

      await firestoreCubit.saveClient(ClientModel(
        uid: currentUser!.uid,
        businessName: controllerCubit.businessNameController.text,
        category: '',
        imageUrl: downloadUrl,
        phoneNumber: controllerCubit.phoneNumber.text,
        secondPhoneNumber: controllerCubit.secondPhoneNumber.text,
        geoPoint: controllerCubit.geoPoint ?? const GeoPoint(0, 0),
        government: '',
        town: '',
      ));

      if (!context.mounted) return;
      print(44);
      context.read<GetClientDataCubit>().getClientData();
      AuthService.saveLoginState(true);
      Navigator.pushNamed(context, '/NavigatorBar');
      emit(UploadClientDataloaded());
      print(55);
    } catch (e) {
      print(66);

      emit(UploadClientDataError('Failed to upload Client data: $e'));
    }
  }

  Future<void> updateClientData(BuildContext context) async {
    emit(UploadClientDataloading());

    final controllerCubit = context.read<ControllerCubit>();

    try {
      FirebaseFirestore.instance
          .collection('clients')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'businessName': controllerCubit.businessNameController.text,
        'phoneNumber': controllerCubit.phoneNumber.text,
        'category': controllerCubit.categoryController.text,
        'government': controllerCubit.governmentController.text,
        'town': controllerCubit.townController.text,
        'secondPhoneNumber': controllerCubit.secondPhoneNumber.text,
      });

      emit(UploadClientDataloaded());
    } catch (e) {
      emit(UploadClientDataError('Failed to upload Client data: $e'));
    }
  }
}
