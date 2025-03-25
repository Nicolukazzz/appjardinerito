import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:appjardinerito/main.dart'; // Importa ThemeProvider
import 'data_screen.dart';

class PlantSelectionScreen extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Selecciona tu planta",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _databaseRef.child('plantas10').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar las plantas",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(
                      child: Text(
                        "No hay plantas disponibles",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }

                  final plantsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final plants = plantsMap.entries.toList();

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      final plantName = plant.key;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DataScreen(plantId: plant.key),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(1.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 50,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.green
                                            : Colors.green,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    plantName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
