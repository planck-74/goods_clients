import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/location/location_cubit.dart';
import 'package:goods_clients/business_logic/cubits/location/location_state.dart';
import 'package:goods_clients/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods_clients/business_logic/cubits/upload_client_data/upload_client_data_cubit.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/presentation/custom_widgets/build_location_picker.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_textfield.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/build_image_picker.dart';
import 'package:goods_clients/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class BuildFields extends StatefulWidget {
  const BuildFields({super.key});

  @override
  State<BuildFields> createState() => _BuildFieldsState();
}

class _BuildFieldsState extends State<BuildFields> {
  XFile? pickedFile;
  final ImagePicker picker = ImagePicker();
  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (file != null) {
      setState(() {
        pickedFile = file;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يتم اختيار صورة.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
    final controllerCubit = context.read<ControllerCubit>();

    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Row(
              children: [
                buildImagePicker(
                  screenHeight: MediaQuery.of(context).size.height,
                  context: context,
                  onTap: pickImage,
                  pickedImage:
                      pickedFile != null ? File(pickedFile!.path) : null,
                ),
                Expanded(
                  child: customTextFormField(
                    height: 50,
                    context: context,
                    width: screenWidth * 0.5,
                    controller: controllerCubit.businessNameController,
                    validationText: 'أدخل اسم المنشأة',
                    labelText: 'اسم المنشأة',
                  ),
                ),
              ],
            ),
            customTextFormField(
              height: 50,
              context: context,
              width: screenWidth,
              controller: controllerCubit.secondPhoneNumber,
              validationText: 'أدخل رقم الهاتف الثاني',
              labelText: 'رقم الهاتف الثاني (اختياري)',
              keyboardType: const TextInputType.numberWithOptions(),
            ),
            const SizedBox(height: 6),
            Container(
              height: 50,
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                value: null,
                hint: const Text(
                  'نوع المنشأة',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'كشك',
                    child: Text(
                      'كشك',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'سوبر ماركت',
                    child: Text(
                      'سوبر ماركت',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'محل البان',
                    child: Text(
                      'محل البان',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'كافيه',
                    child: Text(
                      'كافيه',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
                onChanged: (value) {
                  context.read<ControllerCubit>().category = value;
                },
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<LocationCubit, LocationState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Container(
                      height: 50,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        value: state.selectedGovernorate,
                        hint: const Text(
                          'اختر المحافظة',
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 18),
                        ),
                        items: state.governorates
                            .map((gov) => DropdownMenuItem(
                                  value: gov,
                                  child: Text(
                                    gov,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<LocationCubit>().fetchCities(value);
                            context.read<ControllerCubit>().government = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.selectedGovernorate != null)
                      Container(
                        height: 50,
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          value: state.selectedCity,
                          hint: const Text(
                            'اختر المدينة',
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                          items: state.cities
                              .map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null &&
                                state.selectedGovernorate != null) {
                              context.read<LocationCubit>().fetchNeighborhoods(
                                  state.selectedGovernorate!, value);
                              context.read<ControllerCubit>().town = value;
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (state.selectedCity != null &&
                        state.neighborhoods.isNotEmpty)
                      Container(
                        height: 50,
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          value: state.selectedNeighborhood,
                          hint: const Text(
                            'اختر الحي (اختياري)',
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                          items: state.neighborhoods
                              .map((neighborhood) => DropdownMenuItem(
                                    value: neighborhood,
                                    child: Text(
                                      neighborhood,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<LocationCubit>()
                                  .selectNeighborhood(value);

                              context
                                  .read<ControllerCubit>()
                                  .neighborhood
                                  .text = value;
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            buildLocationPicker(width: screenWidth),
            const SizedBox(height: 12),
            customOutlinedButton(
              context: context,
              backgroundColor: darkBlueColor,
              width: screenWidth * 0.95,
              height: 50,
              child: BlocBuilder<SignCubit, SignState>(
                builder: (context, state) {
                  if (state is SignLoading) {
                    return const CircularProgressIndicator();
                  }
                  return const Text(
                    'حفظ البيانات',
                    style: TextStyle(color: whiteColor),
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

                final neighborhood = cubit.neighborhood.text.trim();
                final geoPoint = cubit.geoPoint ?? const GeoPoint(0, 0);

                if (businessName.isEmpty ||
                    category.isEmpty ||
                    phoneNumber.isEmpty ||
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

                if (pickedFile == null) {
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
                        imageFile: File(pickedFile!.path),
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
                          neighborhood: neighborhood,
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
