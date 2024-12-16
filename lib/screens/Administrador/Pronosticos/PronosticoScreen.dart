import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/Pronosticos/DatosPronosticoScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';

class PronosticoScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;
  final String imagen;

  const PronosticoScreen({super.key,
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.imagen
  });

  @override
  PronosticoScreenState createState() => PronosticoScreenState();
}

class PronosticoScreenState extends State<PronosticoScreen> {
  List<Map<String, dynamic>> zonas = [];
  Map<String, List<Map<String, dynamic>>> zonasPorMunicipio = {};
  String? municipioSeleccionado;
  String? zonaSeleccionada;
  int? idzonaSeleccionada;
  String url = Url().apiUrl;
  String ip = Url().ip;
  late PronosticoService pronosticoService=PronosticoService();
  late EstacionHidrologicaService estacionService=EstacionHidrologicaService();
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    cargarZona();
  }

  Future<void> cargarZona() async {
    try {
      final zonasCargadas = await pronosticoService.zonaID();
      setState(() {
        zonas = zonasCargadas;
        zonasPorMunicipio = estacionService.agruparEstacionesPorMunicipio(zonas);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las zonas')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparzonasPorMunicipio(
      List<Map<String, dynamic>> zonas) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var zona in zonas) {
      if (!agrupadas.containsKey(zona['nombreMunicipio'])) {
        agrupadas[zona['nombreMunicipio']] = [];
      }
      agrupadas[zona['nombreMunicipio']]!.add(zona);
    }
    return agrupadas;
  }

  void navigateToDatosPronosticoScreen() {
    if (idzonaSeleccionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DatosPronosticoScreen(
            idZona: idzonaSeleccionada!,
            nombreMunicipio: municipioSeleccionado!,
            nombreZona: zonaSeleccionada!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.soloNombreTelefono,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: widget.idUsuario,
          estado: PerfilEstado.soloNombreTelefono,
        ),
      ),
      body: FondoWidget(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 70,
              color: const Color.fromARGB(
                  91, 4, 18, 43),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("images/${widget.imagen}"),
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.0,
                      runSpacing: 5.0,
                      children: [
                        Text("Bienvenid@",
                            style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                              color: Colors.white60,
                            ))),
                        Text(
                            '| ${widget.nombre} ${widget.apePat} ${widget.apeMat}',
                            style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: zonas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: zonasPorMunicipio.keys.length,
                      itemBuilder: (context, index) {
                        String municipio =
                            zonasPorMunicipio.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      municipioSeleccionado = municipio;
                                      zonaSeleccionada = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 203, 230, 255),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      municipio,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 34, 52, 96),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (municipioSeleccionado != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Seleccione una estación en $municipioSeleccionado:',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 234, 240, 255),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: zonaSeleccionada,
                      hint: const Text(
                        'Seleccione una estación',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 236, 241, 255),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          zonaSeleccionada = newValue;
                          idzonaSeleccionada =
                              zonasPorMunicipio[municipioSeleccionado]!
                                  .firstWhere((element) =>
                                      element['nombreZona'] ==
                                      newValue)['idZona'];
                          navigateToDatosPronosticoScreen();
                        });
                      },
                      items: zonasPorMunicipio[municipioSeleccionado]!
                          .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> zona) {
                        return DropdownMenuItem<String>(
                          value: zona['nombreZona'],
                          child: Text(zona['nombreZona']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
