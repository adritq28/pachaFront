import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/dateTime/DateTimePicker.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/AnadirCultivoScreen.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/EditarCultivoScreen.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/VisualizarCultivoScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/services/ZonaService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';


class DatosFechaSiembraScreen extends StatefulWidget {
  final int idZona;
  final String nombreMunicipio;
  final String nombreZona;

  const DatosFechaSiembraScreen({super.key,
    required this.idZona,
    required this.nombreMunicipio,
    required this.nombreZona,
  });

  @override
  DatosFechaSiembraScreenState createState() =>
      DatosFechaSiembraScreenState();
}

class DatosFechaSiembraScreenState extends State<DatosFechaSiembraScreen> {
  final ZonaService zonaService = ZonaService();
  final DateTimePicker dateService = DateTimePicker();
  List<Map<String, dynamic>> datos = [];
  List<Map<String, dynamic>> datosFiltrados = [];
  bool isLoading = true;
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

  late PronosticoService miModelo4;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final data = await zonaService.fetchZonas(widget.idZona);
      setState(() {
        datos = data;
        datosFiltrados = datos;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void editarDato(int index) async {
    print("entro a editar ");
    Map<String, dynamic> dato = datos[index];

    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarCultivoScreen(
          idCultivo: dato['idCultivo'],
          nombre: dato['nombre'],
          fechaSiembra: dato['fechaSiembra'] ?? '',
          fechaReg: dato['fechaReg'] ?? '',
          tipo: dato['tipo'],
        ),
      ),
    );

    if (cambiosGuardados == true) {
      await cargarDatos();
      setState(() {});
    }
  }

  void visualizarDato(int index) {
    Map<String, dynamic> dato = datos[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarCultivoScreen(
          idCultivo: dato['idCultivo'],
          nombre: dato['nombre'],
          fechaSiembra: dato['fechaSiembra'] ?? '',
          fechaReg: dato['fechaReg'] ?? '',
          tipo: dato['tipo'],
        ),
      ),
    );
    print('Visualizar dato en la posición $index');
  }


void eliminarDato(int index) async {
  Map<String, dynamic> dato = datosFiltrados[index];
  int idCultivo = dato['idCultivo'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro que deseas eliminar estos datos?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                final dio = Dio();
                final response = await dio.delete(
                  '$url/cultivos/eliminar/$idCultivo',
                  options: Options(headers: {'Content-Type': 'application/json'}),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    datos.removeAt(index);
                    datosFiltrados = datosFiltrados
                        .where((dato) => dato['idCultivo'] != idCultivo)
                        .toList();
                  });
                  print('Dato eliminado correctamente');
                } else {
                  print('Error al intentar eliminar el dato');
                }
              } catch (e) {
                print('Error al eliminar el dato: $e');
              }
            },
          ),
        ],
      );
    },
  );
}

  void anadirDato() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AnadirCultivoScreen(idZona: widget.idZona)),
    );

    if (result == true) {
      cargarDatos();
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 70,
                    color: const Color.fromARGB(91, 4, 18, 43),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
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
                              Text('| Admin | Municipio de: ${widget.nombreMunicipio} | Zona: ${widget.nombreZona}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: anadirDato,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Añadir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 142, 146, 143),
                        ),
                      ),
                    ],
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
                                      'Fecha Siembra',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nombre Cultivo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Tipo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nombre Fecha Siembra',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Fecha Reg',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Acciones',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: datosFiltrados.map((dato) {
                                  int index = datosFiltrados.indexOf(dato);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          DateTimePicker.formatDateTime(
                                              dato['fechaSiembra']?.toString()),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['nombre'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['tipo'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['nombreFechaSiembra'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          DateTimePicker.formatDateTime(
                                              dato['fechaReg']?.toString()),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => editarDato(index),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  padding: const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: const Color(0xFFF0B27A),
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () =>
                                                  visualizarDato(index),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  padding: const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: const Color(0xFF58D68D),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove_red_eye_sharp,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () => eliminarDato(index),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  padding: const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: const Color(0xFFEC7063),
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
