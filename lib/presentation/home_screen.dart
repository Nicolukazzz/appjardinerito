import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'my_garden_screen.dart';
import 'add_plant_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Pantallas correspondientes a cada item del menú inferior
  final List<Widget> _screens = [
    MyGardenScreen(), // Pantalla de "Mi Jardín"
    AddPlantScreen(), // Pantalla de "Agregar Planta"
    SettingsScreen(), // Pantalla de "Configuración"
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jardinerito",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[200],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Mi Jardín'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outlined),
            label: 'Agregar Planta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}
