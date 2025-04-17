import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goods_clients/business_logic/providers.dart';
import 'package:goods_clients/business_logic/routes.dart';
import 'package:goods_clients/data/global/theme/theme_data.dart';
import 'package:goods_clients/firebase_options.dart';
import 'package:goods_clients/services/auth_service.dart';
import 'package:goods_clients/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(GoodsClients());
}

class GoodsClients extends StatelessWidget {
  final AuthService authService = AuthService();
  GoodsClients({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: providers,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            routes: routes,
            supportedLocales: const [
              Locale('ar', 'EG'),
            ],
            locale: const Locale('ar', 'EG'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            title: 'بضائع',
            theme: getThemeData(),
            home: const SplashScreen()));
  }
}
