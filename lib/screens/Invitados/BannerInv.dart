import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerInv extends StatelessWidget {
  final String nombreMunicipio;
  final String nombreZona;
  final String nombreCultivo;

  const BannerInv({
    super.key,
    required this.nombreMunicipio,
    required this.nombreZona,
    required this.nombreCultivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: const Color.fromARGB(91, 4, 18, 43),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 15),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 5.0,
              children: [
                Text(
                  "Bienvenido Invitado",
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
                Text(
                  '| Municipio de: $nombreMunicipio',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  '| Zona: $nombreZona',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  ' | Cultivo de $nombreCultivo',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
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
