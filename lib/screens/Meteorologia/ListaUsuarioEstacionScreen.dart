import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/model/UsuarioEstacion.dart';
import 'package:helvetasfront/screens/Hidrologia/ListaEstacionHidrologicaScreen.dart';
import 'package:helvetasfront/screens/Meteorologia/ListaEstacionScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

class ListaUsuarioEstacionScreen extends StatefulWidget {
  const ListaUsuarioEstacionScreen({super.key});

  @override
  ListaUsuarioEstacionScreenState createState() =>
      ListaUsuarioEstacionScreenState();
}

class ListaUsuarioEstacionScreenState
    extends State<ListaUsuarioEstacionScreen> {
  late EstacionService estacion;
  late UsuarioService miModelo4;
  late List<UsuarioEstacion> _usuarioEstacion = [];
  late List<String> _municipios = [];
  String? _selectedMunicipio;

  @override
  void initState() {
    super.initState();
    miModelo4 = Provider.of<UsuarioService>(context, listen: false);
    estacion = Provider.of<EstacionService>(context, listen: false);
    _cargarUsuarioEstacion();
  }

  Future<void> _cargarUsuarioEstacion() async {
    try {
      await miModelo4.getUsuario();
      List<UsuarioEstacion> a = miModelo4.lista11;
      setState(() {
        _usuarioEstacion = a;
        _municipios = a.map((e) => e.nombreMunicipio).toSet().toList();
      });
    } catch (e) {
      print('Error al cargar los datos5555: $e');
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
          showProfileButton: false,
          idUsuario: 0,
          estado: PerfilEstado.nombreEstacionMunicipio,
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
                      const SizedBox(width: 15),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Text('Bienvenid@ | ',
                                style: GoogleFonts.lexend(
                                    textStyle: const TextStyle(
                                  color: Colors.white60,
                                ))),
                            Text('OBSERVADORES METEOROLÓGICOS E HIDROLÓGICOS',
                                textAlign: TextAlign.center,
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
                const SizedBox(height: 15),
                Text(
                  'Municipios: ',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 239, 239, 240),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: const Color.fromARGB(255, 3, 50, 112),
                  hint: Text(
                    "Seleccione un Municipio",
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  value: _selectedMunicipio,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMunicipio = newValue;
                    });
                  },
                  items:
                      _municipios.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: GoogleFonts.convergence(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 244, 244, 255),
                              fontSize: 15.0,
                            ),
                          )),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: op2(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget op2(BuildContext context) {
    List<UsuarioEstacion> usuariosFiltrados = _selectedMunicipio == null
        ? _usuarioEstacion
        : _usuarioEstacion
            .where((u) => u.nombreMunicipio == _selectedMunicipio)
            .toList();

    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      itemCount: (usuariosFiltrados.length / 2).ceil(),
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        var firstDato = usuariosFiltrados[firstIndex];
        var secondDato = secondIndex < usuariosFiltrados.length
            ? usuariosFiltrados[secondIndex]
            : null;
        bool isWideScreen = screenWidth > 600;

        return isWideScreen
            ? Row(
                children: [
                  Expanded(
                    child: buildCard(context, firstDato),
                  ),
                  if (secondDato != null)
                    Expanded(
                      child: buildCard(context, secondDato),
                    ),
                ],
              )
            : Column(
                children: [
                  buildCard(context, firstDato),
                  if (secondDato != null) buildCard(context, secondDato),
                ],
              );
      },
    );
  }

  Widget buildCard(BuildContext context, UsuarioEstacion dato) {
    return InkWell(
      onTap: () {
        mostrarDialogoContrasena(context, dato);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("images/${dato.imagen}"),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              dato.nombreCompleto,
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Estación: ${dato.tipoEstacion.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "Municipio: ${dato.nombreMunicipio.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "Estación: ${dato.nombreEstacion.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.assignment_add,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    mostrarDialogoContrasena(context, dato);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void mostrarDialogoContrasena(BuildContext context, UsuarioEstacion dato) {
    final TextEditingController _passwordController = TextEditingController();
    bool _obscureText = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      'Ingrese sus credenciales',
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
              content: Container(
                width: 400,
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(
                            color: Colors.blueGrey, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd35400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1abc9c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('OK',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () async {
                        final password = _passwordController.text;
                        final esValido = await estacion.validarContrasena(
                            password, dato.idUsuario);
                        if (esValido) {
                          await estacion
                              .actualizarUltimoAcceso(dato.idUsuario);

                          Navigator.of(context).pop();

                          if (dato.codTipoEstacion) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChangeNotifierProvider(
                                  create: (context) => EstacionService(),
                                  child: ListaEstacionScreen(
                                    idUsuario: dato.idUsuario,
                                    nombreMunicipio: dato.nombreMunicipio,
                                    nombreEstacion: dato.nombreEstacion,
                                    tipoEstacion: dato.tipoEstacion,
                                    nombreCompleto: dato.nombreCompleto,
                                    telefono: dato.telefono,
                                    idEstacion: dato.idEstacion,
                                    codTipoEstacion: dato.codTipoEstacion,
                                    imagen: dato.imagen,
                                  ),
                                );
                              }),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChangeNotifierProvider(
                                  create: (context) =>
                                      EstacionHidrologicaService(),
                                  child: ListaEstacionHidrologicaScreen(
                                    idUsuario: dato.idUsuario,
                                    nombreMunicipio: dato.nombreMunicipio,
                                    nombreEstacion: dato.nombreEstacion,
                                    tipoEstacion: dato.tipoEstacion,
                                    nombreCompleto: dato.nombreCompleto,
                                    telefono: dato.telefono,
                                    idEstacion: dato.idEstacion,
                                    codTipoEstacion: dato.codTipoEstacion,
                                    imagen: dato.imagen,
                                  ),
                                );
                              }),
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Contraseña incorrecta'),
                                actions: [
                                  TextButton(
                                    child: const Text('Aceptar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
