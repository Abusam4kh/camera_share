import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CameraShareApp());
}

class CameraShareApp extends StatelessWidget {
  const CameraShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1769AA);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'شارك الكاميرا',
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
