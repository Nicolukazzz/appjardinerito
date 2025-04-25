import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appjardinerito/main.dart';

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseReference _gardenRef = FirebaseDatabase.instance.ref().child(
    'mijardin',
  );
  bool _showConfirmation = false;
  String _selectedPlantName = '';

  void _addPlantToGarden(BuildContext context, String plantName) async {
    try {
      DatabaseEvent event =
          await _databaseRef.child('plantas10/$plantName').once();

      if (event.snapshot.value != null) {
        final plantData = event.snapshot.value as Map<dynamic, dynamic>;
        await _gardenRef.child(plantName).set(plantData);

        setState(() {
          _selectedPlantName = plantName;
          _showConfirmation = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Planta agregada a Mi Jardín: $plantName",
              style: GoogleFonts.poppins(),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: No se encontró la planta",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al agregar la planta",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  void _resetSelection() {
    setState(() {
      _showConfirmation = false;
      _selectedPlantName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          _showConfirmation ? "" : "Selecciona una planta",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      body:
          _showConfirmation
              ? _buildConfirmationScreen(context)
              : _buildPlantSelectionScreen(context),
    );
  }

  Widget _buildPlantSelectionScreen(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                      onTap: () => _addPlantToGarden(context, plantName),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[900]
                                : Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco, size: 50, color: Colors.green),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Colors.green),
          SizedBox(height: 23),
          Text(
            "Planta $_selectedPlantName agregada con éxito",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 50,
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.green[700]
                        : Colors.grey[900],
              ),
              onPressed: _resetSelection,
              child: Text(
                "Aceptar",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
