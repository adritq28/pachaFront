import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          '© Pachatatiña 2024 | HELVETAS | EUROCLIMA | SENAMHI',
          style: GoogleFonts.convergence(
            textStyle: TextStyle(
              color: Color.fromARGB(255, 237, 237, 239),
              fontSize: 11.0,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}