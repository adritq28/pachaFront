import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/DatosEstacionHidrologica.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnadirDatoHidrologicoScreen extends StatelessWidget {
  final int idEstacion;

  const AnadirDatoHidrologicoScreen({
    super.key,
    required this.idEstacion,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        Provider.of<DatosEstacionHidrologica>(context, listen: false)
            .setFechaReg(
                DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatosEstacionHidrologica(),
      child: Scaffold(
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
                child: Consumer<DatosEstacionHidrologica>(
                  builder: (context, formState, _) {
                    return Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: TextFormField(
                                initialValue: formState.limnimetro != null
                                    ? formState.limnimetro.toString()
                                    : '',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: getInputDecoration(
                                  'Limnimetro',
                                  Icons.thermostat,
                                ),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                onChanged: (value) {
                                  final double? newLimnimetro =
                                      double.tryParse(value);
                                  if (newLimnimetro != null) {
                                    formState.setLimnimetro(newLimnimetro);
                                  } else {
                                    formState.setLimnimetro(0);
                                  }
                                },
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDateTime(context),
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: formState.fechaReg),
                                      decoration: getInputDecoration(
                                        'Fecha y Hora',
                                        Icons.calendar_today,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  if (formState.validateForm()) {
                                    guardarDato(
                                      context,
                                      idEstacion,
                                      Url().apiUrl,
                                      formState.limnimetro,
                                      formState.fechaReg,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Por favor, complete todos los campos')),
                                    );
                                  }
                                },
                                child: const Text('Añadir Dato'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Footer(),
          ],
        ),
      ),
    );
  }

  
}
