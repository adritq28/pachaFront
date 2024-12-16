import 'package:flutter/material.dart';
import 'package:helvetasfront/screens/LoginScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';

class CustomDrawer extends StatelessWidget {
  final bool showProfileButton;
  final int idUsuario;
  final PerfilEstado estado;
  final String? nombreMunicipio;
  final String? nombreEstacion;
  final String? nombreZona;
  final String? nombreCultivo;

  CustomDrawer({
    this.showProfileButton = true,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio,
    this.nombreEstacion,
    this.nombreZona,
    this.nombreCultivo,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF48C9B0)),
            child: Text('Menú de Navegación', style: getTextStyleNormal24()),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          if (showProfileButton)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilScreen(
                      idUsuario: idUsuario,
                      estado: estado,
                      nombreMunicipio: nombreMunicipio,
                      nombreEstacion: nombreEstacion,
                      nombreZona: nombreZona,
                      nombreCultivo: nombreCultivo,
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
