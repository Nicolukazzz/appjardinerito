import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';

import 'package:appjardinerito/presentation/bluetooth_provider.dart';

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

  double _humidity = 0;
  double _light = 0;
  double _temperature = 0;
  double _ph = 0;

  @override
  void initState() {
    super.initState();
    _setupBluetooth();
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
        _generateRecommendations();
      });
    } catch (e) {
      setState(() => _statusMessage = "Error: Formato inválido");
    }
  }

  void _generateRecommendations() {
    final recommendations = <String>[];

    if (_humidity < 40) recommendations.add("Agrega agua a la planta.");
    if (_light < 1000)
      recommendations.add("Coloca la planta en un lugar más iluminado.");
    if (_temperature < 18)
      recommendations.add("Mantén la planta en un ambiente más cálido.");
    if (_ph < 5.5 || _ph > 7) recommendations.add("Ajusta el pH del suelo.");

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
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _takeMeasurements,
        backgroundColor: primaryColor,
        icon:
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.sensors, color: Colors.white),
        label: Text(
          'Medir',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
