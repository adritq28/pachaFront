import 'dart:io';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/Utils/mobile_utils.dart';
import 'package:helvetasfront/model/DatosPronostico.dart';
import 'package:helvetasfront/model/Fenologia.dart';
import 'package:helvetasfront/model/HistFechaSiembra.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/FenologiaService.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PronosticoAgrometeorologico extends StatefulWidget {
  final int idZona;
  final String nombreMunicipio;
  final int idCultivo;
  final String nombreZona;

  const PronosticoAgrometeorologico(
      {super.key,
      required this.idZona,
      required this.nombreMunicipio,
      required this.idCultivo,
      required this.nombreZona});

  @override
  PronosticoAgrometeorologicoState createState() =>
      PronosticoAgrometeorologicoState();
}

class PronosticoAgrometeorologicoState
    extends State<PronosticoAgrometeorologico> {
  late FenologiaService miModelo5;
  late Future<Map<String, dynamic>>? _futureUltimaAlerta;

  late Future<List> futurePronosticoCultivo;
  late Future<List<Map<String, dynamic>>> futurePcpnFase;
  List<HistFechaSiembra> fechasSiembra = [];
  HistFechaSiembra? _selectedFechaSiembra;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    miModelo5 = Provider.of<FenologiaService>(context, listen: false);
    _cargarFenologia();
    _cargarFenologia2();
    _fetchFechasSiembra();
  }

  Future<List<Map<String, dynamic>>> fetchComunidades(int idZona) async {
    try {
      final dio = Dio();
      final response = await dio.get('$url/zona/lista_comunidad/$idZona');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error al obtener las comunidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> exportToExcel(
    List<Fenologia> datosList,
  ) async {
    try {
      var excel = excel_pkg.Excel.createExcel();
      var sheet = excel['Sheet1'];
      var aux = 1;
      sheet.appendRow([
        'FASE',
        'Temp. letal min',
        'Temp. opt min',
        'Umb. inf',
        'Umb. sup',
        'Temp. opt max',
        'Temp. letal max'
      ]);
      for (var dato in datosList) {
        sheet.appendRow([
          aux++,
          dato.tempMin.toString(),
          dato.tempOptMin.toString(),
          dato.umbInf.toString(),
          dato.umbSup.toString(),
          dato.tempOptMax.toString(),
          dato.tempMax.toString(),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('No se pudo generar el archivo Excel.');
      }

      if (kIsWeb) {
        await downloadExcelMobile2(fileBytes, "Umbrales.xlsx");
      } else {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/Umbrales.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        OpenFile.open(filePath);
      }

      print('Archivo listo para descargar');
    } catch (e) {
      print('Error al guardar el archivo: $e');
    }
  }

  void exportarDato() async {
    try {
      await exportToExcel(miModelo5.lista11);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  Future<void> _fetchFechasSiembra() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$url/cultivos/fechas/${widget.idCultivo}',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        setState(() {
          fechasSiembra =
              data.map((json) => HistFechaSiembra.fromJson(json)).toList();
        });
      } else {
        throw Exception('No se encontró');
      }
    } catch (e) {
      throw Exception('Error al obtener las fechas de siembra: $e');
    }
  }

  Future<void> _cargarFenologia() async {
    try {
      await Provider.of<FenologiaService>(context, listen: false)
          .obtenerFenologia(widget.idCultivo);

      if (miModelo5.lista11.isNotEmpty) {
        int idCultivo = miModelo5.lista11[0].idCultivo;
        setState(() {
          _futureUltimaAlerta = miModelo5.fetchUltimaAlerta(idCultivo);
          futurePronosticoCultivo = miModelo5.pronosticoCultivo(idCultivo);
          futurePcpnFase = miModelo5.fetchPcpnFase(widget.idCultivo);
        });
      } else {
        throw Exception('No se encontró el idCultivo');
      }
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  Future<void> _cargarFenologia2() async {
    try {
      await Provider.of<FenologiaService>(context, listen: false)
          .obtenerPronosticosFase(widget.idCultivo);
      await Provider.of<FenologiaService>(context, listen: false)
          .fase(widget.idCultivo);
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
      body: Stack(
        children: [
          const FondoWidget(),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Consumer<FenologiaService>(
              builder: (context, miModelo5, _) {
                if (miModelo5.lista11.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay datos disponibles',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              height: 90,
                              color: const Color.fromARGB(91, 4, 18, 43),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 15),
                                  Flexible(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10.0,
                                      runSpacing: 5.0,
                                      children: [
                                        Text("Bienvenido Invitado",
                                            style: GoogleFonts.lexend(
                                                textStyle: const TextStyle(
                                              color: Colors.white60,
                                            ))),
                                        Text(
                                            '| Municipio de: ${widget.nombreMunicipio}',
                                            style: GoogleFonts.lexend(
                                                textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10))),
                                        Text('| Zona: ${widget.nombreZona}',
                                            style: GoogleFonts.lexend(
                                                textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10))),
                                        Text(
                                            ' | Cultivo de ${miModelo5.lista11[0].nombreCultivo}',
                                            style: GoogleFonts.lexend(
                                                textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'COMUNIDADES DE LA ZONA ${widget.nombreZona.toUpperCase()} EN EL MUNICIPIO ${widget.nombreMunicipio.toUpperCase()}',
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 20,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchComunidades(widget.idZona),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueAccent),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay comunidades disponibles.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          } else {
                            List<Map<String, dynamic>> comunidades =
                                List<Map<String, dynamic>>.from(snapshot.data!);

                            List<String> nombresComunidades = comunidades
                                .map((comunidad) =>
                                    comunidad['nombreComunidad'] ??
                                    'Sin nombre')
                                .toList()
                                .cast<String>();
                            final ScrollController scrollController =
                                ScrollController();
                            List<Color> cardColors = [
                              const Color.fromARGB(120, 30, 136, 229),
                              const Color.fromARGB(120, 75, 169, 124),
                              const Color.fromARGB(120, 199, 119, 16),
                              const Color.fromARGB(120, 111, 12, 231),
                              const Color.fromARGB(120, 7, 170, 230),
                            ];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: scrollController,
                                      child: Row(
                                        children: List.generate(
                                            nombresComunidades.length, (index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Card(
                                              elevation: 4,
                                              color: cardColors[
                                                  index % cardColors.length],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          AssetImage(
                                                        'images/76.png',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      nombresComunidades[index]
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'PRONOSTICO AGROMETEOROLOGICO',
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 20,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (_futureUltimaAlerta != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: _futureUltimaAlerta,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final alertData = snapshot.data!;
                                  final alertMessages = {
                                    'Temperatura Máxima':
                                        alertData['TempMax']?.toString() ??
                                            'No alert',
                                    'Temperatura Mínima':
                                        alertData['TempMin']?.toString() ??
                                            'No alert',
                                    'Precipitación':
                                        alertData['Pcpn']?.toString() ??
                                            'No alert',
                                  };

                                  return SizedBox(
                                    height: 400.0,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            alertMessages.entries.map((entry) {
                                          final alertType = entry.key;
                                          final alertMessage = entry.value;

                                          IconData icon;
                                          Color alertColor;
                                          String imageUrl;

                                          if (alertMessage.contains("ROJA")) {
                                            alertColor = const Color.fromARGB(
                                                255, 255, 139, 131);
                                            icon = Icons.warning;
                                            imageUrl = 'images/rojo.png';
                                          } else if (alertMessage
                                              .contains("AMARILLA")) {
                                            alertColor = const Color.fromARGB(
                                                255, 231, 217, 90);
                                            icon = Icons.notifications_active;
                                            imageUrl = 'images/amarillo.png';
                                          } else if (alertMessage
                                              .contains("VERDE")) {
                                            alertColor = const Color.fromARGB(
                                                255, 161, 255, 164);
                                            icon = Icons.sentiment_satisfied;
                                            imageUrl = 'images/verde.png';
                                          } else {
                                            alertColor = Colors.white;
                                            icon = Icons.info;
                                            imageUrl = 'images/verde.png';
                                          }

                                          return Container(
                                            width: 250.0,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Card(
                                              color: const Color.fromARGB(
                                                  255, 255, 253, 251),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0),
                                              ),
                                              elevation: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 250.0,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            imageUrl),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      12.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          alertType,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8.0),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 35.0,
                                                              height: 35.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    alertColor,
                                                              ),
                                                              child: Icon(
                                                                icon,
                                                                color: Colors
                                                                    .white,
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8.0),
                                                            Expanded(
                                                              child: Text(
                                                                alertMessage,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                      'No hay alertas disponibles',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'PRONOSTICO EN LOS PROXIMOS 10 DIAS',
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 20,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<DatosPronostico>>(
                        future: miModelo5
                            .pronosticoCultivo(miModelo5.lista11[0].idCultivo),
                        builder: (context,
                            AsyncSnapshot<List<DatosPronostico>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text(
                                    'Este usuario no tiene datos registrados'));
                          } else {
                            final datosList = snapshot.data!;
                            final ScrollController scrollController =
                                ScrollController();
                            return Column(
                              children: [
                                listaTarjetasPronostico(
                                    datosList, scrollController, context),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'FENOLOGIA DE ${miModelo5.lista11[0].nombreCultivo
                                      .toUpperCase()}',
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 20,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Builder(
                          builder: (context) {
                            final ScrollController scrollController =
                                ScrollController();
                            return Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: scrollController,
                                child: Row(
                                  children: [
                                    ...miModelo5.lista11
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      var dato = entry.value;
                                      DateTime fechaAcumulado;
                                      if (index == 0) {
                                        fechaAcumulado = _selectedFechaSiembra
                                                ?.fechaSiembra ??
                                            dato.fechaSiembra;
                                      } else {
                                        int diasAcumulados = miModelo5.lista11
                                            .take(index + 1)
                                            .map((d) => d.nroDias)
                                            .reduce((a, b) => a + b);

                                        fechaAcumulado = (_selectedFechaSiembra
                                                    ?.fechaSiembra ??
                                                miModelo5
                                                    .lista11[0].fechaSiembra)
                                            .add(
                                                Duration(days: diasAcumulados));
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 5,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        width: 200,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Center(
                                              child: Image.asset(
                                                'images/${dato.imagen}',
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: Text(
                                                dato.descripcion,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Nro Dias: ${dato.nroDias}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Fase: ${dato.fase}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${formatearFecha(fechaAcumulado)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 5),
                          Container(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: TextButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC57A),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  exportarDato();
                                },
                                icon: const Icon(Icons.show_chart,
                                    color: Colors.white),
                                label: Text(
                                  'Descargar umbrales',
                                  style: getTextStyleNormal20(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'UMBRALES',
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? 14
                                          : 20,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: const Color.fromARGB(106, 0, 0, 0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: SizedBox(
                              width: 1200,
                              height: 500,
                              child: crearGrafica3(
                                  miModelo5.lista11, miModelo5.lista112),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: const Color.fromARGB(106, 0, 0, 0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: SizedBox(
                              width: 800,
                              height: 500,
                              child: crearGraficaPCPN(miModelo5.lista11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      tablaDatosUmb(miModelo5.lista11),
                      Footer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget crearGrafica3(
      List<Fenologia> datosList, List<DatosPronostico> datosPronostico) {
    List<FlSpot> tempMinSpots = [];
    List<FlSpot> tempOptMinSpots = [];
    List<FlSpot> umbInfSpots = [];
    List<FlSpot> umbSupSpots = [];
    List<FlSpot> tempOptMaxSpots = [];
    List<FlSpot> tempMaxSpots = [];

    List<FlSpot> tempMinSpots2 = [];
    List<FlSpot> tempMaxSpots2 = [];
    for (int i = 0; i < datosList.length; i++) {
      tempMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempMin));
      tempOptMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMin));
      umbInfSpots.add(FlSpot(i.toDouble(), datosList[i].umbInf));
      umbSupSpots.add(FlSpot(i.toDouble(), datosList[i].umbSup));
      tempOptMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMax));
      tempMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempMax));
    }

    for (int j = 0; j < datosPronostico.length; j++) {
      double xScaled =
          (j / (datosPronostico.length - 1)) * (miModelo5.faseActual - 1);
      tempMinSpots2.add(FlSpot(xScaled, datosPronostico[j].tempMin));
      tempMaxSpots2.add(FlSpot(xScaled, datosPronostico[j].tempMax));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 400,
            width: 1200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: tempMinSpots2,
                    isCurved: true,
                    barWidth: 2,
                    colors: [const Color.fromARGB(255, 201, 173, 255)],
                    belowBarData: BarAreaData(show: true),
                  ),
                  LineChartBarData(
                    spots: tempMaxSpots2,
                    isCurved: true,
                    barWidth: 2,
                    colors: [const Color.fromARGB(255, 143, 211, 147)],
                    belowBarData: BarAreaData(show: true),
                  ),
                  LineChartBarData(
                    spots: tempMinSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.blue],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempOptMinSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.green],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: umbInfSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.orange],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: umbSupSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.red],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempOptMaxSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.purple],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempMaxSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.yellow],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitles: (value) {
                      return (value.toInt() < datosList.length
                          ? 'Fase ${datosList[value.toInt()].fase}'
                          : '');
                    },
                    getTextStyles: (context, value) => const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitles: (value) {
                      return value.toString();
                    },
                    getTextStyles: (context, value) => const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                minX: 0,
                maxX: datosList.isNotEmpty
                    ? (datosList.length - 1).toDouble()
                    : datosList.length.toDouble() - 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Temp Min'),
                _buildLegendItem(Colors.green, 'Temp Opt Min'),
                _buildLegendItem(Colors.orange, 'Umb Inf'),
                _buildLegendItem(Colors.red, 'Umb Sup'),
                _buildLegendItem(Colors.purple, 'Temp Opt Max'),
                _buildLegendItem(Colors.yellow, 'Temp Max'),
                _buildLegendItem(Colors.brown, 'Temp Max Alt'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget crearGraficaPCPN(List<Fenologia> datosList) {
    List<FlSpot> pcpnSpots = [];

    for (int i = 0; i < datosList.length; i++) {
      pcpnSpots.add(FlSpot(i.toDouble(), datosList[i].pcpn));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 400,
            width: 800,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: pcpnSpots,
                    isCurved: false,
                    barWidth: 6,
                    colors: [Colors.cyan],
                    belowBarData: BarAreaData(
                        show: true, colors: [Colors.cyan.withOpacity(0.3)]),
                    dotData: FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitles: (value) {
                      return (value.toInt() < datosList.length
                          ? 'Fase ${datosList[value.toInt()].fase}'
                          : '');
                    },
                    getTextStyles: (context, value) => const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitles: (value) {
                      return value.toString();
                    },
                    getTextStyles: (context, value) => const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                minX: 0,
                maxX: datosList.isNotEmpty
                    ? (datosList.length - 1).toDouble()
                    : datosList.length.toDouble() - 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.cyan, 'PCPN'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView tablaDatosUmb(List<Fenologia> datosList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Fase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. letal min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. opt min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Umb. inf',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Umb. sup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. opt max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. letal max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Precipitacion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
          ],
          rows: datosList.map((datos) {
            return DataRow(cells: [
              DataCell(Text('${datos.fase}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempMin}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempOptMin}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.umbInf}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.umbSup}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempOptMax}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempMax}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.pcpn}',
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

String formatearFecha(DateTime fecha) {
  final DateFormat formatter = DateFormat('MMM d, y', 'es');
  return formatter.format(fecha).toUpperCase();
}

String formatFecha(DateTime date) {
  try {
    return DateFormat('d EEEE, MMM', 'es').format(date);
  } catch (e) {
    return DateFormat('d EEEE, MMM').format(date);
  }
}

Widget tarjetaPronostico(DatosPronostico datos, bool isMobile) {
  String fechaFormateada = formatFecha(datos.fechaRangoDecenal);
  String imagen = datos.pcpn > 0 ? 'images/25.png' : 'images/26.png';

  const tempMaxIcon = Icons.thermostat_outlined;
  const tempMinIcon = Icons.thermostat_rounded;
  const pcpnIcon = Icons.water_drop;

  TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: isMobile ? 12 : 13,
  );

  return SizedBox(
    width: isMobile ? 100 : 120,
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color.fromARGB(255, 156, 245, 219)),
      ),
      color: datos.pcpn > 0
          ? const Color.fromARGB(119, 128, 253, 255)
          : const Color.fromARGB(119, 255, 251, 128),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagen,
              height: isMobile ? 60 : 80,
              width: isMobile ? 60 : 80,
            ),
            const SizedBox(height: 10),
            Text(
              fechaFormateada.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
            const SizedBox(height: 10),
            _buildRowWithIcon(
                tempMaxIcon, 'Max: ${datos.tempMax}°C', textStyle),
            const SizedBox(height: 8),
            _buildRowWithIcon(
                tempMinIcon, 'Min: ${datos.tempMin}°C', textStyle),
            const SizedBox(height: 8),
            _buildRowWithIcon(pcpnIcon, 'PCPN: ${datos.pcpn} mm', textStyle),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRowWithIcon(IconData icon, String text, TextStyle textStyle) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.white, size: 20),
      const SizedBox(width: 8),
      Text(
        text,
        style: textStyle,
      ),
    ],
  );
}

Widget listaTarjetasPronostico(List<DatosPronostico> datosList,
    ScrollController scrollController, BuildContext context) {
  bool isMobile = MediaQuery.of(context).size.width < 600;

  return Scrollbar(
    controller: scrollController,
    thumbVisibility: true,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: Row(
        children: datosList.map((datos) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isMobile ? 150 : 200,
            ),
            child: tarjetaPronostico(datos, isMobile),
          );
        }).toList(),
      ),
    ),
  );
}
