import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';

class EditarPronosticoScreen extends StatefulWidget {
  final int idPonostico;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  final String fecha;

  const EditarPronosticoScreen({
    super.key,
    required this.idPonostico,
    required this.tempMax,
    required this.tempMin,
    required this.pcpn,
    required this.fecha,
  });

  @override
  EditarPronosticoScreenState createState() => EditarPronosticoScreenState();
}

class EditarPronosticoScreenState extends State<EditarPronosticoScreen> {
  TextEditingController tempMaxController = TextEditingController();
  TextEditingController tempMinController = TextEditingController();
  TextEditingController pcpnController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  late PronosticoService hidrologicaService = PronosticoService();

  @override
  void initState() {
    super.initState();
    tempMaxController.text = widget.tempMax.toString();
    tempMinController.text = widget.tempMin.toString();
    pcpnController.text = widget.pcpn.toString();
    fechaController.text = widget.fecha;
  }

  Future<void> _guardarCambios() async {
    bool success = await hidrologicaService.guardarCambios(
      idPronostico: widget.idPonostico,
      tempMax: double.parse(tempMaxController.text),
      tempMin: double.parse(tempMinController.text),
      pcpn: double.parse(pcpnController.text),
      fecha: fechaController.text,
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
    }
  }

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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tempMaxController,
                          decoration: getInputDecoration(
                            'Temperatura Máxima',
                            Icons.thermostat,
                          ),
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: tempMinController,
                          decoration: getInputDecoration(
                            'Temperatura Mínima',
                            Icons.thermostat,
                          ),
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pcpnController,
                          decoration: getInputDecoration(
                            'Precipitación',
                            Icons.water,
                          ),
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 203, 230, 255),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _guardarCambios,
                        child: const Text('Guardar Cambios'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
