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
    setState(() {
      _savedActions = json.decode(jsonString);
    });
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
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      ];
    }

    return [
      Padding(
        padding: EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          "Acciones registradas:",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      ...(actions as List).map((entry) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          child: ListTile(
            leading: Icon(Icons.local_florist, color: Colors.green),
            title: Text(
              entry['planta'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(entry['accion'], style: GoogleFonts.poppins()),
          ),
        );
      }).toList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Historial de Cuidados",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.green,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
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
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime(2023),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.green,
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
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.green,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.green,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(),
                      weekendStyle: GoogleFonts.poppins(color: Colors.green),
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
