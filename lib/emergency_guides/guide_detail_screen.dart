import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/guide_model.dart';

class GuideDetailScreen extends StatelessWidget {
  final EmergencyGuide guide;

  const GuideDetailScreen({required this.guide, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.category),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guide.imageContent1 != null)
              _GuideImage(imageUrl: guide.imageContent1!),
            const SizedBox(height: 20),
            MarkdownBody(
              data: guide.textContent1,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16, height: 1.5),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                listBullet: const TextStyle(fontSize: 16),
              ),
            ),
            if (guide.imageContent2 != null) ...[
              const SizedBox(height: 20),
              _GuideImage(imageUrl: guide.imageContent2!),
            ],
            if (guide.imageContent3 != null) ...[
              const SizedBox(height: 20),
              _GuideImage(imageUrl: guide.imageContent3!),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideImage extends StatelessWidget {
  final String imageUrl;

  const _GuideImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 200,
          color: Colors.grey[200],
        ),
        errorWidget: (_, __, ___) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}