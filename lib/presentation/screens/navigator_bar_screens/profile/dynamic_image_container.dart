import 'package:flutter/material.dart';

class DynamicImageContainer extends StatefulWidget {
  final String imageUrl;
  const DynamicImageContainer({super.key, required this.imageUrl});

  @override
  _DynamicImageContainerState createState() => _DynamicImageContainerState();
}

class _DynamicImageContainerState extends State<DynamicImageContainer> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _fetchImageAspectRatio();
  }

  void _fetchImageAspectRatio() {
    final image = Image.network(widget.imageUrl);
    final ImageStream stream = image.image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _aspectRatio = info.image.width / info.image.height;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
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
    }

    return AspectRatio(
      aspectRatio: _aspectRatio!,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(widget.imageUrl),
          ),
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
      ),
    );
  }
}
