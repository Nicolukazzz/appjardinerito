import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appjardinerito/main.dart';
import 'package:appjardinerito/presentation/bluetooth_provider.dart';
import 'home_screen.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> _devicesList = [];
  bool _isScanning = false;
  bool _hasPermissions = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.bluetoothAdvertise,
            Permission.locationWhenInUse,
          ].request();

      setState(() {
        _hasPermissions = statuses.values.every((status) => status.isGranted);
      });

      if (_hasPermissions) {
        _startScan();
      } else {
        _showStatusMessage("Se requieren permisos para usar Bluetooth");
      }
    } else {
      PermissionStatus status = await Permission.bluetooth.request();
      setState(() => _hasPermissions = status.isGranted);
      if (_hasPermissions) _startScan();
    }
  }

  Future<bool> _checkBluetoothState() async {
    try {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
        await Future.delayed(Duration(seconds: 1));
      }
      return true;
    } catch (e) {
      _showStatusMessage("Error al activar Bluetooth");
      return false;
    }
  }

  void _startScan() async {
    if (_isScanning) return;

    bool isBluetoothOn = await _checkBluetoothState();
    if (!isBluetoothOn) {
      _showStatusMessage("Active el Bluetooth en su dispositivo");
      return;
    }

    setState(() {
      _isScanning = true;
      _devicesList.clear();
    });

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: 10),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        setState(() {
          _devicesList =
              results
                  .where((r) => r.device.name.isNotEmpty)
                  .map((r) => r.device)
                  .toList();
        });
      });

      await Future.delayed(Duration(seconds: 10));
    } catch (e) {
      _showStatusMessage("Error en escaneo: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
      await FlutterBluePlus.stopScan();
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isScanning = true;
      _statusMessage = "Conectando...";
    });

    try {
      await device.connect(autoConnect: false);
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? uartCharacteristic;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write ||
              characteristic.properties.notify) {
            uartCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            break;
          }
        }
      }

      bluetoothProvider.setConnectedDevice(device); // Persiste el dispositivo

      // Cambia esta línea para navegar a HomeScreen en lugar de UartChat
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false, // Esto elimina todas las pantallas previas
      );
    } catch (e) {
      _showStatusMessage("Error al conectar: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _disconnectDevice() {
    Provider.of<BluetoothProvider>(context, listen: false).disconnectDevice();
    setState(() => _statusMessage = "Desconectado");
  }

  void _showStatusMessage(String message) {
    setState(() => _statusMessage = message);
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) setState(() => _statusMessage = null);
    });
  }

  Widget _buildPermissionWarning(
    BuildContext context,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 50, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              "Permisos insuficientes",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "La aplicación necesita permisos para buscar dispositivos Bluetooth",
              style: GoogleFonts.poppins(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Otorgar permisos",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              onPressed: _requestPermissions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicator(bool isDarkMode) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              "Buscando dispositivos...",
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDevicesFound(bool isDarkMode, Color primaryColor) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No se encontraron dispositivos",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Asegúrese que los dispositivos están encendidos y visibles",
              style: GoogleFonts.poppins(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Reintentar",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              onPressed: _startScan,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final Color primaryColor =
        isDarkMode ? Colors.green[700]! : Color(0xFF487363);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conexión Bluetooth",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (bluetoothProvider.isConnected)
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: _disconnectDevice,
            ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_statusMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      size: 20,
                      color: isDarkMode ? Colors.green[300] : primaryColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            if (!_hasPermissions)
              _buildPermissionWarning(context, isDarkMode, primaryColor)
            else if (_isScanning && _devicesList.isEmpty)
              _buildScanningIndicator(isDarkMode)
            else if (_devicesList.isEmpty)
              _buildNoDevicesFound(isDarkMode, primaryColor)
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _devicesList.length,
                  itemBuilder: (context, index) {
                    final device = _devicesList[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      child: ListTile(
                        leading: Icon(Icons.bluetooth, color: primaryColor),
                        title: Text(
                          device.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          device.remoteId.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        onTap: () => _connectToDevice(device),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton:
          !bluetoothProvider.isConnected && _hasPermissions
              ? FloatingActionButton(
                backgroundColor: primaryColor,
                child: Icon(
                  _isScanning ? Icons.hourglass_top : Icons.search,
                  color: Colors.white,
                ),
                onPressed: _isScanning ? null : _startScan,
              )
              : null,
    );
  }
}
