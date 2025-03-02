import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Importa Firebase Realtime Database
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart'; // Importa ThemeProvider

class HomeScreen extends StatelessWidget {
  final String plantId; // ID del documento de la planta seleccionada

  const HomeScreen({super.key, required this.plantId}); // Constructor

  // Método para mostrar el diálogo de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar planta"),
          content: Text("¿Estás seguro de que deseas eliminar esta planta?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _deletePlant(context); // Elimina la planta
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar la planta de Firebase Realtime Database
  void _deletePlant(BuildContext context) {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    databaseRef
        .child('plantas10')
        .child(plantId)
        .remove()
        .then((_) {
          print("Planta eliminada exitosamente: $plantId");
          Navigator.pop(
            context,
          ); // Regresa a la pantalla anterior después de eliminar
        })
        .catchError((error) {
          print("Error al eliminar la planta: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: Text("Jardinerito"),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            themeProvider.isDarkMode
                ? Colors.grey[900]
                : const Color.fromARGB(255, 69, 138, 71),
        titleTextStyle: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme(); // Cambia entre temas
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream:
            databaseRef
                .child('plantas10')
                .child(plantId)
                .onValue, // Escucha cambios en la planta seleccionada
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(), // Muestra un indicador de carga
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar los datos de la planta",
              ), // Muestra un mensaje de error
            );
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text(
                "No se encontraron datos para esta planta",
              ), // Muestra un mensaje si no hay datos
            );
          }

          // Obtiene los datos de la planta
          final plantData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Planta: $plantId", // Muestra el ID de la planta seleccionada
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                    children: [
                      _buildDataCard(
                        context,
                        "Humedad",
                        plantData['humedad']['min'].toString(),
                        plantData['humedad']['max'].toString(),
                        "💧",
                        Colors.blue,
                      ),
                      _buildDataCard(
                        context,
                        "Luz",
                        plantData['luz']['min'].toString(),
                        plantData['luz']['max'].toString(),
                        "☀️",
                        Colors.amber,
                      ),
                      _buildDataCard(
                        context,
                        "Temperatura",
                        plantData['temperatura']['min'].toString(),
                        plantData['temperatura']['max'].toString(),
                        "🌡️",
                        Colors.red,
                      ),
                      _buildDataCard(
                        context,
                        "PH",
                        plantData['ph']['min'].toString(),
                        plantData['ph']['max'].toString(),
                        "🧪",
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Botón de eliminar planta
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      context,
                    ); // Muestra el diálogo de confirmación
                  },
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text(
                    "Eliminar Planta",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo del botón
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    String title,
    String minValue,
    String maxValue,
    String emoji,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(minHeight: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 40)),
            SizedBox(height: 10),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: Text(
                "Mín: $minValue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Flexible(
              child: Text(
                "Máx: $maxValue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
