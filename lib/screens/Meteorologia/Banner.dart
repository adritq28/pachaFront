import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerObs extends StatelessWidget {
  final String imagen;
  final String nombreCompleto;
  final String nombreMunicipio;
  final String nombreEstacion;

  const BannerObs({
    super.key,
    required this.imagen,
    required this.nombreCompleto,
    required this.nombreMunicipio,
    required this.nombreEstacion,
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
            backgroundImage: AssetImage("images/$imagen"),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 5.0,
              children: [
                Text("Bienvenid@",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                      color: Colors.white60,
                    ))),
                Text(' $nombreCompleto',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
                Text('| Municipio de: $nombreMunicipio',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
                Text('| Estación de: $nombreEstacion',
                    textAlign: TextAlign.center,
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
