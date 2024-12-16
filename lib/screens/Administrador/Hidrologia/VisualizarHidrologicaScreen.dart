import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class VisualizarHidrologicaScreen extends StatelessWidget {
  final int idHidrologica;
  final double limnimetro;
  final String fechaReg;

  const VisualizarHidrologicaScreen({super.key, 
    required this.idHidrologica,
    required this.limnimetro,
    required this.fechaReg,
  });

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _buildDataRow('Limnimetro', '${limnimetro.toString()} cm', Icons.water),
                  _buildDataRow('Fecha y Hora de registro', formatDateTime(fechaReg), Icons.calendar_today),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String labelText, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 201, 219, 255),
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$labelText: $valueText',
              style: const TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 201, 219, 255),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
