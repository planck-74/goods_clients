import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/backgrounds/otp_background.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/build_location_picking_screen.dart';

class GetClientLocation extends StatefulWidget {
  const GetClientLocation({super.key});

  @override
  State<GetClientLocation> createState() => _GetClientLocationState();
}

class _GetClientLocationState extends State<GetClientLocation> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: const Stack(
            children: [
              BuildBackground(),
              BuildLocationPickingScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
