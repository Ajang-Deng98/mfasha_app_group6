import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                // ✅ Fixed: CustomImage widget now correctly implemented
                const CustomImage(imagePath: 'assets/images/profile.png', width: 80, height: 80),
                const SizedBox(height: 20),
                const Text(
                  "Mfasha",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Empowering Health, Ensuring Safety",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              backgroundColor: Colors.yellow,
              child: const Icon(Icons.arrow_right_alt, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Fixed: Define the CustomImage widget
class CustomImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const CustomImage({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 80, color: Colors.red);
      },
    );
  }
}
