import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Promotor/BannerProm.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class FormFechaSiembra extends StatefulWidget {
  final int idUsuario;
  final int idZona;
  final String nombreZona;
  final String nombreMunicipio;
  final String nombreCompleto;
  final String telefono;
  final int idCultivo;
  final String nombreCultivo;
  final String tipo;
  final String imagen;
  final String imagenP;

  const FormFechaSiembra(
      {super.key,
      required this.idUsuario,
      required this.idZona,
      required this.nombreZona,
      required this.nombreMunicipio,
      required this.nombreCompleto,
      required this.telefono,
      required this.idCultivo,
      required this.nombreCultivo,
      required this.tipo,
      required this.imagen,
      required this.imagenP});

  @override
  FormFechaSiembraState createState() => FormFechaSiembraState();
}

class FormFechaSiembraState extends State<FormFechaSiembra> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  DateTime? _fechaSeleccionada;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
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

  Future<void> guardarFechaSiembra() async {
    if (_fechaSeleccionada != null) {
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
      final dio = Dio();

      final url2 =
          '$url/cultivos/${widget.idCultivo}/fecha-siembra?fechaSiembra=$formattedDate';

      try {
        final response = await dio.put(
          url2,
          data: {
            'fechaSiembra': formattedDate,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFf0f0f0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Dato guardado correctamente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Color(0xFF34495e),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: const Text('Dato añadido correctamente.'),
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
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ],
              );
            },
          );
          setState(() {
            _fechaSeleccionada = null;
          });
        } else {
          print('Error ${response.statusCode}: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar la fecha'),
            ),
          );
        }
      } catch (e) {
        print('Error al realizar la solicitud PUT: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha primero'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF164092),
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              BannerProm(
                imagenP: widget.imagenP,
                nombreCompleto: widget.nombreCompleto,
                nombreZona: widget.nombreZona,
                nombreCultivo: widget.nombreCultivo,
              ),
              const SizedBox(height: 20),
              Text(
                'REGISTRO DE FECHAS DE SIEMBRA PARA LAS COMUNIDADES DE LA ZONA ${widget.nombreZona.toUpperCase()} EN EL MUNICIPIO ${widget.nombreMunicipio.toUpperCase()}',
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 20,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchComunidades(widget.idZona),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                            comunidad['nombreComunidad'] ?? 'Sin nombre')
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Card(
                                      elevation: 4,
                                      color:
                                          cardColors[index % cardColors.length],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const CircleAvatar(
                                              radius: 25,
                                              backgroundImage: AssetImage(
                                                'images/76.png',
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              nombresComunidades[index]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
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
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime(DateTime.now().year - 1),
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 400 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    titleCentered: true,
                  ),
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _fechaSeleccionada = DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day);
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_fechaSeleccionada != null)
                Text(
                  'Fecha seleccionada: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 240,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await guardarFechaSiembra();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1abc9c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                    ),
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
    );
  }
}
