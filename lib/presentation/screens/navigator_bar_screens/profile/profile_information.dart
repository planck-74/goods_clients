import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileInformation extends StatelessWidget {
  const ProfileInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          context,
          const Text(
            'معلومات الحساب',
            style: TextStyle(color: whiteColor),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetClientDataCubit, GetClientDataState>(
          builder: (context, state) {
            if (state is GetClientDataSuccess) {
              final ClientModel client = ClientModel.fromMap(state.client);
              return ListView(
                children: [
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "الاسم: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "الاسم التجاري: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          client.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "التصنيف: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          client.category,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "الموقع: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "الهاتف الأساسي: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          client.phoneNumber,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "الهاتف الثانوي: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          client.secondPhoneNumber,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  customElevatedButtonRectangle(
                    color: Theme.of(context).secondaryHeaderColor,
                    onPressed: () async {
                      GeoPoint geoPoint = client.geoPoint;

                      double latitude = geoPoint.latitude;
                      double longitude = geoPoint.longitude;

                      Uri url = Uri.parse('https:');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not open the map.';
                      }
                    },
                    child: const Text(
                      "عرض الموقع على الخريطة",
                      style: TextStyle(color: Colors.white),
                    ),
                    width: 0.5,
                    context: context,
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
