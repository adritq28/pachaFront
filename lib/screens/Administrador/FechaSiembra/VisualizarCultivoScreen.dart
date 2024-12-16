import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/dateTime/DateTimePicker.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/util/fondo.dart';

class VisualizarCultivoScreen extends StatelessWidget {
  final int idCultivo;
  final String nombre;
  final String fechaSiembra;
  final String fechaReg;
  final String tipo;

  const VisualizarCultivoScreen(
      {super.key, required this.idCultivo,
      required this.nombre,
      required this.fechaSiembra,
      required this.fechaReg,
      required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,),
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
                  _buildDataRow(
                      'Nombre', '${nombre.toString()} °C', Icons.thermostat),
                  _buildDataRow('Tipo', '${tipo.toString()} mm', Icons.water),
                  _buildDataRow('Fecha y Hora de Siembra',
                      DateTimePicker.formatDateTime(fechaSiembra), Icons.calendar_today),
                  _buildDataRow('Fecha y Hora de Registro',
                      DateTimePicker.formatDateTime(fechaReg), Icons.calendar_today),
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
