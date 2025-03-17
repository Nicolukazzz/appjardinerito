import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart'; // Importa ThemeProvider

class NewPlantFormScreen extends StatefulWidget {
  @override
  _NewPlantFormScreenState createState() => _NewPlantFormScreenState();
}

class _NewPlantFormScreenState extends State<NewPlantFormScreen> {
  // Estados para las selecciones
  String? _tiempoSeleccionado; // Para la primera pregunta
  String? _espacioSeleccionado; // Para la segunda pregunta
  String? _tipoPlantaSeleccionado; // Para la tercera pregunta
  String? _luzSeleccionada; // Para la cuarta pregunta

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nueva Planta",
          style: GoogleFonts.poppins(
            // Aplica la fuente Poppins
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.green,
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pregunta 1
              Text(
                "¿Cuánto tiempo puedes dedicar al cuidado de una planta?",
                style: GoogleFonts.poppins(
                  // Aplica la fuente Poppins
                  fontSize: 20, // Tamaño de fuente aumentado
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              _buildRadioOption(
                context,
                "Poco tiempo",
                _tiempoSeleccionado == "Poco tiempo",
                (value) {
                  setState(() {
                    _tiempoSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Moderado tiempo",
                _tiempoSeleccionado == "Moderado tiempo",
                (value) {
                  setState(() {
                    _tiempoSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Bastante tiempo",
                _tiempoSeleccionado == "Bastante tiempo",
                (value) {
                  setState(() {
                    _tiempoSeleccionado = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Pregunta 2
              Text(
                "¿Qué tipo de espacio tienes?",
                style: GoogleFonts.poppins(
                  // Aplica la fuente Poppins
                  fontSize: 20, // Tamaño de fuente aumentado
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              _buildRadioOption(
                context,
                "Interior",
                _espacioSeleccionado == "Interior",
                (value) {
                  setState(() {
                    _espacioSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Exterior",
                _espacioSeleccionado == "Exterior",
                (value) {
                  setState(() {
                    _espacioSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Ambos",
                _espacioSeleccionado == "Ambos",
                (value) {
                  setState(() {
                    _espacioSeleccionado = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Pregunta 3
              Text(
                "¿Te gustan las plantas con flores, hojas decorativas o frutos?",
                style: GoogleFonts.poppins(
                  // Aplica la fuente Poppins
                  fontSize: 20, // Tamaño de fuente aumentado
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              _buildRadioOption(
                context,
                "Flores",
                _tipoPlantaSeleccionado == "Flores",
                (value) {
                  setState(() {
                    _tipoPlantaSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Hojas decorativas",
                _tipoPlantaSeleccionado == "Hojas decorativas",
                (value) {
                  setState(() {
                    _tipoPlantaSeleccionado = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Frutos",
                _tipoPlantaSeleccionado == "Frutos",
                (value) {
                  setState(() {
                    _tipoPlantaSeleccionado = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Pregunta 4
              Text(
                "¿Prefieres plantas que necesiten mucha luz o poca luz?",
                style: GoogleFonts.poppins(
                  // Aplica la fuente Poppins
                  fontSize: 20, // Tamaño de fuente aumentado
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              _buildRadioOption(
                context,
                "Mucha luz",
                _luzSeleccionada == "Mucha luz",
                (value) {
                  setState(() {
                    _luzSeleccionada = value;
                  });
                },
              ),
              _buildRadioOption(
                context,
                "Poca luz",
                _luzSeleccionada == "Poca luz",
                (value) {
                  setState(() {
                    _luzSeleccionada = value;
                  });
                },
              ),
              _buildRadioOption(context, "Ambas", _luzSeleccionada == "Ambas", (
                value,
              ) {
                setState(() {
                  _luzSeleccionada = value;
                });
              }),
              SizedBox(height: 20),
              // Botón "Buscar Planta"
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para buscar plantas basadas en las selecciones
                    if (_tiempoSeleccionado != null &&
                        _espacioSeleccionado != null &&
                        _tipoPlantaSeleccionado != null &&
                        _luzSeleccionada != null) {
                      print("Tiempo seleccionado: $_tiempoSeleccionado");
                      print("Espacio seleccionado: $_espacioSeleccionado");
                      print(
                        "Tipo de planta seleccionado: $_tipoPlantaSeleccionado",
                      );
                      print("Luz seleccionada: $_luzSeleccionada");
                      // Aquí puedes agregar la lógica para buscar plantas
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Por favor, responde todas las preguntas",
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Buscar Planta",
                    style: GoogleFonts.poppins(
                      // Aplica la fuente Poppins
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        themeProvider.isDarkMode
                            ? Colors.green[700]
                            : Color(0xFF70D47E),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para crear opciones de radio personalizadas
  Widget _buildRadioOption(
    BuildContext context,
    String label,
    bool isSelected,
    Function(String?) onChanged,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color(0xFF487363), // Color de fondo personalizado
      child: InkWell(
        onTap: () {
          onChanged(label); // Cambia la selección al tocar la caja
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                value: label,
                groupValue: isSelected ? label : null,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  // Aplica la fuente Poppins
                  fontSize: 20, // Tamaño de fuente aumentado
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
