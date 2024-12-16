import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/AnadirDatoHidrologicoScreen.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/EditarHidrologicaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/VisualizarHidrologicaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class DatosHidrologicaScreen extends StatefulWidget {
  final int idEstacion;
  final String nombreMunicipio;
  final String nombreEstacion;

  const DatosHidrologicaScreen({
    super.key,
    required this.idEstacion,
    required this.nombreMunicipio,
    required this.nombreEstacion,
  });

  @override
  DatosHidrologicaScreenState createState() => DatosHidrologicaScreenState();
}

class DatosHidrologicaScreenState extends State<DatosHidrologicaScreen> {
  List<Map<String, dynamic>> datos = [];
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

  late EstacionService miModelo4;
  late EstacionHidrologicaService hidrologicaService=EstacionHidrologicaService();
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    fetchDatos();
  }

  Future<void> fetchDatos() async {
  try {
    final fetchedDatos =
        await hidrologicaService.fetchDatosHidrologico(widget.idEstacion);

    setState(() {
      datos = fetchedDatos;
      datosFiltrados = fetchedDatos;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
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

  void editarDato(int index) async {
    Map<String, dynamic> dato = datos[index];
    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHidrologicaScreen(
          idHidrologica: dato['idHidrologica'],
          limnimetro: dato['limnimetro'] ?? 0.0,
          fechaReg: dato['fechaReg'] ?? '',
        ),
      ),
    );
    if (cambiosGuardados == true) {
      await fetchDatos();
      setState(() {});
      
    }
  }

  void visualizarDato(int index) {
    Map<String, dynamic> dato = datos[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarHidrologicaScreen(
          idHidrologica: dato['idHidrologica'],
          limnimetro: dato['limnimetro'],
          fechaReg: dato['fechaReg'],
        ),
      ),
    );
    print('Visualizar dato en la posición $index');
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

void eliminarDato(int index) async {
  Map<String, dynamic> dato = datos[index];
  int idHidrologica = dato['idHidrologica'];

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
                  '$url/estacion/eliminarH/$idHidrologica',
                  options: Options(headers: {'Content-Type': 'application/json'}),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    datos.removeAt(index);
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
          builder: (context) =>
              AnadirDatoHidrologicoScreen(idEstacion: widget.idEstacion)),
    );
    if (result == true) {
      fetchDatos();
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("images/47.jpg"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Municipio de: ${widget.nombreMunicipio}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(208, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Estación Hidrologica: ${widget.nombreEstacion}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(208, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
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
                              color: Color.fromARGB(255, 185, 223, 255),
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      iconEnabledColor: Colors.white,
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
                          backgroundColor:
                              const Color.fromARGB(255, 142, 146, 143),
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
                                          formatDateTime(
                                              dato['fechaReg'].toString()),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['limnimetro'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => editarDato(index),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color:
                                                      const Color(0xFFF0B27A),
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () =>
                                                  visualizarDato(index),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color:
                                                      const Color(0xFF58D68D),
                                                ),
                                                child: const Icon(
                                                  Icons.remove_red_eye_sharp,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () => eliminarDato(index),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color:
                                                      const Color(0xFFEC7063),
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 24,
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
