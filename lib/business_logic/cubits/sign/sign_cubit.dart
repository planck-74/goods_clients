import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/cubits/client_data/controller_cubit.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods_clients/data/models/client_model.dart';
import 'package:goods_clients/presentation/custom_widgets/snack_bars.dart';
import 'package:goods_clients/services/auth_service.dart';
part 'sign_state.dart';

class SignCubit extends Cubit<SignState> {
  String? verificatId;
  int? resendToked;
  final TextEditingController sentCode = TextEditingController();
  PhoneAuthCredential? credential;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isIndicatorInOtpScreenShowen = false;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  SignCubit() : super(SignInitial());

  Future<void> signWithPhoneNumber({
    required GlobalKey<FormState> formKey,
    required BuildContext context,
  }) async {
    final phoneNumber = context.read<ControllerCubit>().phoneNumber;

    if (formKey.currentState!.validate()) {
      emit(SignLoading());

      try {
        await auth.verifyPhoneNumber(
          phoneNumber: '+2${phoneNumber.text}',
          timeout: const Duration(seconds: 60),
          codeSent: (verificationId, resendToken) {
            verificatId = verificationId;
            resendToked = resendToken;
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/OtpScreen');
              emit(SignLoaded());
            }
          },
          verificationCompleted: (credential) async {
            try {
              await auth.signInWithCredential(credential);
              if (context.mounted) {
                context.read<GetClientDataCubit>().getClientData();
                AuthService.saveLoginState(true);
                Navigator.pushReplacementNamed(context, '/NavigatorBar');
              }
              emit(SignLoaded());
            } catch (e) {
              if (context.mounted) {
                snackBar(
                    context: context,
                    text: 'فشل تسجيل الدخول: ${e.toString()}');
              }
              emit(SignInitial());
            }
          },
          verificationFailed: (e) {
            String errorMessage = 'حدث خطأ غير متوقع: ${e.code}';
            if (e.code == 'invalid-phone-number') {
              errorMessage = 'من فضلك قم بإدخال رقم هاتف صحيح';
            } else if (e.code == 'network-request-failed') {
              errorMessage =
                  'حدثت مشكلة في الشبكة. يرجى التحقق من اتصال الإنترنت الخاص بك والمحاولة مرة أخرى.';
            }
            if (context.mounted) {
              snackBar(context: context, text: errorMessage);
            }
            emit(SignInitial());
          },
          codeAutoRetrievalTimeout: (verificationId) {
            verificatId = verificationId;
          },
        );
      } catch (e) {
        if (context.mounted) {
          snackBar(context: context, text: 'حدث خطأ أثناء تسجيل الدخول: $e');
        }
        emit(SignInitial());
      }
    }
  }

  void showIndicatorInOtpScreen() {
    isIndicatorInOtpScreenShowen = true;
  }

  Future<void> verifyOTP({
    required BuildContext context,
    required String verificationId,
  }) async {
    emit(SignLoading());
    if (verificatId == null || verificatId!.isEmpty) {
      snackBar(context: context, text: 'فشل تسجيل الدخول');
      return;
    }

    String otp = sentCode.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      snackBar(context: context, text: 'رمز التحقق يجب أن يحتوي على ٦ أرقام');
      return;
    }

    try {
      credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      if (credential == null) {
        snackBar(context: context, text: 'فشل إنشاء بيانات الاعتماد');
        emit(SignFailure());

        return;
      }

      await auth.signInWithCredential(credential!);

      bool isRegistered = await AuthService.isPhoneNumberRegistered(
        context.read<ControllerCubit>().phoneNumber.text,
      );

      if (context.mounted) {
        if (!isRegistered) {
          Navigator.pushReplacementNamed(context, '/GetClientDetails');
        } else {
          context.read<ControllerCubit>().phoneNumber.clear();
          const SnackBar(content: Text('تم تسجيل الدخول بنجاح!'));
          context.read<GetClientDataCubit>().getClientData();
          AuthService.saveLoginState(true);
          Navigator.pushReplacementNamed(context, '/NavigatorBar');
        }
      }
      emit(SignLoaded());
    } catch (e) {
      if (context.mounted) {
        snackBar(context: context, text: 'حدث خطأ أثناء التحقق من الكود: $e');
      }
    }
  }

  Future<void> saveClient(ClientModel supplier, context) async {
    try {
      await db.collection('clients').doc(supplier.uid).set(supplier.toMap());
      emit(SignLoaded());
    } catch (e) {
      snackBar(
          context: context, text: 'حدث خطأ غير متوقع ، حاول في وقتٍ لاحق: $e');
    }
  }

  Future<String> uploadImage({
    required BuildContext context,
    required File imageFile,
  }) async {
    emit(SignLoading());
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${context.read<ControllerCubit>().nameController.text}_$timestamp.jpg';

    String uid = FirebaseAuth.instance.currentUser!.uid;

    Reference ref = storage.ref().child('clients/$uid/images/$fileName');

    try {
      await ref.putFile(imageFile);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return '';
    }
  }
}
