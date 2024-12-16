import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class VisualizarMeteorologicaScreen extends StatelessWidget {
  final int idDatosEst;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  final double tempAmb;
  final String dirViento;
  final double velViento;
  final double taevap;
  final String fechaReg;

  const VisualizarMeteorologicaScreen({super.key,
    required this.idDatosEst,
    required this.tempMax,
    required this.tempMin,
    required this.pcpn,
    required this.tempAmb,
    required this.dirViento,
    required this.velViento,
    required this.taevap,
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
                  _buildDataRow('Temperatura Máxima', '${tempMax.toString()} °C', Icons.thermostat),
                  _buildDataRow('Temperatura Mínima', '${tempMin.toString()} °C', Icons.thermostat),
                  _buildDataRow('Precipitación', '${pcpn.toString()} mm', Icons.water),
                  _buildDataRow('Temperatura Ambiente', '${tempAmb.toString()} °C', Icons.thermostat),
                  _buildDataRow('Dirección Viento', dirViento, Icons.air),
                  _buildDataRow('Velocidad Viento', '${velViento.toString()} km/h', Icons.speed),
                  _buildDataRow('Evaporación', '${taevap.toString()} mm', Icons.speed),
                  _buildDataRow('Fecha y Hora', formatDateTime(fechaReg), Icons.calendar_today),
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
