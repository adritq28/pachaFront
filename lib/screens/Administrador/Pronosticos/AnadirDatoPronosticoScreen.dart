import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class AnadirDatoPronosticoScreen extends StatefulWidget {
  final int idZona;

  const AnadirDatoPronosticoScreen({super.key,
    required this.idZona,
  });

  @override
  AnadirDatoPronosticoScreenState createState() =>
      AnadirDatoPronosticoScreenState();
}

class AnadirDatoPronosticoScreenState
    extends State<AnadirDatoPronosticoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _pcpnController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  @override
  void dispose() {
    _tempMaxController.dispose();
    _tempMinController.dispose();
    _pcpnController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
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
        setState(() {
          _fechaController.text =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime);
        });
      }
    }
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tempMaxController,
                            decoration: getInputDecoration(
                                'Temp Max', Icons.thermostat),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura ambiente';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tempMinController,
                            decoration: getInputDecoration(
                                'Temp Min', Icons.thermostat),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura ambiente';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pcpnController,
                            decoration: getInputDecoration(
                                'Precipitación', Icons.water),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                _selectDateTime,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fechaController,
                                decoration: getInputDecoration(
                                  'Fecha y Hora',
                                  Icons.calendar_today,
                                ),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
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
                            backgroundColor: const Color.fromARGB(255, 203, 230, 255),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => guardarDato(
                              context,
                              _formKey,
                              url,
                              widget.idZona,
                              _tempMaxController,
                              _tempMinController,
                              _pcpnController,
                              _fechaController,),
                          child: const Text('Añadir Dato'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
                  Footer(),
        ],
      ),
    );
  }
}
