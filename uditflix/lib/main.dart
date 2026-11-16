import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';

// Punto de entrada de la aplicacion

void main() {
  runApp(const MyApp());
}

// Widget principal de UDITFlix

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nombre de nuestra aplicacion
      title: 'UDITFlix',
      // Ocultamos la etiqueta DEBUG
      debugShowCheckedModeBanner: false,
      // Configuracion visual general
      theme: ThemeData(
        useMaterial3: true,
        // Color principal de nuestra aplicacion
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors(0xFF5B2D90)
        ),
        // Color de fondo de pantalla
        scaffoldBackgroundColor: Colors(0xFFF7F5FA),
        // Color de la barra superior
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors(0xFFF5B2D90),
          foregroundColor: Colors.white,
          centerTitle: true,         
        ),
      ),

      // Primera pantalla que vera el usuario.
      home: const CatalogoScreen(),
    );
  }
}

