import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_state.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/presentation/custom_widgets/custom_app_bar.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/button.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/open_social_media.dart';
import 'package:goods_clients/presentation/screens/navigator_bar_screens/profile/show_call_dialog.dart';
import 'package:goods_clients/services/auth_service.dart';

import 'dynamic_image_container.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        const Text(
          'الحساب',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<GetClientDataCubit, GetClientDataState>(
              builder: (context, state) {
                if (state is GetClientDataSuccess) {
                  return DynamicImageContainer(
                    imageUrl: state.client['imageUrl'],
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 50, 50, 50).withOpacity(0.7),
                        const Color.fromARGB(255, 30, 30, 30).withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 200,
                );
              },
            ),
            BlocBuilder<GetClientDataCubit, GetClientDataState>(
              builder: (context, state) {
                if (state is GetClientDataSuccess) {
                  ClientModel client = ClientModel.fromMap(state.client);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              client.businessName,
                              style: const TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: Image.asset(
                                        'assets/icons/triangle.png'),
                                  ),
                                ),
                                Text(
                                  client.category,
                                  style: const TextStyle(
                                      color: darkBlueColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: whiteColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: Column(
                              children: [
                                ExpansionTile(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  dense: true,
                                  title: const Text(
                                    "العنوان",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 20),
                                  ),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Text(
                                            'محافظة:',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                          Text(
                                            client.government,
                                            style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Text(
                                            'مدينة:',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                          Text(
                                            client.town,
                                            style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  dense: true,
                                  title: const Text(
                                    "أرقام الهواتف",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 20),
                                  ),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'الرقم ألاساسي:',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              client.phoneNumber,
                                              style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'الرقم الاحتياطي:',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              client.secondPhoneNumber,
                                              style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildButton(
                                  context,
                                  Colors.blueGrey,
                                  'تعديل بيانات الحساب',
                                  () => Navigator.pushNamed(
                                      context, '/EditProfile'),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                buildButton(
                                  context,
                                  Colors.yellow,
                                  'الإشعارات',
                                  () => showNotificationsDialog(context),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                buildButton(
                                  context,
                                  Colors.blue,
                                  'إتصل بنا',
                                  () => showCallDialog(context),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                buildButton(
                                  context,
                                  Colors.purple,
                                  'راسلنا',
                                  () => Navigator.pushNamed(
                                      context, '/ChatScreen'),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                buildButton(
                                  context,
                                  Colors.red,
                                  'تسجيل الخروج',
                                  () {
                                    AuthService.logout(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator(
                  color: darkBlueColor,
                );
              },
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSocialIcon(
                        'assets/icons/facebook.png',
                        () => openSocialMedia(context, 'facebook'),
                      ),
                      buildSocialIcon(
                        'assets/icons/instagram.png',
                        () => openSocialMedia(context, 'instagram'),
                      ),
                      buildSocialIcon(
                        'assets/icons/whatsapp.png',
                        () => openSocialMedia(context, 'whatsapp'),
                      ),
                      buildSocialIcon(
                        'assets/icons/telegram.png',
                        () => openSocialMedia(context, 'telegram'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: whiteColor,
          content: Text('ياتي قريباً،إنتظر خدمة إشعارات مميزة'),
        );
      },
    );
  }
}
