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
              _GuideImage(imageUrl: guide.imageContent1!, context: context),
            if (guide.textContent1.isNotEmpty) ...[
              const SizedBox(height: 20),
              MarkdownBody(
                data: guide.textContent1,
                styleSheet: _buildMarkdownStyle(context),
              ),
            ],
            if (guide.imageContent2 != null) ...[
              const SizedBox(height: 30),
              _GuideImage(imageUrl: guide.imageContent2!, context: context),
            ],
            if (guide.textContent2.isNotEmpty) ...[
              const SizedBox(height: 20),
              MarkdownBody(
                data: guide.textContent2,
                styleSheet: _buildMarkdownStyle(context),
              ),
            ],
            if (guide.imageContent3 != null) ...[
              const SizedBox(height: 30),
              _GuideImage(imageUrl: guide.imageContent3!, context: context),
            ],
            if (guide.textContent3.isNotEmpty) ...[
              const SizedBox(height: 20),
              MarkdownBody(
                data: guide.textContent3,
                styleSheet: _buildMarkdownStyle(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    return MarkdownStyleSheet(
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
    );
  }
}

class _GuideImage extends StatelessWidget {
  final String imageUrl;
  final BuildContext context;

  const _GuideImage({required this.imageUrl, required this.context});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.6;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.contain,
          placeholder: (_, __) => Container(
            height: imageHeight,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => Container(
            height: imageHeight,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image failed to load', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}