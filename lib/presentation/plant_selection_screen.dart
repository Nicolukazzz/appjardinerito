import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart'; // Importa ThemeProvider
import 'data_screen.dart';
import 'blue_screen.dart';

class PlantSelectionScreen extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  void _showCreatePlantDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Crear nueva planta"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Nombre de la planta"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final plantName = _nameController.text.trim();
                if (plantName.isNotEmpty) {
                  _createNewPlant(plantName);
                  Navigator.pop(context);
                }
              },
              child: Text("Crear"),
            ),
          ],
        );
      },
    );
  }

  void _createNewPlant(String plantName) {
    final newPlantRef = _databaseRef.child('plantas10').child(plantName);
    newPlantRef
        .set({'humedad': '0%', 'luz': '0%', 'temperatura': '0°C', 'ph': '0'})
        .then((_) {
          print("Planta creada exitosamente: $plantName");
        })
        .catchError((error) {
          print("Error al crear la planta: $error");
        });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String plantName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar planta"),
          content: Text("¿Estás seguro de que deseas eliminar esta planta?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _deletePlant(plantName);
                Navigator.pop(context);
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deletePlant(String plantName) {
    _databaseRef
        .child('plantas10')
        .child(plantName)
        .remove()
        .then((_) {
          print("Planta eliminada exitosamente: $plantName");
        })
        .catchError((error) {
          print("Error al eliminar la planta: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Jardinerito"),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        leading: IconButton(
          icon: Icon(Icons.bluetooth),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BluetoothScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Selecciona tu planta",
              style: TextStyle(
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
                    return Center(child: Text("Error al cargar las plantas"));
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(child: Text("No hay plantas disponibles"));
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
                                  (context) => HomeScreen(plantId: plant.key),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context, plantName);
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
                                    style: TextStyle(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePlantDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: themeProvider.isDarkMode ? Colors.green : Colors.green,
      ),
    );
  }
}
