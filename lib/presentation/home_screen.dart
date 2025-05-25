// Tu import actual
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'my_garden_screen.dart';
import 'add_plant_screen.dart';
import 'calendar_screen.dart';
import 'alvarito_blue_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _tutorialStep = 0;
  bool _showTutorial = false;

  final List<Widget> _screens = [
    MyGardenScreen(),
    AddPlantScreen(),
    CalendarScreen(),
  ];

  final List<Map<String, String>> _tutorialSteps = [
    {
      'title': '¡Hola, soy Alvarito! 🌱',
      'description':
          'Este es tu Jardín. Aquí verás todas tus plantas y su estado. ¡Toca cualquiera para ver más detalles!',
    },
    {
      'title': 'Agregar Plantas',
      'description':
          'Presiona el botón central para agregar nuevas plantas desde nuestra biblioteca.',
    },
    {
      'title': 'Calendario de Cuidados',
      'description':
          'Aquí podrás ver un registro de todas las acciones que realizaste con tus plantas, como regarlas, moverlas, etc.',
    },
    {
      'title': 'Botón Mágico',
      'description':
          'El botón de arriba a la derecha permite conectar con Alvarrito, para tomar los datos de tus plantas y recibir consejos personalizados.',
    },
  ];

  void _startTutorial() {
    setState(() {
      _tutorialStep = 0;
      _showTutorial = true;
    });
  }

  void _nextTutorialStep() {
    if (_tutorialStep < _tutorialSteps.length - 1) {
      setState(() {
        _tutorialStep++;
      });
    } else {
      setState(() {
        _showTutorial = false;
      });
    }
  }

  void _previousTutorialStep() {
    if (_tutorialStep > 0) {
      setState(() {
        _tutorialStep--;
      });
    }
  }

  void _closeTutorial() {
    setState(() {
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = isDarkMode ? Colors.grey[900] : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showTutorial ? "Tutorial" : "Mi Jardín",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        leading:
            _showTutorial
                ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: _closeTutorial,
                )
                : IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.yellow : Colors.white,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
        actions: [
          if (!_showTutorial)
            IconButton(
              icon: Image.asset('assets/blue_icon.png', width: 30, height: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlvaritoBlueScreen()),
                );
              },
            ),
          if (!_showTutorial)
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.white),
              onPressed: _startTutorial,
            ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          if (!_showTutorial) _buildFloatingHelpMessage(isDarkMode),
          if (_showTutorial) _buildTutorialOverlay(context, isDarkMode),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDarkMode ? Colors.grey[800] : Colors.green[600],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (_showTutorial) {
                setState(() => _tutorialStep = index);
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor:
                isDarkMode ? Colors.grey[400] : Colors.green[100],
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.eco, size: 24),
                label: 'Mi Jardín',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, size: 24),
                label: 'Agregar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, size: 24),
                label: 'Calendario',
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHelpMessage(bool isDarkMode) {
    final messages = [
      'Aquí puedes ver todas tus plantas. ¡Tócalas para más detalles!',
      'Agrega una nueva planta desde la lista o descubre cuál es ideal para ti.',
      'Revisa las acciones que hiciste con tus plantas, como riego o cambio de lugar.',
    ];

    return Positioned(
      bottom: 10, // Ajustado para que esté encima de la barra de navegación
      left: 20,
      right: 20,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        color: isDarkMode ? Colors.grey[850] : Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            messages[_currentIndex],
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.green[900],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialOverlay(BuildContext context, bool isDarkMode) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _closeTutorial,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(24),
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/blue_icon.png', width: 80, height: 80),
                    SizedBox(height: 12),
                    Text(
                      _tutorialSteps[_tutorialStep]['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _tutorialSteps[_tutorialStep]['description']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_tutorialStep + 1}/${_tutorialSteps.length}',
                          style: GoogleFonts.poppins(
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            if (_tutorialStep > 0)
                              TextButton(
                                onPressed: _previousTutorialStep,
                                child: Text(
                                  'Anterior',
                                  style: GoogleFonts.poppins(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _nextTutorialStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _tutorialStep == _tutorialSteps.length - 1
                                    ? 'Finalizar'
                                    : 'Siguiente',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
        ),
      ],
    );
  }
}
