import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:appjardinerito/main.dart';
import 'simple_plant_selection_screen.dart';
import 'my_garden_screen.dart';
import 'new_plant_form_screen.dart';

class NewPlantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jardinerito",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ), // Texto en negrita con Poppins
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold, // Texto en negrita con Poppins
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[800]
                          : Color(0xFF487363),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "¡Hola! Soy tu ayudante en el cuidado de plantas, Alvarito. ¿Cómo estás? ¿Te gustaría encontrar una planta nueva o elegir una que ya conoces?",
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold, // Texto en negrita con Poppins
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewPlantFormScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.eco, color: Colors.white),
                    label: Text(
                      "Nueva planta",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ), // Texto en negrita con Poppins
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.isDarkMode
                              ? Colors.green[700]
                              : Color(0xFF70D47E),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.poppins(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SimplePlantSelectionScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.search, color: Colors.white),
                    label: Text(
                      "Elegir una planta",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ), // Texto en negrita con Poppins
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.isDarkMode
                              ? Colors.grey[700]
                              : Color(0xFF487363),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.poppins(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyGardenScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.local_florist, color: Colors.white),
                    label: Text("Mi Jardín"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeProvider.isDarkMode
                              ? Colors.green[700]
                              : Color(0xFF70D47E),
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Image.asset('assets/ico.png', height: 150),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
