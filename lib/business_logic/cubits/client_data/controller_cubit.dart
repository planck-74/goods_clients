import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'controller_state.dart';

class ControllerCubit extends Cubit<ControllerState> {
  ControllerCubit() : super(ControllerInitial());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController governmentController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController secondPhoneNumber = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController addressTyped = TextEditingController();
  GeoPoint? geoPoint;
  XFile? pickedFile;

  void initControllers(Map<String, dynamic> client) {
    if (businessNameController.text.isEmpty) {
      businessNameController.text = client['businessName'] ?? '';
    }
    if (governmentController.text.isEmpty) {
      governmentController.text = client['government'] ?? '';
    }
    if (townController.text.isEmpty) {
      townController.text = client['town'] ?? '';
    }
    if (categoryController.text.isEmpty) {
      categoryController.text = client['category'] ?? '';
    }
    if (phoneNumber.text.isEmpty) {
      phoneNumber.text = client['phoneNumber'] ?? '';
    }
    if (secondPhoneNumber.text.isEmpty) {
      secondPhoneNumber.text = client['secondPhoneNumber'] ?? '';
    }
    if (addressTyped.text.isEmpty) {
      addressTyped.text = client['addressTyped'] ?? '';
    }
    geoPoint = client['geoPoint'];
  }

  String? category;
  String? government;
  String? town;

  List<String> storeIds = [];

  final TextEditingController searchProduct = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  void clearSearchDetails() {
    searchResults.clear();
    emit(ControllerInitial());
  }

  void dispose() {
    nameController.dispose();
    businessNameController.dispose();
    governmentController.dispose();
    townController.dispose();
    categoryController.dispose();
    phoneNumber.dispose();
    secondPhoneNumber.dispose();
    area.dispose();
    searchProduct.dispose();
  }

  void reset() {
    nameController.clear();
    businessNameController.clear();
    governmentController.clear();
    townController.clear();
    categoryController.clear();
    phoneNumber.clear();
    secondPhoneNumber.clear();
    area.clear();
    addressTyped.clear();
    searchProduct.clear();
    geoPoint = null;
    category = null;
    government = null;
    town = null;
    storeIds.clear();
    searchResults.clear();
    emit(ControllerInitial());
  }
}
