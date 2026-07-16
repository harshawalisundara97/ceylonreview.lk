import 'package:flutter/material.dart';

/// Full-screen, swipeable, pinch-zoomable viewer for a list of photo URLs.
/// Used by review thumbnails and the place detail Photos strip.
class PhotoViewer extends StatelessWidget {
  const PhotoViewer(
      {super.key, required this.photoUrls, required this.initialIndex});

  final List<String> photoUrls;
  final int initialIndex;

  static void open(BuildContext context,
      {required List<String> photoUrls, required int initialIndex}) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          PhotoViewer(photoUrls: photoUrls, initialIndex: initialIndex),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photoUrls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              photoUrls[i],
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
