import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Titulo extends StatelessWidget {
  final String title;

  const Titulo({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 20,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
