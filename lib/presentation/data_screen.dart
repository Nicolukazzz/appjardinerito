import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appjardinerito/main.dart';

class DataScreen extends StatelessWidget {
  final String plantId;

  const DataScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = isDarkMode ? Colors.green[700] : Color(0xFF487363);
    final databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Datos de la Planta",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseRef.child('plantas10/$plantId').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar los datos",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text(
                "No se encontraron datos",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          final plantData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  plantId,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.9,
                    children: [
                      _buildDataCard(
                        context: context,
                        title: "Humedad",
                        min: plantData['humedad']['min'].toString(),
                        max: plantData['humedad']['max'].toString(),
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDataCard(
                        context: context,
                        title: "Luz",
                        min: plantData['luz']['min'].toString(),
                        max: plantData['luz']['max'].toString(),
                        icon: Icons.light_mode,
                        color: Colors.amber[700]!,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDataCard(
                        context: context,
                        title: "Temperatura",
                        min: plantData['temperatura']['min'].toString(),
                        max: plantData['temperatura']['max'].toString(),
                        icon: Icons.thermostat,
                        color: Colors.red,
                        isDarkMode: isDarkMode,
                      ),
                      _buildDataCard(
                        context: context,
                        title: "PH",
                        min: plantData['ph']['min'].toString(),
                        max: plantData['ph']['max'].toString(),
                        icon: Icons.science,
                        color: Colors.purple,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCard({
    required BuildContext context,
    required String title,
    required String min,
    required String max,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Mín",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      min,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Máx",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      max,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
