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
    final primaryColor =
        isDarkMode ? Colors.green[700] : const Color(0xFF487363);
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    plantId,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    plantData['nombre_cientifico'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de condiciones ambientales
                Text(
                  'Condiciones Ambientales',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildDataCard(
                      context: context,
                      title: "Humedad (%)",
                      min: plantData['humedad']['min'].toString(),
                      max: plantData['humedad']['max'].toString(),
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDataCard(
                      context: context,
                      title: "Luz (lx)",
                      min: plantData['luz']['min'].toString(),
                      max: plantData['luz']['max'].toString(),
                      icon: Icons.light_mode,
                      color: Colors.amber[700]!,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDataCard(
                      context: context,
                      title: "Temperatura (°C)",
                      min: plantData['temperatura']['min'].toString(),
                      max: plantData['temperatura']['max'].toString(),
                      icon: Icons.thermostat,
                      color: Colors.red,
                      isDarkMode: isDarkMode,
                    ),
                    _buildDataCard(
                      context: context,
                      title: "PH del suelo",
                      min: plantData['ph']['min'].toString(),
                      max: plantData['ph']['max'].toString(),
                      icon: Icons.science,
                      color: Colors.purple,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sección de características
                Text(
                  'Características',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (plantData['medicinal'] == 'Si')
                      _buildFeatureChip(
                        label: 'Medicinal',
                        icon: Icons.medical_services,
                        color: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['ornamental'] == 'Si')
                      _buildFeatureChip(
                        label: 'Ornamental',
                        icon: Icons.spa,
                        color: Colors.purple,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['purifica_aire'] == 'Si')
                      _buildFeatureChip(
                        label: 'Purifica aire',
                        icon: Icons.air,
                        color: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['toxica'] == 'Si')
                      _buildFeatureChip(
                        label: 'Tóxica',
                        icon: Icons.warning,
                        color: Colors.red,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['no_toxica'] == 'Si')
                      _buildFeatureChip(
                        label: 'No tóxica',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['colgante'] == 'Si')
                      _buildFeatureChip(
                        label: 'Colgante',
                        icon: Icons.vertical_align_bottom,
                        color: Colors.orange,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['trepadora'] == 'Si')
                      _buildFeatureChip(
                        label: 'Trepadora',
                        icon: Icons.trending_up,
                        color: Colors.teal,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['arbustiva'] == 'Si')
                      _buildFeatureChip(
                        label: 'Arbustiva',
                        icon: Icons.nature,
                        color: Colors.brown,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['herbacea'] == 'Si')
                      _buildFeatureChip(
                        label: 'Herbácea',
                        icon: Icons.grass,
                        color: Colors.lightGreen,
                        isDarkMode: isDarkMode,
                      ),
                    if (plantData['suculenta'] == 'Si')
                      _buildFeatureChip(
                        label: 'Suculenta',
                        icon: Icons.water_drop,
                        color: Colors.pink,
                        isDarkMode: isDarkMode,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sección de maceta
                Text(
                  'Maceta Recomendada',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMacetaInfo(
                          context: context,
                          label: 'Material',
                          value: plantData['maceta']['material'],
                          icon: Icons.construction,
                          isDarkMode: isDarkMode,
                        ),
                        _buildMacetaInfo(
                          context: context,
                          label: 'Forma',
                          value: plantData['maceta']['forma'],
                          icon: Icons.shape_line,
                          isDarkMode: isDarkMode,
                        ),
                        _buildMacetaInfo(
                          context: context,
                          label: 'Drenaje',
                          value: plantData['maceta']['drenaje'],
                          icon: Icons.water,
                          isDarkMode: isDarkMode,
                        ),
                        _buildMacetaInfo(
                          context: context,
                          label: 'Color',
                          value: plantData['maceta']['color'],
                          icon: Icons.palette,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de riego
                Text(
                  'Riego',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRiegoInfo(
                          context: context,
                          label: 'Frecuencia',
                          value: plantData['riego']['frecuencia'],
                          icon: Icons.timer,
                          isDarkMode: isDarkMode,
                        ),
                        _buildRiegoInfo(
                          context: context,
                          label: 'Método',
                          value: plantData['riego']['metodo'],
                          icon: Icons.water_damage,
                          isDarkMode: isDarkMode,
                        ),
                        _buildRiegoInfo(
                          context: context,
                          label: 'Cantidad',
                          value: plantData['riego']['cantidad'],
                          icon:
                              Icons.water, // Icono cambiado a uno más adecuado
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de sustrato
                Text(
                  'Sustrato',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Composición recomendada:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plantData['sustrato'] ?? 'No especificado',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (plantData['ajuste_ph'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajuste de PH:',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (plantData['ajuste_ph']['bajar'] != null &&
                                  plantData['ajuste_ph']['bajar']
                                      .toString()
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Para bajar el PH:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plantData['ajuste_ph']['bajar'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              if (plantData['ajuste_ph']['subir'] != null &&
                                  plantData['ajuste_ph']['subir']
                                      .toString()
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Para subir el PH:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plantData['ajuste_ph']['subir'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de poda
                if (plantData['poda'] != null &&
                    (plantData['poda']['tipo'] != null ||
                        plantData['poda']['frecuencia'] != null))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Poda',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (plantData['poda']['tipo'] != null &&
                                  plantData['poda']['tipo']
                                      .toString()
                                      .isNotEmpty)
                                _buildPodaInfo(
                                  context: context,
                                  label: 'Tipo de poda',
                                  value: plantData['poda']['tipo'],
                                  icon: Icons.content_cut,
                                  isDarkMode: isDarkMode,
                                ),
                              if (plantData['poda']['frecuencia'] != null &&
                                  plantData['poda']['frecuencia']
                                      .toString()
                                      .isNotEmpty)
                                _buildPodaInfo(
                                  context: context,
                                  label: 'Frecuencia',
                                  value: plantData['poda']['frecuencia'],
                                  icon: Icons.calendar_today,
                                  isDarkMode: isDarkMode,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
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

  Widget _buildFeatureChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Chip(
      avatar: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      side: BorderSide(color: color.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildMacetaInfo({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.brown),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiegoInfo({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodaInfo({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
