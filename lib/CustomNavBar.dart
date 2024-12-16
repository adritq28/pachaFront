import 'package:flutter/material.dart';
import 'package:helvetasfront/screens/LoginScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';

class CustomNavBar extends StatelessWidget {
  final bool isHomeScreen;
  final bool showProfileButton;
  final int idUsuario;
  final PerfilEstado estado;
  final String? nombreMunicipio;
  final String? nombreEstacion;
  final String? nombreZona;
  final String? nombreCultivo;

  CustomNavBar({
    this.isHomeScreen = false,
    this.showProfileButton = false,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio,
    this.nombreEstacion,
    this.nombreZona,
    this.nombreCultivo,
  });

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: const Color.fromARGB(255, 9, 31, 67),
      elevation: 0,
      leadingWidth: isSmallScreen ? 100 : 56,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isHomeScreen)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          if (isSmallScreen)
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'PACHA',
                  style: getTextStyleNormal201(),
                ),
                const TextSpan(
                  text: 'YATIÑA',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (nombreMunicipio != null && nombreEstacion != null)
            Text(
              '$nombreMunicipio - $nombreEstacion',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (!isSmallScreen) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "Inicio",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (showProfileButton)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilScreen(idUsuario: idUsuario, estado: estado, nombreMunicipio: nombreMunicipio, nombreEstacion: nombreEstacion, nombreZona: nombreZona, nombreCultivo: nombreCultivo,),
                  ),
                );
              },
              child: const Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "Configuración",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}
