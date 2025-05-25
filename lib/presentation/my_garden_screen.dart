import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appjardinerito/main.dart';
import 'package:appjardinerito/presentation/bluetooth_provider.dart';
import 'sensor_data_screen.dart';

class MyGardenScreen extends StatelessWidget {
  final DatabaseReference _gardenRef = FirebaseDatabase.instance.ref().child(
    'mijardin',
  );

  void _deletePlant(BuildContext context, String plantName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Color(0xFF1A1A1A) // Fondo oscuro en modo oscuro
                  : Color(0xFFFFF2A6), // Fondo amarillo claro en modo claro
          title: Text(
            "Eliminar planta",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color:
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Color(0xFFFFBF00) // Amarillo en modo oscuro
                      : Color(0xFF29AB87), // Verde en modo claro
            ),
          ),
          content: Text(
            "¿Estás seguro de eliminar $plantName de tu jardín?",
            style: GoogleFonts.poppins(
              fontSize: 17,
              color:
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _gardenRef
                    .child(plantName)
                    .remove()
                    .then((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Planta eliminada: $plantName",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Color(0xFF29AB87), // Verde
                        ),
                      );
                    })
                    .catchError((error) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Error al eliminar la planta",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
              },
              child: Text(
                "Eliminar",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final primaryColor = Color(0xFF29AB87); // Verde principal
    final secondaryColor = Color(0xFFFFBF00); // Amarillo secundario

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mi Jardín",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color:
                isDarkMode
                    ? Color(0xFFFFBF00)
                    : Colors.white, // Amarillo en oscuro, blanco en claro
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            isDarkMode
                ? Color(0xFF1A1A1A)
                : Color(0xFF29AB87), // Verde en claro
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor:
          isDarkMode
              ? Color(0xFF121212)
              : Color(0xFFFFF2A6), // Fondo amarillo claro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _gardenRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error al cargar las plantas",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 50,
                            color:
                                isDarkMode
                                    ? Color(0xFFFFBF00)
                                    : Color(0xFF29AB87),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No tienes plantas en tu jardín",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final plantsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final plants = plantsMap.entries.toList();

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      final plantName = plant.key;
                      final plantData = plant.value as Map<dynamic, dynamic>;
                      final imagePath =
                          plantData['image'] ?? 'assets/images/default.jpg';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      SensorDataScreen(plantId: plantName),
                            ),
                          );
                        },
                        onLongPress: () => _deletePlant(context, plantName),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    plantName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDarkMode
                                              ? Color(0xFFFFBF00)
                                              : Color(0xFF29AB87),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
