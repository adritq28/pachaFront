import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerProm extends StatelessWidget {
  final String imagenP;
  final String nombreCompleto;
  final String nombreZona;
  final String nombreCultivo;

  const BannerProm({
    super.key,
    required this.imagenP,
    required this.nombreCompleto,
    required this.nombreZona,
    required this.nombreCultivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color.fromARGB(91, 4, 18, 43),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("images/$imagenP"),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 5.0,
              children: [
                Text("Bienvenid@",
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                      color: Colors.white60,
                    ))),
                Text('| $nombreCompleto',
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
                Text('| Municipio de: $nombreZona',
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
                Text('| Cultivo de: $nombreCultivo',
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
