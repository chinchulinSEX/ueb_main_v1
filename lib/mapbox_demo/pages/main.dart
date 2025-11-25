// file: lib/main.dart
// 🟦 Suelo & Agua – main.dart corporativo y profesional
// Tema elegante, modo oscuro, colores institucionales y estructura optimizada

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// Páginas principales
import 'splash_page.dart';
import 'login_new.dart';
import 'AR_bolitasPages_new.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const SueloAguaApp());
}

Future<void> setup() async {
  // Cargar variables del archivo .env
  await dotenv.load(fileName: ".env");

  // Token para Mapbox
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);

  // Solicitar permisos esenciales
  await Permission.camera.request();
  await Permission.locationWhenInUse.request();
}

class SueloAguaApp extends StatelessWidget {
  const SueloAguaApp({super.key});

  // 🎨 Paleta institucional Suelo & Agua
  static const azulAgua = Color(0xFF1565C0);
  static const celesteGota = Color(0xFF29B6F6);
  static const verdeHoja = Color(0xFF4CAF50);
  static const marronSuelo = Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUELO & AGUA',
      debugShowCheckedModeBanner: false,

      // ⭐ TEMA CLARO CORPORATIVO
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulAgua,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: azulAgua,
          ),
        ),
      ),

      // 🌙 TEMA OSCURO CORPORATIVO
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulAgua,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),

      // 🔄 Detecta automáticamente modo claro/oscuro
      themeMode: ThemeMode.system,

      // 👇 Pantalla inicial
      home: const SplashPage(),

      // Rutas limpias y organizadas
      routes: {
        '/login': (context) => const LoginNewPage(),
        '/ar': (context) => const ARBolitasPagesNew(),
      },
    );
  }
}
