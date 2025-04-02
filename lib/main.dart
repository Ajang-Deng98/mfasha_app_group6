import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb) { // Ensure reCAPTCHA isn't triggered for mobile
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    runApp(OKToast(child: MyApp()));
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mfasha Health App',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginPage(),
    );
  }
}