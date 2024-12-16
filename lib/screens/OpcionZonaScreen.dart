import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/screens/Promotor/FormFechaSiembra.dart';
import 'package:helvetasfront/screens/Promotor/FormPronostico.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

class OpcionZonaScreen extends StatefulWidget {
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

  const OpcionZonaScreen(
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
  OpcionZonaScreenState createState() => OpcionZonaScreenState();
}

class OpcionZonaScreenState extends State<OpcionZonaScreen> {
  late PromotorService promotorService;
  late Future<List<Promotor>> _promotorFuture;
  String url = Url().apiUrl;
  String ip = Url().ip;
  List<Map<String, dynamic>> comunidades = [];

  @override
  void initState() {
    super.initState();
    promotorService = Provider.of<PromotorService>(context, listen: false);
    _promotorFuture = _cargarPromotor();
    _cargarComunidades();
  }

  Future<List<Map<String, dynamic>>> fetchComunidades(int idZona) async {
    final dio = Dio();
    final url2 = '$url/zona/lista_comunidad/$idZona';

    try {
      final response = await dio.get(
        url2,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

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

  Future<void> _cargarComunidades() async {
    try {
      List<Map<String, dynamic>> comunidades =
          await fetchComunidades(widget.idZona);
      setState(() {
        comunidades = comunidades;
      });
    } catch (e) {
      print('Error al cargar comunidades: $e');
    }
  }

  Future<List<Promotor>> _cargarPromotor() async {
    try {
      final datosService2 =
          Provider.of<PromotorService>(context, listen: false);
      await datosService2.obtenerListaZonas(widget.idUsuario);
      final lista = datosService2.lista11;
      for (var promotor in lista) {
        print(
            'ID Usuario: ${promotor.idUsuario}, Nombre: ${promotor.nombreCompleto}');
      }

      return lista;
    } catch (e) {
      print('Error al cargar los datos: $e');
      return [];
    }
  }

  Widget _buildZonaCard(
    BuildContext context,
    String nombreZona,
    String imagen,
    String nombreCultivo,
    String tipo,
    String nombreFechaSiembra,
    PromotorService promotorService,
  ) {
    return GestureDetector(
      onTap: () {
        _showFechasSiembraDialog(context, nombreZona, promotorService);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            ),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: AssetImage("images/$imagen"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nombreCultivo,
                      style: GoogleFonts.lexend(
                        textStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Text(
                      "Zona: ${nombreZona.toUpperCase()}",
                      style: getTextStyleNormal20n(),
                    ),
                    Text(
                      "Tipo Cultivo: $tipo",
                      style: getTextStyleNormal20n(),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Selecciona una fecha de siembra para ver el pronóstico',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assignment_add,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFechasSiembraDialog(BuildContext context, String nombreZona,
      PromotorService promotorService) {
    final fechasSiembra = promotorService.lista11
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
                                  Navigator.pop(context);
                                  _mostrarModal(dato);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedDates
                                            .contains(dato.nombreFechaSiembra)
                                        ? hoverColor
                                        : normalColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 144, 101, 51),
                                          borderRadius:
                                              BorderRadius.circular(10)),
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

  void _mostrarModal(Promotor promotor) {
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
                    color: const Color.fromARGB(226, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Opciones',
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 9, 64, 142),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => PromotorService(),
                                child: FormFechaSiembra(
                                  idUsuario: promotor.idUsuario,
                                  idZona: promotor.idZona,
                                  nombreZona: promotor.nombreZona ?? '',
                                  nombreMunicipio:
                                      promotor.nombreMunicipio ?? '',
                                  nombreCompleto: promotor.nombreCompleto ?? '',
                                  telefono: promotor.telefono ?? '',
                                  idCultivo: promotor.idCultivo ?? 0,
                                  nombreCultivo: promotor.nombreCultivo ?? '',
                                  tipo: promotor.tipo ?? '',
                                  imagen: promotor.imagen ?? '',
                                  imagenP: widget.imagenP ?? '',
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Registro Fecha Siembra',
                                style: GoogleFonts.lexend(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => PronosticoService(),
                                child: FormPronostico(
                                  idUsuario: promotor.idUsuario,
                                  idZona: promotor.idZona,
                                  idCultivo: promotor.idCultivo,
                                  nombreZona: promotor.nombreZona ?? '',
                                  nombreMunicipio:
                                      promotor.nombreMunicipio ?? '',
                                  nombreCompleto: promotor.nombreCompleto ?? '',
                                  telefono: promotor.telefono ?? '',
                                  nombreCultivo: promotor.nombreCultivo ?? '',
                                  imagenP: widget.imagenP ?? '',
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.white),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Registro Pronostico Decenal',
                                style: GoogleFonts.lexend(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
                                        fontSize: 15))),
                            Text('| Municipio de: ${widget.nombreMunicipio}',
                                style: GoogleFonts.lexend(
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Promotor>>(
                    future: _promotorFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay datos disponibles',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      } else {
                        final zonasUnicas = <String, Promotor>{};
                        for (var promotor in snapshot.data!) {
                          zonasUnicas[promotor.nombreZona] = promotor;
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            double width = constraints.maxWidth;

                            if (width >= 1200) {
                              crossAxisCount = 3;
                            } else if (width >= 800) {
                              crossAxisCount = 2;
                            }

                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio:
                                      width / (crossAxisCount * 400),
                                ),
                                itemCount: zonasUnicas.values.length,
                                itemBuilder: (context, index) {
                                  var promotor =
                                      zonasUnicas.values.elementAt(index);
                                  return _buildZonaCard(
                                    context,
                                    promotor.nombreZona,
                                    promotor.imagen,
                                    promotor.nombreCultivo,
                                    promotor.tipo,
                                    promotor.nombreFechaSiembra,
                                    promotorService,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
