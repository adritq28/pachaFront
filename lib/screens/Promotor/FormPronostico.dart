import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/Pronosticos/EditarPronosticoScreen.dart';
import 'package:helvetasfront/screens/Administrador/Pronosticos/VisualizarPronosticoScreen.dart';
import 'package:helvetasfront/screens/Promotor/BannerProm.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class FormPronostico extends StatefulWidget {
  final int idUsuario;
  final int idZona;
  final int idCultivo;
  final String nombreZona;
  final String nombreMunicipio;
  final String nombreCompleto;
  final String telefono;
  final String nombreCultivo;
  final String imagenP;

  const FormPronostico(
      {super.key,
      required this.idUsuario,
      required this.idZona,
      required this.idCultivo,
      required this.nombreZona,
      required this.nombreMunicipio,
      required this.nombreCompleto,
      required this.telefono,
      required this.nombreCultivo,
      required this.imagenP});

  @override
  FormPronosticoState createState() => FormPronosticoState();
}

class FormPronosticoState extends State<FormPronostico> {
  List<Map<String, dynamic>> datos = [];
  List<Map<String, dynamic>> datosFiltrados = [];
  bool isLoading = true;
  String? mesSeleccionado;
  List<String> meses = [
    'Todos',
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _pcpnController = TextEditingController();
  final TextEditingController _fechaRangoDecenalController =
      TextEditingController();

  late DateTime fecha = DateTime.now();
  String url = Url().apiUrl;
  String ip = Url().ip;

  DateTime? lastFechaRangoDecenal;
  final int _limiteDatosPorDia = 10;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    fetchZonas();
    _checkButtonState();
  }

  @override
  void dispose() {
    _tempMaxController.dispose();
    _tempMinController.dispose();
    _pcpnController.dispose();
    fecha;
    _fechaRangoDecenalController.dispose();
    super.dispose();
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

  Future<void> _checkButtonState() async {
    final datosHoy = await obtenerDatosIngresadosHoy(widget.idZona);
    final today = DateTime.now();

    setState(() {
      _isButtonEnabled = datosHoy < _limiteDatosPorDia;
      lastFechaRangoDecenal = today;
    });
  }

  Future<void> guardarDato() async {
    if (_formKey.currentState!.validate()) {
      final datosHoy = await obtenerDatosIngresadosHoy(widget.idZona);

      if (datosHoy >= _limiteDatosPorDia) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Has alcanzado el límite de datos para hoy')),
        );
        return;
      }

      final newDato = {
        'idZona': widget.idZona,
        'tempMax': _tempMaxController.text.isEmpty
            ? null
            : double.parse(_tempMaxController.text),
        'tempMin': _tempMinController.text.isEmpty
            ? null
            : double.parse(_tempMinController.text),
        'pcpn': _pcpnController.text.isEmpty
            ? null
            : double.parse(_pcpnController.text),
        'fecha': DateTime.now().toIso8601String(),
        'fechaRangoDecenal': _fechaRangoDecenalController.text.isEmpty
            ? null
            : _fechaRangoDecenalController.text,
        'idCultivo': widget.idCultivo,
      };

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirme los datos ingresados por favor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Color(0xFF34495e),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Temperatura máxima: ${newDato['tempMax']?.toString() ?? 'N/A'} °C',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Temperatura mínima: ${newDato['tempMin']?.toString() ?? 'N/A'} °C',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Precipitación: ${newDato['pcpn']?.toString() ?? 'N/A'} mm',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Fecha de pronostico: ${newDato['fechaRangoDecenal']?.toString() ?? 'N/A'}',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFe74c3c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1abc9c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                onPressed: () async {
                  final dio = Dio();
                  final response = await dio.post(
                    '$url/datos_pronostico/addDatosPronostico',
                    data: newDato,
                    options:
                        Options(headers: {'Content-Type': 'application/json'}),
                  );

                  if (response.statusCode == 201) {
                    await fetchZonas();
                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFFf0f0f0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            'Dato guardado correctamente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFF34495e),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Dato añadido correctamente. AVISO: Este formulario estará habilitado para EDITAR el dato hasta 10 días a partir de la fecha.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? 14
                                  : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1abc9c),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 20),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                          ],
                        );
                      },
                    );
                    _tempMaxController.clear();
                    _tempMinController.clear();
                    _pcpnController.clear();
                    _fechaRangoDecenalController.clear();
                  } else {
                    final errorMessage =
                        response.data['message'] ?? 'Unknown error';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al añadir dato: $errorMessage')),
                    );
                  }
                },
                child: const Text('Sí',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<int> obtenerDatosIngresadosHoy(int idZona) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        '$url/datos_pronostico/contarDatosHoy/$idZona',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['count'];
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  void editarDato(int index) async {
    Map<String, dynamic> dato = datos[index];

    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPronosticoScreen(
          idPonostico: dato['idPronostico'],
          tempMax: dato['tempMax'] ?? 0.0,
          tempMin: dato['tempMin'] ?? 0.0,
          pcpn: dato['pcpn'] ?? 0.0,
          fecha: dato['fecha'] ?? '',
        ),
      ),
    );

    if (cambiosGuardados == true) {
      fetchZonas();
    }
  }

  void visualizarDato(int index) {
    Map<String, dynamic> dato = datos[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarPronosticoScreen(
          idPronostico: dato['idPronostico'],
          tempMax: dato['tempMax'],
          tempMin: dato['tempMin'],
          pcpn: dato['pcpn'],
          fecha: dato['fecha'],
        ),
      ),
    );
    print('Visualizar dato en la posición $index');
  }

  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      print('Error al parsear la fecha: $dateTimeString');
      return 'Fecha inválida';
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime defaultDate = DateTime.now();
    final DateTime firstDate =
        lastFechaRangoDecenal != null ? lastFechaRangoDecenal! : defaultDate;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        setState(() {
          _fechaRangoDecenalController.text =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime);
        });
      }
    }
  }

  Future<void> fetchZonas() async {
    try {
      final dio = Dio();

      final response = await dio.get(
        '$url/datos_pronostico/lista_datos_zona/${widget.idCultivo}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.data;

        if (jsonResponse.isEmpty) {
          setState(() {
            datos = [];
            datosFiltrados = [];
            lastFechaRangoDecenal = null;
          });
          print('No se encontraron datos.');
          return;
        }

        setState(() {
          datos = List<Map<String, dynamic>>.from(jsonResponse);
          datosFiltrados = datos;
          List<DateTime> fechas = datos
              .map((dato) {
                try {
                  final fecha = DateTime.parse(dato['fechaRangoDecenal']);
                  return fecha;
                } catch (e) {
                  print('Error al analizar la fecha: $e');
                  return null;
                }
              })
              .whereType<DateTime>()
              .toList();

          if (fechas.isNotEmpty) {
            lastFechaRangoDecenal =
                fechas.reduce((a, b) => a.isAfter(b) ? a : b);
          } else {
            lastFechaRangoDecenal = null;
          }

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load datos meteorologicos');
      }
    } catch (e) {
      print('Error al obtener zonas: $e');
      setState(() {
        datos = [];
        datosFiltrados = [];
        lastFechaRangoDecenal = null;
        isLoading = false;
      });
    }
  }

  void filtrarDatosPorMes(String? mes) {
    if (mes == null || mes.isEmpty || mes == 'Todos') {
      setState(() {
        datosFiltrados = datos;
      });
      return;
    }

    int mesIndex = meses.indexOf(mes);

    setState(() {
      datosFiltrados = datos.where((dato) {
        try {
          DateTime fecha = DateTime.parse(dato['fecha']);
          return fecha.month == mesIndex;
        } catch (e) {
          print('Error al parsear la fecha: ${dato['fecha']}');
          return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.nombreZonaCultivo,
        nombreZona: widget.nombreZona,
        nombreCultivo: widget.nombreCultivo,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: true,
          idUsuario: widget.idUsuario,
          estado: PerfilEstado.nombreZonaCultivo,
          nombreZona: widget.nombreZona,
          nombreCultivo: widget.nombreCultivo,
        ),
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                BannerProm(
                  imagenP: widget.imagenP,
                  nombreCompleto: widget.nombreCompleto,
                  nombreZona: widget.nombreZona,
                  nombreCultivo: widget.nombreCultivo,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      const SizedBox(height: 20),
                      Text(
                        'REGISTRO DE PRONÓSTICOS DECENALES PARA LAS COMUNIDADES DE LA ZONA ${widget.nombreZona.toUpperCase()} EN EL MUNICIPIO ${widget.nombreMunicipio.toUpperCase()}',
                        style: GoogleFonts.lexend(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? 14
                                : 20,
                          ),
                        ),
                        textAlign: TextAlign.center,
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
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                            padding: const EdgeInsets.only(
                                                right: 10),
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
                                                    const EdgeInsets.all(15),
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
                      const SizedBox(height: 10),
                      formDatosPronostico(),
                      const SizedBox(height: 10),
                      Container(
                        child: DropdownButton<String>(
                          dropdownColor: const Color.fromARGB(255, 3, 50, 112),
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
                          items:
                              meses.map<DropdownMenuItem<String>>((String mes) {
                            return DropdownMenuItem<String>(
                              value: mes,
                              child: Text(
                                mes,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 228, 243, 255),
                                ),
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          iconEnabledColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Nro',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                                'Fecha Pronostico Decenal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Temp Max',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Temp Min',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Precipitación',
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
                          rows: List<DataRow>.generate(datosFiltrados.length,
                              (index) {
                            final dato = datosFiltrados[index];
                            final fechaRegistro =
                                DateTime.parse(dato['fecha'].toString());
                            final ahora = DateTime.now();
                            final fechaLimite =
                                fechaRegistro.add(const Duration(days: 9));
                            final editable = ahora.isBefore(fechaLimite);

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    formatDateTime(dato['fecha']?.toString()),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    formatDateTime(
                                        dato['fechaRangoDecenal']?.toString()),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dato['tempMax'].toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dato['tempMin'].toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dato['pcpn'].toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      if (editable)
                                        GestureDetector(
                                          onTap: () => editarDato(index),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                      if (editable) const SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () => visualizarDato(index),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formDatosPronostico() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                isSmallScreen
                    ? Column(
                        children: [
                          TextFormField(
                            controller: _tempMaxController,
                            decoration: getInputDecoration(
                                'Temp Max', Icons.thermostat),
                            style: getTextStyForm(),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura máxima';
                              }
                              final double? tempMax = double.tryParse(value);
                              if (tempMax == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempMax < -5 || tempMax > 35) {
                                return 'La temperatura debe estar entre -18 y 15';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _tempMinController,
                            decoration: getInputDecoration(
                                'Temp Min', Icons.thermostat),
                            style: getTextStyForm(),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura mínima';
                              }
                              final double? tempMin = double.tryParse(value);
                              if (tempMin == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempMin < -18 || tempMin > 15) {
                                return 'La temperatura debe estar entre -18 y 15';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tempMaxController,
                              decoration: getInputDecoration(
                                  'Temp Max', Icons.thermostat),
                              style: getTextStyForm(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura máxima';
                                }
                                final double? tempMax = double.tryParse(value);
                                if (tempMax == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMax < -5 || tempMax > 35) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _tempMinController,
                              decoration: getInputDecoration(
                                  'Temp Min', Icons.thermostat),
                              style: getTextStyForm(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura mínima';
                                }
                                final double? tempMin = double.tryParse(value);
                                if (tempMin == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMin < -18 || tempMin > 15) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                isSmallScreen
                    ? Column(
                        children: [
                          TextFormField(
                            controller: _pcpnController,
                            decoration: getInputDecoration(
                                'Precipitación', Icons.water),
                            style: getTextStyForm(),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              final double? precipitation =
                                  double.tryParse(value);
                              if (precipitation == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (precipitation < 0 || precipitation > 70) {
                                return 'La precipitación debe estar entre 0 y 50';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: _selectDateTime,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fechaRangoDecenalController,
                                decoration: getInputDecoration(
                                  'Fecha y Hora',
                                  Icons.calendar_today,
                                ),
                                style: const TextStyle(
                                  fontSize: 35.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pcpnController,
                              decoration: getInputDecoration(
                                  'Precipitación', Icons.water),
                              style: getTextStyForm(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                final double? precipitation =
                                    double.tryParse(value);
                                if (precipitation == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (precipitation < 0 || precipitation > 70) {
                                  return 'La precipitación debe estar entre 0 y 50';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDateTime,
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _fechaRangoDecenalController,
                                  decoration: getInputDecoration(
                                    'Fecha y Hora',
                                    Icons.calendar_today,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 35.0,
                                    color: Color.fromARGB(255, 201, 219, 255),
                                  ),
                                  keyboardType: TextInputType.datetime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 240,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled
                            ? const Color(0xFF17A589)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isButtonEnabled ? guardarDato : null,
                      icon: const Icon(Icons.save_as_outlined,
                          color: Colors.white),
                      label: Text(
                        'Guardar',
                        style: getTextStyleNormal20(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
