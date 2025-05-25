import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:appjardinerito/main.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();

  static Future<void> refresh(BuildContext context) async {
    final state = context.findAncestorStateOfType<_CalendarScreenState>();
    if (state != null && state.mounted) {
      await state._loadSavedActions();
    }
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<String, dynamic> _savedActions = {};

  @override
  void initState() {
    super.initState();
    _loadSavedActions();
  }

  Future<void> _loadSavedActions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('plant_actions') ?? '{}';

    if (mounted) {
      setState(() {
        _savedActions = json.decode(jsonString);
        print('Acciones cargadas: $_savedActions'); // Debug
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateKey = day.toIso8601String().substring(0, 10);
    return _savedActions[dateKey] ?? [];
  }

  List<Widget> _getActionsForDay(DateTime day) {
    final actions = _getEventsForDay(day);

    if (actions.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No hay acciones registradas para este día",
            style: GoogleFonts.poppins(
              color:
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Color(0xFFFFBF00) // Amarillo en modo oscuro
                      : Colors.grey,
            ),
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          "Acciones registradas:",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color:
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Color(0xFF29AB87), // Verde en modo claro
          ),
        ),
      ),
      ...(actions as List).map((entry) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          color:
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Color(0xFF1A1A1A) // Gris oscuro en modo oscuro
                  : Colors.white,
          child: ListTile(
            leading: Icon(
              Icons.local_florist,
              color: Color(0xFF29AB87), // Verde
            ),
            title: Text(
              '${entry['planta']} - ${entry['accion']}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color:
                    Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
              ),
            ),
            subtitle: Text(
              'Hora: ${entry['fecha']}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                    Provider.of<ThemeProvider>(context).isDarkMode
                        ? Color(0xFFFFBF00) // Amarillo en modo oscuro
                        : Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Color(0xFF29AB87); // Verde principal
    final secondaryColor = Color(0xFFFFBF00); // Amarillo secundario

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Historial de Cuidados",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color:
                isDark
                    ? secondaryColor
                    : Colors.white, // Amarillo en oscuro, blanco en claro
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? Color(0xFF1A1A1A)
                : primaryColor, // Gris oscuro en modo oscuro, verde en claro
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? secondaryColor : Colors.white,
            ),
            onPressed: _loadSavedActions,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      backgroundColor:
          isDark
              ? Color(0xFF121212)
              : Color(0xFFFFF2A6), // Fondo amarillo claro en modo claro
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? Color(0xFF1A1A1A) : Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime(2023),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {},
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: primaryColor, // Verde
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: primaryColor.withOpacity(
                          0.5,
                        ), // Verde con opacidad
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      weekendTextStyle: GoogleFonts.poppins(
                        color:
                            isDark
                                ? secondaryColor
                                : primaryColor, // Amarillo en oscuro, verde en claro
                      ),
                      markerDecoration: BoxDecoration(
                        color: primaryColor, // Verde
                        shape: BoxShape.circle,
                      ),
                      markerSize: 6,
                      markersAlignment: Alignment.bottomCenter,
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color:
                            isDark
                                ? secondaryColor
                                : primaryColor, // Amarillo en oscuro, verde en claro
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color:
                            isDark
                                ? secondaryColor
                                : primaryColor, // Amarillo en oscuro, verde en claro
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      weekendStyle: GoogleFonts.poppins(
                        color:
                            isDark
                                ? secondaryColor
                                : primaryColor, // Amarillo en oscuro, verde en claro
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ..._getActionsForDay(_selectedDay),
            ],
          ),
        ),
      ),
    );
  }
}
