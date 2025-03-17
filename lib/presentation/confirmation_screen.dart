import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts

class ConfirmationScreen extends StatelessWidget {
  final String plantName;

  ConfirmationScreen({required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "",
          style: GoogleFonts.poppins(), // Aplica la fuente Poppins
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 25),
            Text(
              "Planta $plantName agregada con éxito",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 70,
              width: 130,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Volver a la pantalla anterior
                },
                child: Text(
                  "Aceptar",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ), // Aplica la fuente Poppins
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
