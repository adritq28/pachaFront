import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/EditarHidrologicaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/VisualizarHidrologicaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaEstacionHidrologicaScreen extends StatefulWidget {
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreEstacion;
  final String tipoEstacion;
  final String nombreCompleto;
  final String telefono;
  final int idEstacion;
  final bool codTipoEstacion;
  final String imagen;

  const ListaEstacionHidrologicaScreen(
      {super.key,
      required this.idUsuario,
      required this.nombreMunicipio,
      required this.nombreEstacion,
      required this.tipoEstacion,
      required this.nombreCompleto,
      required this.telefono,
      required this.idEstacion,
      required this.codTipoEstacion,
      required this.imagen});

  @override
  ListaEstacionHidrologicaScreenState createState() =>
      ListaEstacionHidrologicaScreenState();
}

class ListaEstacionHidrologicaScreenState
    extends State<ListaEstacionHidrologicaScreen> {
  List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
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

  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limnimetro = TextEditingController();
  late DateTime fechaReg = DateTime.now();
  String url = Url().apiUrl;
  String ip = Url().ip;
  bool isButtonDisabled = false;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchDatosHidrologico();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkButtonStatus(widget.idUsuario);
    });
  }

  @override
  void dispose() {
    _limnimetro.dispose();
    fechaReg;
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkButtonStatus(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClickDate = prefs.getString('lastClickDate_$userId');
      final todayDate = DateTime.now().toIso8601String().split('T').first;

      setState(() {
        isButtonDisabled = lastClickDate == todayDate;
      });
    } catch (e) {
      print('Error checking button status: $e');
    }
  }

  Future<void> guardarDato() async {
    if (_formKey.currentState!.validate()) {
      final newDato = {
        'idEstacion': widget.idEstacion,
        'limnimetro':
            _limnimetro.text.isEmpty ? null : double.parse(_limnimetro.text),
        'fechaReg': DateTime.now().toIso8601String(),
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
                    '- Limnimetro: ${newDato['limnimetro']?.toString() ?? 'N/A'} cm',
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
                    '$url/datosHidrologica/addDatosHidrologica',
                    data: newDato,
                    options: Options(
                      headers: {'Content-Type': 'application/json'},
                    ),
                  );

                  if (response.statusCode == 200) {
                    print('Datos Hidrológicos añadidos correctamente');
                  } else if (response.statusCode == 201) {
                    await fetchDatosHidrologico();
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
                            'Dato añadido correctamente. AVISO: Este formulario estará habilitado para EDITAR el dato hasta las 00:00 horas del día de hoy.',
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
                    _limnimetro.clear();
                  } else {
                    final errorMessage = response.data ??
                        'Error desconocido';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastClickDate', DateTime.now().toIso8601String().split('T').first);
    setState(() {
      isButtonDisabled = true;
    });
  }

  void visualizarDato(int index) {
    try {
      Map<String, dynamic> dato = datos[index];

      if (dato['idHidrologica'] != null &&
          dato['limnimetro'] != null &&
          dato['fechaReg'] != null) {
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
      } else {
        print('Datos incompletos en la posición $index');
      }
    } catch (e) {
      print('Error al intentar visualizar el dato en la posición $index: $e');
    }
  }

  void editarDato(int index) async {
    Map<String, dynamic> dato = datos[index];

    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHidrologicaScreen(
          idHidrologica: dato['idHidrologica'],
          limnimetro: dato['limnimetro'],
          fechaReg: dato['fechaReg'],
        ),
      ),
    );

    if (cambiosGuardados == true) {
      fetchDatosHidrologico();
    }
  }

  bool _esUltimoRegistroDelDia(
      Map<String, dynamic> dato, List<Map<String, dynamic>> datosFiltrados) {
    final fechaActual = DateTime.now();
    final fechaDato = DateTime.parse(dato['fechaReg']);
    final esMismoDia = fechaDato.year == fechaActual.year &&
        fechaDato.month == fechaActual.month &&
        fechaDato.day == fechaActual.day;
    return esMismoDia &&
        dato ==
            datosFiltrados.lastWhere(
                (d) => DateTime.parse(d['fechaReg']).day == fechaActual.day);
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
    if (mes == null || mes.isEmpty || mes == 'Todos') {
      setState(() {
        datosFiltrados = datos;
      });
      return;
    }

    int mesIndex = meses.indexOf(mes) - 1;

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

  Future<void> fetchDatosHidrologico() async {
  try {
    final dio = Dio();
    final response = await dio.get(
      '$url/estacion/lista_datos_hidrologica/${widget.idEstacion}',
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = response.data;
      final List<Map<String, dynamic>> datos =
          List<Map<String, dynamic>>.from(jsonResponse);

      setState(() {
        this.datos = datos;
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


  @override
  Widget build(BuildContext context) {
    final String fechaActual = dateFormat.format(DateTime.now());
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,
        nombreEstacion: widget.nombreEstacion,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
            isHomeScreen: false,
            showProfileButton: true,
            idUsuario: widget.idUsuario,
            estado: PerfilEstado.nombreEstacionMunicipio,
            nombreMunicipio: widget.nombreMunicipio,
            nombreEstacion: widget.nombreEstacion),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                            Text('| ${widget.nombreCompleto}',
                                style: GoogleFonts.lexend(
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Text('| Municipio de: ${widget.nombreMunicipio}',
                                style: GoogleFonts.lexend(
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Text('| Estacion de: ${widget.nombreEstacion}',
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
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(width: 5),
                          ],
                        ),
                        formDatosEstacion(),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 600;
                            final textStyle = getTextStyle(constraints);

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: isMobile ? 20 : 30,
                                dataRowHeight: isMobile ? 40 : 56,
                                headingRowHeight: isMobile ? 40 : 56,
                                columns: [
                                  DataColumn(
                                      label: Text('Nro', style: textStyle)),
                                  DataColumn(
                                      label: Text('Fecha', style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Limnimetro', style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Acciones', style: textStyle)),
                                ],
                                rows: List<DataRow>.generate(
                                    datosFiltrados.length, (index) {
                                  final dato = datosFiltrados[index];

                                  return DataRow(
                                    cells: [
                                      DataCell(Text((index + 1).toString(),
                                          style: textStyle)),
                                      DataCell(Text(
                                          formatDateTime(
                                              dato['fechaReg']?.toString()),
                                          style: textStyle)),
                                      DataCell(Text(
                                          dato['limnimetro'].toString(),
                                          style: textStyle)),
                                      DataCell(
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: dateFormat.format(DateTime
                                                            .parse(datos[index][
                                                                'fechaReg'])) ==
                                                        fechaActual
                                                    ? () => editarDato(index)
                                                    : null,
                                                child: MouseRegion(
                                                  cursor: dateFormat.format(
                                                              DateTime.parse(datos[
                                                                      index][
                                                                  'fechaReg'])) ==
                                                          fechaActual
                                                      ? SystemMouseCursors.click
                                                      : SystemMouseCursors
                                                          .basic,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        isMobile ? 5 : 7),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: dateFormat.format(
                                                                  DateTime.parse(
                                                                      datos[index]
                                                                          [
                                                                          'fechaReg'])) ==
                                                              fechaActual
                                                          ? const Color(
                                                              0xFFF0B27A)
                                                          : const Color
                                                              .fromARGB(107,
                                                              158, 158, 158),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          const Color.fromARGB(
                                                              192,
                                                              255,
                                                              255,
                                                              255),
                                                      size: isMobile ? 20 : 24,
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
                                                    padding: EdgeInsets.all(
                                                        isMobile ? 5 : 7),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: const Color(
                                                          0xFF58D68D),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .remove_red_eye_sharp,
                                                      color: Colors.white,
                                                      size: isMobile ? 20 : 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formDatosEstacion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 100,
                  child: TextFormField(
                    controller: _limnimetro,
                    decoration:
                        getInputDecoration('Limnimetro', Icons.thermostat),
                    style: const TextStyle(
                      fontSize: 50.0,
                      color: Color.fromARGB(255, 201, 219, 255),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la temperatura ambiente';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A589),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: guardarDato,
                  icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                  label: Text(
                    'Guardar',
                    style: getTextStyleNormal20(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 3, 50, 112),
                    value: mesSeleccionado,
                    hint: Text(
                      'Registros anteriores - Seleccione un mes',
                      style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15.0,
                        ),
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
                          style: GoogleFonts.lexend(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15.0,
                            ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(String?)? onSaved;

  const MyTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 225, 255, 246),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 180, 255, 231)),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.blue),
        prefixIcon:
            Icon(prefixIcon, color: const Color.fromARGB(255, 97, 173, 255)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      onSaved: onSaved,
    );
  }
}
