import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/decorations/custom_decorations.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/CultivoService.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

class EditarCultivoScreen extends StatelessWidget {
  final int idCultivo;
  final String nombre;
  final String fechaSiembra;
  final String fechaReg;
  final String tipo;

  const EditarCultivoScreen({
    super.key,
    required this.idCultivo,
    required this.nombre,
    required this.fechaSiembra,
    required this.fechaReg,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CultivoService(
        idCultivo: idCultivo,
        nombre: nombre,
        fechaSiembra: fechaSiembra,
        fechaReg: fechaReg,
        tipo: tipo,
      ),
      child: const _EditarCultivoBody(),
    );
  }
}

class _EditarCultivoBody extends StatelessWidget {
  const _EditarCultivoBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CultivoService>(context);

    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
        ),
      body: FondoWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                controller: provider.nombreController,
                label: 'Nombre Cultivo',
                icon: Icons.thermostat,
              ),
              const SizedBox(height: 10),
              _buildDatePickerField(
                context: context,
                controller: provider.fechaSiembraController,
                label: 'Fecha Siembra',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool success = await provider.guardarCambios();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cambios guardados')),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al guardar cambios')),
                    );
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: getInputDecoration(label,
        icon,
      ),
      style: const TextStyle(fontSize: 17.0, color: Color.fromARGB(255, 201, 219, 255)),
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
            style: const TextStyle(fontSize: 17.0, color: Color.fromARGB(255, 201, 219, 255)),),
            
      ),
    );
  }
}
