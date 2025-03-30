import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/presentation/splash_screen.dart';
import 'package:appjardinerito/presentation/bluetooth_provider.dart'; // Nuevo import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(),
        ), // Nuevo provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jardinerito',
      theme: themeProvider.themeData,
      home: SplashScreen(),
    );
  }
}

// TemaProvider (sin cambios)
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
