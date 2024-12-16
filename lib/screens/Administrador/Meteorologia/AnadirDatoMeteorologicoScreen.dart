import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class AnadirDatoMeteorologicoScreen extends StatefulWidget {
  final int idEstacion;

  const AnadirDatoMeteorologicoScreen({super.key,
    required this.idEstacion,
  });

  @override
  AnadirDatoMeteorologicoScreenState createState() =>
      AnadirDatoMeteorologicoScreenState();
}

class AnadirDatoMeteorologicoScreenState
    extends State<AnadirDatoMeteorologicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _pcpnController = TextEditingController();
  final TextEditingController _tempAmbController = TextEditingController();
  final TextEditingController _dirVientoController = TextEditingController();
  final TextEditingController _velVientoController = TextEditingController();
  final TextEditingController _taevapController = TextEditingController();
  final TextEditingController _fechaRegController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  late EstacionService estacionService=EstacionService();
  
  @override
  void dispose() {
    _tempMaxController.dispose();
    _tempMinController.dispose();
    _pcpnController.dispose();
    _tempAmbController.dispose();
    _dirVientoController.dispose();
    _velVientoController.dispose();
    _taevapController.dispose();
    _fechaRegController.dispose();
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
          _fechaRegController.text =
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
                                  return 'Por favor ingresa la temperatura máxima';
                                }
                                final double? tempMax = double.tryParse(value);
                                if (tempMax == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMax < -5 || tempMax > 35) {
                                  return 'La temperatura debe estar entre -18 y 15';
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
                                  return 'Por favor ingresa la temperatura mínima';
                                }
                                final double? tempMin = double.tryParse(value);
                                if (tempMin == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMin < -18 || tempMin > 15) {
                                  return 'La temperatura debe estar entre -18 y 15';
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              final double? precipitation =
                                  double.tryParse(value);
                              if (precipitation == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (precipitation < 0 || precipitation > 70) {
                                return 'La precipitación debe estar entre 0 y 50';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tempAmbController,
                            decoration: getInputDecoration(
                                'Temp Ambiente', Icons.thermostat),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              final double? tempAmb = double.tryParse(value);
                              if (tempAmb == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempAmb < 0 || tempAmb > 90) {
                                return 'La temperatura ambiente debe estar entre 0 y 90';
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
                            controller: _dirVientoController,
                            decoration:
                                getInputDecoration('Dir Viento', Icons.air),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            )
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _velVientoController,
                            decoration:
                                getInputDecoration('Vel Viento', Icons.speed),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }

                              final double? dirviento = double.tryParse(value);
                              if (dirviento == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (dirviento < 0 || dirviento > 20) {
                                return 'La velocidad del viento debe estar entre 0 y 20';
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
                            controller: _taevapController,
                            decoration:
                                getInputDecoration('Evaporación', Icons.speed),
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                final double? evaporacion =
                                    double.tryParse(value);
                                if (evaporacion == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (evaporacion < 0 || evaporacion > 80) {
                                  return 'La evaporacion debe estar entre 0 y 80';
                                }
                                return null;
                              }
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                _selectDateTime,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fechaRegController,
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
                          onPressed:  () => estacionService.guardarDato(
                              context,
                              _formKey,
                              widget.idEstacion,
                              url,
                              _tempMaxController,
                              _tempMinController,
                              _pcpnController,
                              _fechaRegController,
                              _tempAmbController,
                              _dirVientoController,
                              _velVientoController,
                              _taevapController),
                          child: const Text('Añadir Dato'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
