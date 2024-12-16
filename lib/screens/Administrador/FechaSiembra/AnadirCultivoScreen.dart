import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/dateTime/DateTimePicker.dart';
import 'package:helvetasfront/decorations/custom_decorations.dart';
import 'package:helvetasfront/model/Cultivo.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/CultivoService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

class AnadirCultivoScreen extends StatelessWidget {
  final int idZona;

  const AnadirCultivoScreen({super.key, required this.idZona});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CultivoFormState(),
      child: Scaffold(
        drawer: CustomDrawer(idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
        ),
        body: Consumer<CultivoFormState>(
          builder: (context, formState, child) {
            return Stack(
              children: [
                const FondoWidget(),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          _buildRowFields(formState),
                          const SizedBox(height: 20),
                          _buildDateField(formState, context),
                          const SizedBox(height: 20),
                          _buildSubmitButton(formState, context),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Footer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRowFields(CultivoFormState formState) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: TextEditingController(text: formState.nombre),
            label: 'Nombre Cultivo',
            icon: Icons.thermostat,
            onChanged: (value) => formState.setNombre(value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: TextEditingController(text: formState.tipo),
            label: 'Tipo Cultivo',
            icon: Icons.thermostat,
            onChanged: (value) => formState.setTipo(value),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: getInputDecoration(label, icon),
      style: const TextStyle(fontSize: 17.0, color: Color.fromARGB(255, 201, 219, 255)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(CultivoFormState formState, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final selectedDate = await DateTimePicker.selectDateTime(context, TextEditingController());
              if (selectedDate != null) {
                formState.setFechaSiembra(selectedDate);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(text: formState.fechaSiembra),
                decoration: getInputDecoration('Fecha y Hora de Siembra', Icons.calendar_today),
                style: const TextStyle(fontSize: 17.0, color: Color.fromARGB(255, 201, 219, 255)),
                keyboardType: TextInputType.datetime,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSubmitButton(CultivoFormState formState, BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 203, 230, 255),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            guardarDato(
              context,
              Url().apiUrl,
              idZona,
            );
          },
          child: const Text('Añadir Dato'),
        ),
      ),
    );
  }
}
