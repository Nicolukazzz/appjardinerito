import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'bluetooth_screen.dart';
import 'plant_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = isDarkMode ? Colors.green[700] : Color(0xFF487363);
    final tileColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configuración",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8), // Espacio adicional después del AppBar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              child: Column(
                children: [
                  _buildSettingsTile(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: Icons.bluetooth,
                    title: "Conexión Bluetooth",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BluetoothScreen(),
                          ),
                        ),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSettingsTile(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: Icons.language,
                    title: "Plantas en Base de Datos",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantSelectionScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Jardinerito v1.0',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required bool isDarkMode,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.green[300] : Color(0xFF487363),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
