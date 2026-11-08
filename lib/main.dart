import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_page.dart';
import 'firebase_options.dart';

const Color teal = Color(0xFF008F9D);
const Color darkGreen = Color(0xFF294541);
const Color paleGreen = Color(0xFFE7F3EE);
const Color pageColor = Color(0xFFF6F9F7);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init bypassed/failed, using MySQL API: $e');
  }

  runApp(const LocaraApp());
}

class LocaraApp extends StatelessWidget {
  const LocaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'locara',
      theme: ThemeData(
        scaffoldBackgroundColor: pageColor,
        colorScheme: ColorScheme.fromSeed(seedColor: teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashPage(),
    );
  }
}
