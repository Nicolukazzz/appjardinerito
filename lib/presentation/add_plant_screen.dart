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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }

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
          _searchQuery = '';
          _searchController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Planta agregada a Mi Jardín: $plantName",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Color(0xFF29AB87), // Verde
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
            backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
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

  Widget _buildModernSearchField(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFFFFF2A6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: isDarkMode ? Color(0xFFFFBF00) : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar plantas...',
          hintStyle: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF29AB87)),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFFFF2A6),
      appBar: AppBar(
        title: Text(
          _showConfirmation ? "" : "Selecciona una planta",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Color(0xFFFFBF00) : Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Color(0xFF29AB87),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        bottom:
            _showConfirmation
                ? null
                : PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: _buildModernSearchField(context),
                  ),
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
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Color(0xFF29AB87);

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
                          color: isDarkMode ? Color(0xFFFFBF00) : primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No hay plantas disponibles",
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

                // Filtrar según búsqueda
                final filteredPlants =
                    _searchQuery.isEmpty
                        ? plants
                        : plants.where((plant) {
                          final plantName = plant.key.toString().toLowerCase();
                          return plantName.contains(_searchQuery);
                        }).toList();

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredPlants.length,
                  itemBuilder: (context, index) {
                    final plant = filteredPlants[index];
                    final plantName = plant.key;
                    final normalizedName = normalizeName(plantName);

                    return GestureDetector(
                      onTap: () => _addPlantToGarden(context, plantName),
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
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/images/$normalizedName.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.eco,
                                      size: 50,
                                      color: primaryColor,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  plantName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode
                                            ? Color(0xFFFFBF00)
                                            : primaryColor,
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
    );
  }

  Widget _buildConfirmationScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Color(0xFF29AB87)),
          SizedBox(height: 23),
          Text(
            "Planta $_selectedPlantName agregada con éxito",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 50,
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF29AB87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
