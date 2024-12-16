import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/Utils/mobile_utils.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/download_helper.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ListaInvitadoHidrologicaScreen extends StatefulWidget {
  final int idEstacion;
  final String nombreMunicipio;
  final String nombreEstacion;

  const ListaInvitadoHidrologicaScreen({super.key,
    required this.idEstacion,
    required this.nombreMunicipio,
    required this.nombreEstacion,
  });

  @override
  ListaInvitadoHidrologicaScreenState createState() =>
      ListaInvitadoHidrologicaScreenState();
}

class ListaInvitadoHidrologicaScreenState extends State<ListaInvitadoHidrologicaScreen> {
  late List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
  String? mesSeleccionado;
  List<String> meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    fetchDatosHidrologico();
  }

Future<String> obtNombreObservador(int idEstacion) async {
  final String apiUrl2 =
      '$url/estacion/nombre_observador/${widget.idEstacion}';
  
  try {
    final dio = Dio();
    final response = await dio.get(apiUrl2);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(
          'Error al obtener el nombre del observador: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error al conectar con el servidor');
  }
}

Future<void> fetchDatosHidrologico() async {
  try {
    final dio = Dio();
    final response = await dio.get(
      '$url/estacion/lista_datos_hidrologica/${widget.idEstacion}',
    );

    if (response.statusCode == 200) {
      setState(() {
        datos = List<Map<String, dynamic>>.from(response.data);
        datosFiltrados = datos;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load datos hidrologicos');
    }
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> exportToExcel(List<Map<String, dynamic>> datosList,
    String nombreMunicipio,
    String nombreEstacion,
    String departamento,
    String nombreObservador,) async {
  try {
    var excel = excel_pkg.Excel.createExcel();
    var sheet = excel['Sheet1'];
      sheet.cell(CellIndex.indexByString("A1")).value =
          nombreMunicipio;
      sheet.cell(CellIndex.indexByString("A2")).value =
          "Estación:";
      sheet.cell(CellIndex.indexByString("B2")).value =
          nombreEstacion;
      sheet.cell(CellIndex.indexByString("A3")).value =
          "Departamento:";
      sheet.cell(CellIndex.indexByString("B3")).value =
          departamento;
      sheet.cell(CellIndex.indexByString("A4")).value =
          "Observador:";
      sheet.cell(CellIndex.indexByString("B4")).value =
          nombreObservador;
    sheet.appendRow([
      'Fecha',
      'Limnimetro',
    ]);
    for (var dato in datosList) {
      sheet.appendRow([
        formatDateTime(dato['fechaReg']?.toString()),
        dato['limnimetro'] ?? '',
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes == null) {
      throw Exception('No se pudo generar el archivo Excel.');
    }

    if (kIsWeb) {
      await downloadExcelMobile(fileBytes, "DatosHidrologicos.xlsx");
    } else {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/DatosHidrologicos.xlsx';
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
      String nombreObservador = await obtNombreObservador(widget.idEstacion);
      exportToExcel(datosFiltrados, widget.nombreMunicipio,
          widget.nombreEstacion, "La Paz", nombreObservador);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  Future<void> exportToCSV(
  List<Map<String, dynamic>> datosList,
  String nombreMunicipio,
  String nombreEstacion,
  String departamento,
  String nombreObservador,
) async {
  try {
    List<List<dynamic>> rows = [
      [
        "ID",
        "Fecha Registro"
        "Limnimetro",
        
      ]
    ];

    for (var dato in datosList) {
      List<dynamic> row = [
        dato['idHidrologica']?.toString() ?? ' ',
        formatDateTime(dato['fechaReg']?.toString()),
        dato['limnimetro'] ?? '',
      ];
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    List<int> fileBytes = utf8.encode(csv);

    if (fileBytes.isEmpty) {
      throw Exception('No se pudo generar el archivo CSV.');
    }

    if (kIsWeb) {
      await downloadForWeb(fileBytes, "DatosHidrologicos.csv");
    } else {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/DatosMeteorologicos.csv';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      OpenFile.open(filePath);
    }
    print('Archivo listo para descargar');
  } catch (e) {
    print('Error al guardar el archivo: ${e.toString()}');
  }
}



  void exportarDatoCSV() async {
    try {
      String nombreObservador = await obtNombreObservador(widget.idEstacion);
      exportToCSV(datosFiltrados, widget.nombreMunicipio, widget.nombreEstacion,
          "La Paz", nombreObservador);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      print('Error al parsear la fecha: $dateTimeString');
      return 'Fecha inválida';
    }
  }

  void filtrarDatosPorMes(String? mes) {
    if (mes == null || mes.isEmpty) {
      setState(() {
        datosFiltrados = datos;
      });
      return;
    }

    int mesIndex = meses.indexOf(mes) + 1;

    setState(() {
      datosFiltrados = datos.where((dato) {
        try {
          DateTime fecha = DateTime.parse(dato['fechaReg']);
          return fecha.month == mesIndex;
        } catch (e) {
          print('Error al parsear la fecha: ${dato['fechaReg']}');
          return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,
        nombreEstacion: widget.nombreEstacion),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    color: const Color.fromARGB(
                        51, 25, 25, 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("images/47.jpg"),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10.0,
                            runSpacing: 5.0,
                            children: [
                              const Text(
                                "Bienvenido Invitado",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                        '| Municipio de: ${widget.nombreMunicipio}',
                                        style: GoogleFonts.lexend(
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                              Text(
                                '| Estación Hidrológica: ${widget.nombreEstacion}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(208, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.5,
                    child: DropdownButton<String>(
                      value: mesSeleccionado,
                      hint: const Text(
                        'Seleccione un mes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          mesSeleccionado = newValue;
                          filtrarDatosPorMes(newValue);
                        });
                      },
                      items: meses.map<DropdownMenuItem<String>>((String mes) {
                        return DropdownMenuItem<String>(
                          value: mes,
                          child: Text(
                            mes,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 185, 223,
                                  255),
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Colors.grey[
                          800],
                      style: const TextStyle(
                        color: Colors
                            .white,
                      ),
                      iconEnabledColor:
                          Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: exportarDato,
            icon: const Icon(Icons.downloading, color: Colors.white),
            label: const Text(
              'Exportar Excel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF58D68D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          const SizedBox(height: 5),
          TextButton.icon(
            onPressed: exportarDatoCSV,
            icon: const Icon(Icons.downloading, color: Colors.white),
            label: const Text(
              'Exportar CSV',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: exportarDato,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Exportar Excel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF58D68D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          const SizedBox(width: 5),
          TextButton.icon(
            onPressed: exportarDatoCSV,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Exportar CSV',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3498db),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          
        ],
      );
    }
  },
),

                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Fecha',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Limnimetro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: datosFiltrados.map((dato) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          formatDateTime(
                                              dato['fechaReg'].toString()),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['limnimetro'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


