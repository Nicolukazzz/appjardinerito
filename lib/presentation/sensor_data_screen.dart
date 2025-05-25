import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:appjardinerito/presentation/bluetooth_provider.dart';
import 'package:appjardinerito/presentation/calendar_screen.dart';
import 'package:appjardinerito/presentation/data_screen.dart';

class SensorDataScreen extends StatefulWidget {
  final String plantId;

  const SensorDataScreen({Key? key, required this.plantId}) : super(key: key);

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  static const UART_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const UART_TX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  static const UART_RX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  BluetoothCharacteristic? _uartRxCharacteristic;
  bool _isLoading = false;
  String _statusMessage = 'Presiona el botón para medir';
  List<String> _recommendations = [];
  String _selectedAction = 'Regada';

  double _humidity = 0;
  double _light = 0;
  double _temperature = 0;
  double _ph = 0;

  // Valores dinámicos obtenidos desde Firebase
  double _minHumidity = 40;
  double _minLight = 1000;
  double _minTemperature = 18;
  double _minPh = 5.5;
  double _maxPh = 7.0;

  final _actions = ['Regada', 'Cambiada de lugar', 'Cambiado el pH', 'Podada'];

  @override
  void initState() {
    super.initState();
    _loadFirebaseThresholds(); // 1️⃣ Carga los umbrales de Firebase
    _setupBluetooth();
  }

  Future<void> _loadFirebaseThresholds() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref().child(
        'plantas/${widget.plantId}/umbrales',
      );

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _minHumidity = (data['minHumidity'] ?? 40).toDouble();
          _minLight = (data['minLight'] ?? 1000).toDouble();
          _minTemperature = (data['minTemperature'] ?? 18).toDouble();
          _minPh = (data['minPh'] ?? 5.5).toDouble();
          _maxPh = (data['maxPh'] ?? 7.0).toDouble();
        });
      } else {
        print('No se encontraron umbrales para ${widget.plantId}');
      }
    } catch (e) {
      print('Error al cargar umbrales de Firebase: $e');
    }
  }

  Future<void> _setupBluetooth() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );

    if (!bluetoothProvider.isConnected) {
      setState(() => _statusMessage = 'Dispositivo no conectado');
      return;
    }

    try {
      final device = bluetoothProvider.connectedDevice!;
      if (!device.isConnected) {
        await device.connect(autoConnect: false);
        await Future.delayed(Duration(seconds: 1));
      }

      final services = await device.discoverServices();
      final uartService = services.firstWhere(
        (s) =>
            s.uuid.toString().toLowerCase() == UART_SERVICE_UUID.toLowerCase(),
      );

      _uartRxCharacteristic = uartService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() == UART_RX_CHAR_UUID.toLowerCase(),
      );

      final txChar = uartService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() == UART_TX_CHAR_UUID.toLowerCase(),
      );

      await txChar.setNotifyValue(true);
      txChar.value.listen(_processSensorData);

      setState(() => _statusMessage = 'Listo para medir');
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    }
  }

  void _processSensorData(List<int> data) {
    try {
      final sensorData = json.decode(String.fromCharCodes(data));
      setState(() {
        _humidity = sensorData["humidity"]?.toDouble() ?? 0;
        _light = sensorData["light"]?.toDouble() ?? 0;
        _temperature = sensorData["temperature"]?.toDouble() ?? 0;
        _ph = sensorData["ph"]?.toDouble() ?? 0;
        _isLoading = false;
        _statusMessage = "Medición completada";
        _generateRecommendations(); // 2️⃣ Genera recomendaciones con los umbrales de Firebase
      });
    } catch (e) {
      setState(() => _statusMessage = "Error: Formato inválido");
    }
  }

  void _generateRecommendations() {
    final recommendations = <String>[];

    if (_humidity < _minHumidity)
      recommendations.add("Agrega agua a la planta.");

    if (_light < _minLight)
      recommendations.add("Coloca la planta en un lugar más iluminado.");

    if (_temperature < _minTemperature)
      recommendations.add("Mantén la planta en un ambiente más cálido.");

    if (_ph < _minPh || _ph > _maxPh)
      recommendations.add("Ajusta el pH del suelo.");

    setState(() => _recommendations = recommendations);
  }

  Future<void> _takeMeasurements() async {
    if (_uartRxCharacteristic == null) {
      setState(() => _statusMessage = 'Error: Característica no disponible');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Midiendo...';
      _recommendations.clear();
    });

    try {
      await _uartRxCharacteristic!.write(utf8.encode('2\n'));
      await Future.delayed(Duration(seconds: 15));

      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Timeout: Sin respuesta";
        });
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    }
  }

  Future<void> _registerAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('plant_actions') ?? '{}';
      final savedActions = json.decode(jsonString) as Map<String, dynamic>;

      final now = DateTime.now();
      final dateKey = now.toIso8601String().substring(0, 10);
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      savedActions[dateKey] ??= [];
      (savedActions[dateKey] as List).add({
        'planta': widget.plantId,
        'accion': _selectedAction,
        'fecha': formattedTime,
        'fecha_completa': now.toIso8601String(),
      });

      await prefs.setString('plant_actions', json.encode(savedActions));
      await CalendarScreen.refresh(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Acción registrada: $_selectedAction"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar acción: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showActionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Registrar Acción", style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAction,
                items:
                    _actions
                        .map(
                          (action) => DropdownMenuItem(
                            value: action,
                            child: Text(action, style: GoogleFonts.poppins()),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedAction = value);
                },
                decoration: InputDecoration(
                  labelText: 'Acción realizada',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "¿Deseas registrar esta acción para ${widget.plantId}?",
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                _registerAction();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Registrar", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showPlantDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataScreen(plantId: widget.plantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = isDarkMode ? Colors.green[700] : Color(0xFF487363);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Datos de la Planta",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showActionDialog,
            tooltip: 'Registrar acción',
          ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.green,
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.plantId,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.9,
                      children: [
                        _buildDataCard(
                          context: context,
                          title: "Humedad",
                          value: "${_humidity.toStringAsFixed(0)}%",
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDataCard(
                          context: context,
                          title: "Luz",
                          value: "${_light.toStringAsFixed(0)} lux",
                          icon: Icons.light_mode,
                          color: Colors.amber[700]!,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDataCard(
                          context: context,
                          title: "Temperatura",
                          value: "${_temperature.toStringAsFixed(0)}°C",
                          icon: Icons.thermostat,
                          color: Colors.red,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDataCard(
                          context: context,
                          title: "PH",
                          value: _ph.toStringAsFixed(1),
                          icon: Icons.science,
                          color: Colors.purple,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  if (_recommendations.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      "Recomendaciones:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    ..._recommendations.map(
                      (rec) => ListTile(
                        leading: Icon(Icons.info, color: Colors.green),
                        title: Text(rec, style: GoogleFonts.poppins()),
                      ),
                    ),
                  ],
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showPlantDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Ver detalles',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _takeMeasurements,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(Icons.sensors, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Medir',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDataCard({
    required BuildContext context,
    required String title,
    required String value,
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
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
