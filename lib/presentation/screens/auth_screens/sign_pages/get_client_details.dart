import 'package:flutter/material.dart';
import 'package:goods_clients/presentation/backgrounds/otp_background.dart';
import 'package:goods_clients/presentation/screens/auth_screens/auth_custom_widgets.dart/build_fields.dart';
import 'package:permission_handler/permission_handler.dart';

class GetClientDetails extends StatefulWidget {
  const GetClientDetails({super.key});

  @override
  State<GetClientDetails> createState() => _GetClientDetailsState();
}

class _GetClientDetailsState extends State<GetClientDetails> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
  }

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
              BuildFields(),
            ],
          ),
        ),
      ),
    );
  }
}
