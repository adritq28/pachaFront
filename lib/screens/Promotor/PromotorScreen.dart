import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/screens/OpcionZonaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

class PromotorScreen extends StatefulWidget {
  const PromotorScreen({super.key});

  @override
  PromotorScreenState createState() => PromotorScreenState();
}

class PromotorScreenState extends State<PromotorScreen> {
  final EstacionService _datosService3 = EstacionService();
  late PromotorService miModelo4;
  late List<Promotor> _Promotor = [];
  late List<String> _municipios = [];
  String? _selectedMunicipio;

  @override
  void initState() {
    super.initState();
    miModelo4 = Provider.of<PromotorService>(context, listen: false);
    _cargarPromotor();
  }

  Future<void> _cargarPromotor() async {
    try {
      await miModelo4.getPromotor();
      List<Promotor> a = miModelo4.lista11;
      setState(() {
        _Promotor = a;
        _municipios = a.map((e) => e.nombreMunicipio).toSet().toList();
      });
    } catch (e) {
      print('Error al cargar los datossss: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.nombreZonaCultivo,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: true,
          idUsuario: 0,
          estado: PerfilEstado.nombreZonaCultivo,
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
                const SizedBox(height: 10),
                Container(
                  height: 70,
                  color: const Color.fromARGB(
                      91, 4, 18, 43),
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
                            Text('PROMOTORES DE TIEMPO Y CLIMA',
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
                  'MUNICIPIOS: ',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color:
                          Color.fromARGB(255, 239, 239, 240),
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
                        color: Color.fromARGB(
                            255, 255, 255, 255),
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
                              color: Color.fromARGB(
                                  255, 238, 238, 255),
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
    List<Promotor> usuariosFiltrados = _selectedMunicipio == null
        ? _Promotor
        : _Promotor.where((u) => u.nombreMunicipio == _selectedMunicipio)
            .toList();

    double isSmallScreen = MediaQuery.of(context)
        .size
        .width;

    return ListView.builder(
        itemCount: (usuariosFiltrados.length / 2).ceil(),
        itemBuilder: (context, index) {
          int firstIndex = index * 2;
          int secondIndex = firstIndex + 1;

          var firstDato = usuariosFiltrados[firstIndex];
          var secondDato = secondIndex < usuariosFiltrados.length
              ? usuariosFiltrados[secondIndex]
              : null;
          bool isWideScreen = isSmallScreen > 600;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(
                      child: buildPromotorCard(context, firstDato),
                    ),
                    if (secondDato != null)
                      Expanded(
                        child: buildPromotorCard(context, secondDato),
                      ),
                  ],
                )
              : Column(
                  children: [
                    buildPromotorCard(context, firstDato),
                    if (secondDato != null)
                      buildPromotorCard(context, secondDato),
                  ],
                );
        });
  }

  Widget buildPromotorCard(BuildContext context, Promotor dato) {
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
              blurRadius: 4,
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
              "${dato.nombreCompleto}",
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Municipio: ${dato.nombreMunicipio.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 0, 7, 40),
                  fontSize: 16,
                ),
              ),
            ),
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

  void mostrarDialogoContrasena(BuildContext context, Promotor dato) {
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
                      textAlign: TextAlign
                          .center,
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
                    TextFormField(
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
                        labelStyle:
                            const TextStyle(color: Colors.blueGrey, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueAccent),
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
                        backgroundColor:
                            const Color(0xFFd35400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1abc9c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: const Text('OK',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () async {
                            final password = _passwordController.text;
                            final esValido = await _datosService3
                                .validarContrasena(password, dato.idUsuario);
                            if (esValido) {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  print(dato.idUsuario);
                                  return ChangeNotifierProvider(
                                    create: (context) => PromotorService(),
                                    child: OpcionZonaScreen(
                                      idUsuario: dato.idUsuario,
                                      idZona: dato.idZona,
                                      nombreZona: dato.nombreZona,
                                      nombreMunicipio: dato.nombreMunicipio,
                                      nombreCompleto: dato.nombreCompleto,
                                      telefono: dato.telefono,
                                      idCultivo: dato.idCultivo,
                                      nombreCultivo: dato.nombreCultivo,
                                      tipo: dato.tipo,
                                      imagen: dato.imagen,
                                      imagenP: dato.imagenP,
                                    ),
                                  );
                                }),
                              );
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
                                          Navigator.of(context)
                                              .pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                    ),
                  ],
                ),
              ]
            );
          },
        );
      },
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
        hintStyle: const TextStyle(
            color: Color.fromARGB(
                255, 180, 255, 231)),
        labelText: labelText,
        labelStyle:
            const TextStyle(color: Colors.blue),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color.fromARGB(255, 97, 173, 255),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      onSaved: onSaved,
    );
  }
}
