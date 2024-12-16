import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';


class VisualizarUsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String imagen;
  final String apePat;
  final String apeMat;
  final String ci;
  final bool admin;
  final String telefono;
  final String rol;

  const VisualizarUsuarioScreen({super.key, 
    required this.idUsuario,
    required this.nombre,
    required this.imagen,
    required this.apePat,
    required this.apeMat,
    required this.ci,
    required this.admin,
    required this.telefono,
    required this.rol,
  });

  @override
  VisualizarUsuarioScreenState createState() =>
      VisualizarUsuarioScreenState();
}

class VisualizarUsuarioScreenState extends State<VisualizarUsuarioScreen> {
  String url = Url().apiUrl;
  String ip = Url().ip;

  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;

  @override
  void initState() {
    super.initState();
    fetchDatosUsuario();
  }

  Future<void> fetchDatosUsuario() async {
  try {
    final dio = Dio();
    final response = await dio.get('$url/usuario/roles/${widget.idUsuario}');

    if (response.statusCode == 200) {
      final responseBody = response.data;

      if (responseBody is List) {
        setState(() {
          datosUsuario = List<Map<String, dynamic>>.from(responseBody);
          imagenUsuario = (datosUsuario.isNotEmpty &&
                  datosUsuario[0]['usuarioImagen'] != null)
              ? 'images/${datosUsuario[0]['usuarioImagen']}'
              : 'images/default.png';
          isLoading = false;
        });
      } else {
        throw Exception('El formato de la respuesta no es una lista.');
      }
    } else {
      print('Error: ${response.statusCode}, Body: ${response.data}');
      throw Exception('Error al obtener los datos del usuario');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error en fetchDatosUsuario: $e');
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 100,
                          backgroundImage:
                              AssetImage(imagenUsuario ?? 'images/default.png'),
                        ),
                        const SizedBox(height: 20),
                        _buildUserInfoGrid(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildUserInfoGrid() {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600
              ? 2
              : 1,
          childAspectRatio: MediaQuery.of(context).size.width > 600
              ? 1.5
              : 0.8,
        ),
        itemCount: datosUsuario.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCommonUserInfoCard(datosUsuario[0]);
          } else {
            var usuario = datosUsuario[index - 1];
            if (usuario['rol'] == '2') {
              return _buildObservadorCard(usuario);
            } else if (usuario['rol'] == '3') {
              return _buildPromotorCard(usuario);
            }
          }
          return const SizedBox();
        },
      ),
    );
  }
  Widget _buildCommonUserInfoCard(Map<String, dynamic> usuario) {
    return Container(
      child: Card(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField(
                  'Nombre',
                  '${usuario['nombre']} ${usuario['apePat']} ${usuario['apeMat']}',
                  Icons.person),
              _buildReadOnlyField(
                  'CI', usuario['ci'] ?? 'N/A', Icons.credit_card),
              _buildReadOnlyField(
                  'Teléfono', usuario['telefono'] ?? 'N/A', Icons.phone),
              _buildReadOnlyField(
                  'Admin',
                  (usuario['admin'] ?? false) ? 'Sí' : 'No',
                  Icons.admin_panel_settings),
            ],
          ),
          // ),
        ),
      ),
    );
  }

  Widget _buildObservadorCard(Map<String, dynamic> usuario) {
    return Card(
      color: Colors.transparent,
      child: Container(
        //height: 300,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Municipio', usuario['municipio'] ?? 'N/A',
                  Icons.location_city),
              _buildReadOnlyField(
                  'Estación', usuario['estacion'] ?? 'N/A', Icons.dashboard),
              _buildReadOnlyField('Tipo Estación',
                  usuario['tipoEstacion'] ?? 'N/A', Icons.dashboard),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPromotorCard(Map<String, dynamic> usuario) {
    return Card(
      color: Colors.transparent,
      child: Container(
        //height: 800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Zona', usuario['zona'] ?? 'N/A', Icons.map),
              _buildReadOnlyField(
                  'Cultivo', usuario['cultivoNombre'] ?? 'N/A', Icons.abc),
              _buildReadOnlyField('Municipio', usuario['municipio'] ?? 'N/A',
                  Icons.location_city),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildReadOnlyField(
      String labelText, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: valueText,
        decoration: getInputDecoration(labelText, icon),
        readOnly: true,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

}
