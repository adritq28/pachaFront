import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Invitados/PronosticoAgrometeorologico.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/FenologiaService.dart';
import 'package:helvetasfront/services/MunicipioService.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ZonasScreen extends StatefulWidget {
  final int idMunicipio;
  final String nombreMunicipio;

  const ZonasScreen({super.key,
    required this.idMunicipio,
    required this.nombreMunicipio,
  });

  @override
  ZonasScreenState createState() => ZonasScreenState();
}

class ZonasScreenState extends State<ZonasScreen> {
  late MunicipioService miModelo5;

  @override
  void initState() {
    super.initState();
    miModelo5 = Provider.of<MunicipioService>(context, listen: false);
    _cargarMunicipio();
  }

  Future<void> _cargarMunicipio() async {
    try {
      await miModelo5
          .obtenerZonas(widget.idMunicipio);
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.nombreEstacionMunicipio,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: 0,
          estado: PerfilEstado.nombreEstacionMunicipio,
        ),
      ),
      backgroundColor: const Color(0xFF164092),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: op2(context),
      ),
    );
  }

  Widget op2(BuildContext context) {
    return Consumer<MunicipioService>(
      builder: (context, miModelo5, _) {
        final zonasMap = {
          for (var dato in miModelo5.lista11)
            dato.nombreZona: {
              'latitud': dato.latitud,
              'longitud': dato.longitud
            }
        };

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: zonasMap.length,
                  itemBuilder: (context, index) {
                    final nombreZona = zonasMap.keys.elementAt(index);
                    final latitud = zonasMap[nombreZona]?['latitud'] ?? 0.0;
                    final longitud = zonasMap[nombreZona]?['longitud'] ?? 0.0;
                    return _buildZonaCard(
                      context,
                      nombreZona,
                      miModelo5,
                      latitud,
                      longitud,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Footer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZonaCard(BuildContext context, String nombreZona,
      MunicipioService miModelo5, double latitud, double longitud) {
    return GestureDetector(
      onTap: () {
        _showFechasSiembraDialog(context, nombreZona, miModelo5);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 400,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(latitud, longitud),
                  zoom: 16.0,
                ),
                nonRotatedChildren: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(latitud, longitud),
                        builder: (ctx) => Container(
                          child: const Icon(
                            Icons.location_pin,
                            color: Color.fromARGB(255, 209, 54, 244),
                            size: 40,
                          ),
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: const LatLng(-13.5000, -58.1500),
                        builder: (ctx) => Container(
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              'Zona: $nombreZona',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Selecciona una fecha de siembra para ver el pronóstico',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFechasSiembraDialog(
      BuildContext context, String nombreZona, MunicipioService miModelo5) {
    final fechasSiembra = miModelo5.lista11
        .where((dato) => dato.nombreZona == nombreZona)
        .toList();

    List<String> selectedDates = [];
    Color hoverColor =
        const Color.fromARGB(151, 196, 148, 251).withOpacity(0.2);
    Color normalColor = Colors.transparent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Fechas de Siembra para $nombreZona",
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 64, 142),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: fechasSiembra.map((dato) {
                          return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) {
                                setState(() {
                                  selectedDates.add(dato.nombreFechaSiembra);
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  selectedDates.remove(dato.nombreFechaSiembra);
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  SystemMouseCursors.click;
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ChangeNotifierProvider(
                                          create: (context) =>
                                              FenologiaService(),
                                          child: PronosticoAgrometeorologico(
                                            idZona: dato.idZona,
                                            nombreMunicipio:
                                                dato.nombreMunicipio,
                                            idCultivo: dato.idCultivo,
                                            nombreZona: dato.nombreZona,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedDates
                                            .contains(dato.nombreFechaSiembra)
                                        ? hoverColor
                                        : normalColor,
                                    borderRadius: BorderRadius.circular(
                                        10),
                                  ),

                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 144, 101, 51),
                                        borderRadius: BorderRadius.circular(
                                            10),
                                      ),
                                      child: ListTile(
                                        title:
                                            Text('- ${dato.nombreFechaSiembra}',
                                                style: GoogleFonts.lexend(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                600
                                                            ? 14
                                                            : 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )),
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      color: const Color.fromARGB(91, 4, 18, 43),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage("images/47.jpg"),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              runSpacing: 5.0,
              children: [
                Text(
                  "Bienvenid@ Invitado",
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
                Text(
                  '| Municipio de: ${widget.nombreMunicipio}',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  ' | Lista de Zonas ',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
