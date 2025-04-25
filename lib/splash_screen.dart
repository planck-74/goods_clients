import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods_clients/business_logic/auth_check.dart';
import 'package:goods_clients/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    context.read<GetClientDataCubit>().getClientData();

    _controller = VideoPlayerController.asset(
      'assets/animations/splash_video.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(false);

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthCheck()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
