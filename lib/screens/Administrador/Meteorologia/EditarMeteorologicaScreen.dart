import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';

class EditarMeteorologicaScreen extends StatefulWidget {
  final int idDatosEst;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  final double tempAmb;
  final String dirViento;
  final double velViento;
  final double taevap;
  final String fechaReg;

  const EditarMeteorologicaScreen({super.key,
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

  @override
  EditarMeteorologicaScreenState createState() =>
      EditarMeteorologicaScreenState();
}

class EditarMeteorologicaScreenState extends State<EditarMeteorologicaScreen> {
  TextEditingController tempMaxController = TextEditingController();
  TextEditingController tempMinController = TextEditingController();
  TextEditingController pcpnController = TextEditingController();
  TextEditingController tempAmbController = TextEditingController();
  TextEditingController dirVientoController = TextEditingController();
  TextEditingController velVientoController = TextEditingController();
  TextEditingController taevapController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  late EstacionService estacionService=EstacionService();
  
  
  @override
  void initState() {
    super.initState();
    tempMaxController.text = widget.tempMax.toString();
    tempMinController.text = widget.tempMin.toString();
    pcpnController.text = widget.pcpn.toString();
    tempAmbController.text = widget.tempAmb.toString();
    dirVientoController.text = widget.dirViento;
    velVientoController.text = widget.velViento.toString();
    taevapController.text = widget.taevap.toString();
    fechaRegController.text = widget.fechaReg;
  }

  

  Future<void> _guardarCambios() async {
  bool success = await estacionService.guardarCambios(
    idEstacion: widget.idDatosEst,
    tempMax: double.parse(tempMaxController.text),
    tempMin: double.parse(tempMinController.text),
    pcpn: double.parse(pcpnController.text),
    tempAmb: double.parse(tempAmbController.text),
    dirViento: dirVientoController.text,
    velViento: double.parse(velVientoController.text),
    taevap: double.parse(taevapController.text),
    fechaReg: fechaRegController.text,
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
                      Expanded(
                        child: TextField(
                          controller: tempAmbController,
                          decoration: getInputDecoration(
                            'Temperatura Ambiente',
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
                          controller: dirVientoController,
                          decoration: getInputDecoration(
                            'Dirección Viento',
                            Icons.air,
                          ),
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: velVientoController,
                          decoration: getInputDecoration(
                            'Velocidad Viento',
                            Icons.speed,
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
                          controller: taevapController,
                          decoration: getInputDecoration(
                            'Evaporación',
                            Icons.speed,
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
                          backgroundColor: const Color.fromARGB(255, 203, 230, 255),
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
