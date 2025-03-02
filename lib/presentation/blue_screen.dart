import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Para íconos animados
import 'uart_chat.dart'; // Importamos el nuevo archivo

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  bool isScanning = false;
  bool isConnected = false;
  bool isConnecting = false;
  bool isRefreshing = false;
  bool hasPermissions = false;
  bool showError = false;
  String? connectionMessage;
  bool showConnectionMessage = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();

    if (statuses.values.every((status) => status.isGranted)) {
      setState(() {
        hasPermissions = true;
      });
      _startScan();
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitChasingDots(
                    color: Colors.blue, // Color de la animación
                    size: 50, // Tamaño de la animación
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        isConnecting = false;
                      });
                    },
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showConnectionMessage(String message, bool isSuccess) {
    setState(() {
      connectionMessage = message;
      showConnectionMessage = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showConnectionMessage = false;
        });
      }
    });
  }

  void _startScan() {
    if (isRefreshing || isConnecting || !hasPermissions) return;
    setState(() {
      isRefreshing = true;
      devicesList.clear();
      showError = false;
    });

    _showLoadingDialog("Buscando dispositivos...");

    FlutterBluePlus.startScan(timeout: Duration(seconds: 3));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (ScanResult result in results) {
          if (!devicesList.contains(result.device)) {
            devicesList.add(result.device);
          }
        }
      });
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
      setState(() {
        isRefreshing = false;
        if (devicesList.isEmpty) {
          showError = true;
        }
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (isConnecting || isRefreshing) return;
    setState(() {
      isConnecting = true;
    });

    _showLoadingDialog("Intentando conectar...");

    try {
      await device.connect(autoConnect: true);
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            characteristic = char;
          }
          if (char.properties.notify) {
            await char.setNotifyValue(true);
          }
        }
      }
      setState(() {
        connectedDevice = device;
        isConnected = true;
      });
      Navigator.pop(context);
      _showConnectionMessage("Conectado a ${device.name}", true);
    } catch (e) {
      setState(() {
        isConnecting = false;
      });
      Navigator.pop(context);
      _showConnectionMessage("Error al conectar", false);
    }
  }

  void _disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        isConnected = false;
        characteristic = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Conexión Bluetooth"),
        centerTitle: true,
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.green,
        actions: [
          if (isConnected)
            IconButton(icon: Icon(Icons.close), onPressed: _disconnectDevice),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!isConnected)
                  Expanded(
                    child:
                        !hasPermissions
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bluetooth_disabled,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Se necesitan permisos para escanear dispositivos",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            : devicesList.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    showError
                                        ? "No se encontraron dispositivos"
                                        : "Buscando dispositivos...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          showError ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: devicesList.length,
                              itemBuilder: (context, index) {
                                BluetoothDevice device = devicesList[index];
                                return FadeIn(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 20,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        device.name.isNotEmpty
                                            ? device.name
                                            : "Dispositivo sin nombre",
                                      ),
                                      subtitle: Text(device.id.toString()),
                                      trailing: Icon(
                                        Icons.bluetooth,
                                        color: Colors.blue,
                                      ),
                                      onTap:
                                          isConnecting
                                              ? null
                                              : () => _connectToDevice(device),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                if (isConnected && connectedDevice != null)
                  Expanded(
                    child: UartChat(
                      device: connectedDevice!,
                      characteristic: characteristic,
                    ),
                  ),
              ],
            ),
          ),
          if (showConnectionMessage)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FadeInUp(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color:
                        connectionMessage!.contains("Error")
                            ? Colors.red[400]
                            : Colors.green[400],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    connectionMessage!,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          !isConnected
              ? FloatingActionButton(
                onPressed: isRefreshing ? null : _startScan,
                child: Icon(Icons.refresh),
              )
              : null,
    );
  }
}
