import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa las opciones de Firebase
import 'package:provider/provider.dart'; // Para manejar el estado del tema
import 'package:appjardinerito/presentation/plant_selection_screen.dart'; // Nueva palla de selección

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Usa las opciones generadas
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Provee el estado del tema
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jardinerito',
      theme: themeProvider.themeData, // Usa el tema actual
      home:
          PlantSelectionScreen(), // Comienza en la pantalla de selección de plantas
    );
  }
}

// Clase para manejar el estado del tema
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Tema claro
  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Tema oscuro
  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
