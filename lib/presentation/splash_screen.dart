import 'package:flutter/material.dart';
import 'package:appjardinerito/presentation/home_screen.dart'; // Importa NewPlantScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNewPlantScreen(); // Cambia el nombre del método para reflejar la nueva pantalla
  }

  _navigateToNewPlantScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Espera 3 segundos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ), // Redirige a NewPlantScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/ico.png',
        ), // Asegúrate de tener esta imagen en tu carpeta de assets
      ),
    );
  }
}
