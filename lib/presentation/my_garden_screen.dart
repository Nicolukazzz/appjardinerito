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
                  ? Colors.grey[900]
                  : Colors.white,
          title: Text(
            "Eliminar planta",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color:
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          content: Text(
            "¿Estás seguro de eliminar $plantName de tu jardín?",
            style: GoogleFonts.poppins(fontSize: 17),
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
                          backgroundColor: Colors.green,
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
    final primaryGreen = Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mi Jardín",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                      child: CircularProgressIndicator(color: primaryGreen),
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
                            color: Colors.grey[900],
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
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_florist,
                                  size: 50,
                                  color: primaryGreen,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  plantName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                  textAlign: TextAlign.center,
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
