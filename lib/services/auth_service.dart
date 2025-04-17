import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/main.dart';
import 'package:goods_clients/presentation/custom_widgets/snack_bars.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static void resendVerificationCode({
    required String phoneNumber,
    required BuildContext context,
    required int resendToken,
    required void Function(String verificationId, int? newResendToken)
        onCodeSent,
  }) {
    auth.verifyPhoneNumber(
      phoneNumber: '+20$phoneNumber',
      verificationCompleted: (credential) async {},
      verificationFailed: (e) {
        showSnackBar(context, 'Verification failed: ${e.message}', Colors.red);
      },
      codeSent: (verificationId, newResendToken) {
        onCodeSent(verificationId, newResendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      forceResendingToken: resendToken,
    );
  }

  static Future<void> logout(BuildContext context) async {
    try {
      await auth.signOut().then((value) {
        showSnackBar(context, 'تم تسجيل الخروج.', darkBlueColor);
        saveLoginState(false);
        context.read<ControllerCubit>().reset();
        context.read<GetClientDataCubit>().clearClientData();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => GoodsClients()),
          (route) => false,
        );
      });
    } catch (e) {
      showSnackBar(context,
          'حدث خطأ أثناء تسجيل الخروج. برجاء المحاولة مرة أخرى.', Colors.red);
    }
  }

  static Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final querySnapshot = await firestore
          .collection('clients')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static void showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    snackBar(context: context, text: message, backgroundColor: backgroundColor);
  }

  static Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logoutSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
}
