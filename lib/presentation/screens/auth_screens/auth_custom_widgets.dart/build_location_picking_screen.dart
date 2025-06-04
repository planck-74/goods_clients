import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/location/location_cubit.dart';
import 'package:goods_clients/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods_clients/business_logic/cubits/upload_client_data/upload_client_data_cubit.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/presentation/custom_widgets/build_location_picker.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods_clients/services/auth_service.dart';

class BuildLocationPickingScreen extends StatefulWidget {
  const BuildLocationPickingScreen({super.key});

  @override
  State<BuildLocationPickingScreen> createState() =>
      _BuildLocationPickingScreenState();
}

class _BuildLocationPickingScreenState
    extends State<BuildLocationPickingScreen> {
  @override
  void initState() {
    super.initState();

    context.read<LocationCubit>().fetchGovernorates();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    context.read<ControllerCubit>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final controllerCubit = context.read<ControllerCubit>();

    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * .2),
            buildLocationPicker(height: screenHeight * .5, width: screenWidth),
            const SizedBox(height: 12),
            customOutlinedButton(
              context: context,
              backgroundColor: primaryColor,
              width: screenWidth * 0.95,
              height: 50,
              child: BlocBuilder<SignCubit, SignState>(
                builder: (context, state) {
                  if (state is SignLoading) {
                    return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator());
                  }
                  return const Text(
                    'تسجيل دخول',
                    style: TextStyle(
                        color: whiteColor, fontWeight: FontWeight.bold),
                  );
                },
              ),
              onPressed: () async {
                final cubit = context.read<ControllerCubit>();
                final businessName = cubit.businessNameController.text.trim();
                final category = cubit.category?.trim() ?? '';
                final phoneNumber = cubit.phoneNumber.text.trim();
                final secondPhoneNumber = cubit.secondPhoneNumber.text.trim();
                final government = cubit.government?.trim() ?? '';
                final town = cubit.town?.trim() ?? '';

                final area = cubit.area.text.trim();
                final geoPoint = cubit.geoPoint ?? const GeoPoint(0, 0);
                if (controllerCubit.pickedFile == null ||
                    businessName.isEmpty ||
                    category.isEmpty ||
                    // phoneNumber.isEmpty ||
                    government.isEmpty ||
                    town.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول المطلوبة!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (controllerCubit.pickedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى اختيار صورة للمحل!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  context
                      .read<UploadClientDataCubit>()
                      .uploadClientData(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جارٍ حفظ البيانات...'),
                      backgroundColor: Colors.blue,
                    ),
                  );

                  await context
                      .read<SignCubit>()
                      .uploadImage(
                        context: context,
                        imageFile: File(controllerCubit.pickedFile!.path),
                      )
                      .then((imageUrl) async {
                    await context.read<SignCubit>().saveClient(
                        ClientModel(
                          uid: FirebaseAuth.instance.currentUser!.uid,
                          businessName: businessName,
                          category: category,
                          imageUrl: imageUrl,
                          phoneNumber: phoneNumber,
                          secondPhoneNumber: secondPhoneNumber,
                          geoPoint: geoPoint,
                          government: government,
                          town: town,
                          area: area,
                          addressTyped: controllerCubit.addressTyped.text,
                        ),
                        context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ البيانات بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.read<GetClientDataCubit>().getClientData();
                    AuthService.saveLoginState(true);
                    Navigator.pushNamed(context, '/NavigatorBar');
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
