import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appjardinerito/main.dart';
import 'bluetooth_screen.dart';
import 'bluetooth_provider.dart';

class AlvaritoBlueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final isConnected = bluetoothProvider.isConnected;

    final Color mainColor =
        isConnected ? Colors.lightBlue.shade200 : Colors.red.shade200;
    final Color strongColor =
        isConnected ? Colors.blue.shade700 : Colors.red.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo degradado vertical moderno
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, 0.8), // Termina a 80% de la altura
                  colors: [
                    mainColor.withOpacity(0.7),
                    mainColor.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),

                          Icon(
                            isConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            size: 90,
                            color: strongColor,
                          ),

                          const SizedBox(height: 30),

                          Text(
                            isConnected
                                ? 'Conectado a ${bluetoothProvider.connectedDevice?.name ?? "dispositivo"}'
                                : 'Bluetooth desconectado',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 50),

                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mainColor.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: strongColor.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/blue_icon.png',
                                width: 180,
                                height: 180,
                                color: strongColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BluetoothScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: strongColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Configurar Bluetooth',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          if (isConnected)
                            TextButton(
                              onPressed: () {
                                bluetoothProvider.disconnectDevice();
                              },
                              child: Text(
                                'Desconectar dispositivo',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: strongColor,
                                ),
                              ),
                            ),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
