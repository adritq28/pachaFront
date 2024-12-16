import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/FechaSiembraScreen.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/EstacionHidrologica.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/EstacionMeteorologica.dart';
import 'package:helvetasfront/screens/Administrador/Pronosticos/PronosticoScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/UsuarioScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/util/fondo.dart';

class AdminScreen extends StatelessWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;

  final String imagen;

  const AdminScreen({super.key,
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.soloNombreTelefono,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: 0,
          estado: PerfilEstado.soloNombreTelefono,
        ),
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 1000) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 3;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 70,
                        color: const Color.fromARGB(91, 4, 18, 43),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage("images/${imagen}"),
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
                                  Text(
                                      '| ${nombre} ${apePat} ${apeMat}',
                                      style: GoogleFonts.lexend(
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        crossAxisSpacing: 80,
                        mainAxisSpacing: 50,
                        padding: const EdgeInsets.all(60.0),
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildButton(
                            context,
                            "Estaciones Meteorológicas",
                            Icons.holiday_village_rounded,
                            const Color.fromARGB(255, 136, 96, 151),
                            const Color.fromARGB(255, 232, 200, 255),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EstacionMeteorologicaScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Estaciones Hidrológicas",
                            Icons.query_stats_outlined,
                            const Color.fromARGB(255, 161, 82, 73),
                            const Color.fromARGB(255, 255, 217, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EstacionHidrologicaScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Pronósticos Decenales",
                            Icons.satellite_rounded,
                            const Color.fromARGB(255, 144, 128, 63),
                            const Color.fromARGB(255, 255, 254, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PronosticoScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Fecha de Siembra de Cultivo",
                            Icons.calendar_month,
                            const Color.fromARGB(255, 57, 139, 91),
                            const Color.fromARGB(255, 201, 255, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FechaSiembraScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Usuarios",
                            Icons.account_circle,
                            const Color.fromARGB(255, 24, 110, 104),
                            const Color.fromARGB(255, 200, 255, 255),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsuarioScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color borderColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 200,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: borderColor,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: borderColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 242, 246, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
