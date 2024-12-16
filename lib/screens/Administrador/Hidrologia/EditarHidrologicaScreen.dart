import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';

class EditarHidrologicaScreen extends StatefulWidget {
  final int idHidrologica;
  final double limnimetro;
  final String fechaReg;

  const EditarHidrologicaScreen({
    super.key,
    required this.idHidrologica,
    required this.limnimetro,
    required this.fechaReg,
  });

  @override
  EditarHidrologicaScreenState createState() => EditarHidrologicaScreenState();
}

class EditarHidrologicaScreenState extends State<EditarHidrologicaScreen> {
  TextEditingController limnimetroController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  late EstacionHidrologicaService hidrologicaService =
      EstacionHidrologicaService();

  @override
  void initState() {
    super.initState();
    limnimetroController.text = widget.limnimetro.toString();
    fechaRegController.text = widget.fechaReg;
  }

  Future<void> _guardarCambios() async {
    bool success = await hidrologicaService.guardarCambios(
      idHidrologica: widget.idHidrologica,
      limnimetro: double.parse(limnimetroController.text),
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
                          controller: limnimetroController,
                          decoration: getInputDecoration(
                            'Limnimetro',
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
                        child: _buildDatePickerField(
                          context: context,
                          controller: fechaRegController,
                          label: 'Fecha Siembra',
                        ),
                      ),
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
          const SizedBox(height: 20),
          Footer(),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toIso8601String().split('T').first;
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: getInputDecoration(label, Icons.calendar_today),
          style: const TextStyle(
              fontSize: 17.0, color: Color.fromARGB(255, 201, 219, 255)),
        ),
      ),
    );
  }
}
