import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';

enum PerfilEstado {
  soloNombreTelefono,
  nombreEstacionMunicipio,
  nombreZonaCultivo
}

class PerfilScreen extends StatefulWidget {
  final int idUsuario;
  final PerfilEstado estado;
  final String? nombreMunicipio;
  final String? nombreEstacion;
  final String? nombreZona;
  final String? nombreCultivo;

  const PerfilScreen({
    super.key,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio,
    this.nombreEstacion,
    this.nombreZona,
    this.nombreCultivo,
  });

  @override
  PerfilScreenState createState() => PerfilScreenState();
}

class PerfilScreenState extends State<PerfilScreen> {
  late Future<Map<String, dynamic>> _perfilData;
  String url = Url().apiUrl;

  @override
  void initState() {
    super.initState();
    _perfilData = fetchPerfilData(widget.idUsuario);
  }

Future<Map<String, dynamic>> fetchPerfilData(int idUsuario) async {
  try {
    final dio = Dio();
    final response = await dio.get('$url/usuario/perfil/$idUsuario');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data.isNotEmpty) {
        return data[0];
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load perfil data');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error al conectar con el servidor');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
            isHomeScreen: false, showProfileButton: false,idUsuario: 0, estado: PerfilEstado.nombreEstacionMunicipio,), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          FutureBuilder<Map<String, dynamic>>(
            future: _perfilData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No hay datos disponibles'));
              } else {
                final perfil = snapshot.data!;
                return Center(
                  child: SizedBox(
                    width: 550,
                    height: 600,
                    child: Card(
                      color: const Color.fromARGB(91, 4, 18, 43),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height:40),
                            CircleAvatar(
                              radius: 120,
                              backgroundImage:
                                  AssetImage('images/${perfil['imagen']}'),
                              backgroundColor: const Color.fromARGB(
                              91, 4, 18, 43),
                            ),
                            const SizedBox(height:16),
                            Text(
                              '${perfil['nombreCompleto']}'.toUpperCase(),
                              
                                  style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Teléfono: ${perfil['telefono']}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (widget.estado ==
                                PerfilEstado.nombreEstacionMunicipio) ...[
                              Text('Estación: ${widget.nombreEstacion}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                              const SizedBox(height: 10),
                              Text('Municipio: ${widget.nombreMunicipio}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                            ] else if (widget.estado ==
                                PerfilEstado.nombreZonaCultivo) ...[
                              Text(
                                  'Zona: ${widget.nombreZona ?? 'No disponible'}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                              const SizedBox(height: 10),
                              Text(
                                  'Cultivo: ${widget.nombreCultivo ?? 'No disponible'}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
