import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/DatosFechaSiembraScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String imagen;
  final String apePat;
  final String apeMat;
  final String ci;
  final bool admin;
  final String telefono;
  final String rol;
  final bool estado;
  final String password;

  const EditarUsuarioScreen(
      {super.key, required this.idUsuario,
      required this.nombre,
      required this.imagen,
      required this.apePat,
      required this.apeMat,
      required this.ci,
      required this.admin,
      required this.telefono,
      required this.rol,
      required this.estado,
      required this.password});

  @override
  EditarUsuarioScreenState createState() => EditarUsuarioScreenState();
}

class EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  TextEditingController imagenController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apePatController = TextEditingController();
  TextEditingController apeMatController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController rolController = TextEditingController();
  TextEditingController municipioController = TextEditingController();
  TextEditingController estacionController = TextEditingController();
  TextEditingController tipoEstacionController = TextEditingController();
  TextEditingController zonaController = TextEditingController();
  TextEditingController nombreCultivoController = TextEditingController();

  List<TextEditingController> municipioControllers = [];
  List<TextEditingController> estacionControllers = [];
  List<TextEditingController> tipoEstacionControllers = [];
  List<TextEditingController> zonaControllers = [];
  List<TextEditingController> nombreCultivoControllers = [];

  bool isAdmin = false;
  bool isEstado = false;
  String url = Url().apiUrl;
  File? _image;
  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;
  List<Map<String, dynamic>> estaciones = [];
  List<String> tiposEstacion = ['Meteorológica', 'Hidrológica'];
  String? municipioSeleccionado;
  String? estacionSeleccionada;
  String? tipoEstacionSeleccionada;
  int? idEstacionSeleccionada;
  int? idMunicipioSeleccionada;
  String? zonaSeleccionada;
  String? nombreCultivoSeleccionada;
  String? nombreZonaSeleccionada;
  int? idZonaSeleccionada;
  int? idCultivoSeleccionada;
  Map<String, List<Map<String, dynamic>>> estacionesPorMunicipio = {};

  List<Map<String, dynamic>> municipios = [];

  @override
  void initState() {
    super.initState();
    imagenController.text = widget.imagen;
    nombreController.text = widget.nombre;
    apePatController.text = widget.apePat;
    apeMatController.text = widget.apeMat;
    ciController.text = widget.ci;
    telefonoController.text = widget.telefono;
    rolController.text = widget.rol;
    isAdmin = widget.admin;
    isEstado = widget.estado;
    passwordController.text = widget.password;
    _image = File('images/${widget.imagen}');
    fetchDatosUsuario();
    fetchMunicipio();
  }

Future<void> guardarDatosSeleccionados(
    String tipoEstacion, String municipio, String estacion) async {
  try {
    var dio = Dio();
    final response = await dio.post(
      '$url/estacion/editar_estacion',
      data: {
        'tipoEstacion': tipoEstacion,
        'municipio': municipio,
        'estacion': estacion,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados exitosamente')),
      );
    } else {
      throw Exception('Error al guardar los datos');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar los datos: $e')),
    );
  }
}
  Future<void> fetchMunicipio() async {
  try {
    var dio = Dio();
    final response = await dio.get('$url/municipio/lista_municipio');

    if (response.statusCode == 200) {
      setState(() {
        municipios = List<Map<String, dynamic>>.from(
          response.data.map((municipio) => {
            'idMunicipio': municipio['idMunicipio'],
            'nombreMunicipio': municipio['nombreMunicipio']
          }),
        );
      });
    } else {
      throw Exception('Failed to load municipios');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al cargar los municipios')),
    );
  }
}


  Widget _buildAdminSwitch() {
    return TextField(
      decoration: InputDecoration(
        labelText: '¿Es Admin?',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: const Icon(Icons.admin_panel_settings, color: Colors.white),
        suffixIcon: Switch(
          value: isAdmin,
          onChanged: (value) {
            setState(() {
              isAdmin = value;
            });
          },
        ),
      ),
      style: const TextStyle(
        fontSize: 17.0,
        color: Color.fromARGB(255, 201, 219, 255),
      ),
      readOnly: true,
    );
  }

  Widget _buildEstadoSwitch() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Estado',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: const Icon(Icons.toggle_on, color: Colors.white),
        suffixIcon: Switch(
          value: isEstado,
          onChanged: (value) {
            setState(() {
              isEstado = value;
            });
          },
        ),
      ),
      style: const TextStyle(
        fontSize: 17.0,
        color: Color.fromARGB(255, 201, 219, 255),
      ),
      readOnly: true,
    );
  }

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var estacion in estaciones) {
      if (!agrupadas.containsKey(estacion['nombreMunicipio'])) {
        agrupadas[estacion['nombreMunicipio']] = [];
      }
      agrupadas[estacion['nombreMunicipio']]!.add(estacion);
    }
    return agrupadas;
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  Future<void> _selectImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    } else {
      print('No se seleccionó ninguna imagen');
    }
  }

Future<void> _guardarCambios() async {
  final dio = Dio();
  final url2 = '$url/usuario/editar';
  
  final data = {
    'idUsuario': widget.idUsuario,
    'imagen': imagenController.text.isNotEmpty ? imagenController.text : null,
    'nombre': nombreController.text.isEmpty ? null : nombreController.text,
    'apePat': apePatController.text.isEmpty ? null : apePatController.text,
    'apeMat': apeMatController.text,
    'ci': ciController.text.isEmpty ? null : ciController.text,
    'admin': isAdmin,
    'telefono': telefonoController.text,
    'password': passwordController.text,
    'estado': isEstado,
  };

  try {
    final response = await dio.post(url2, data: data);
    
    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true);
    } else {
      print('Error al actualizar los datos');
    }
  } catch (e) {
    print('Error al guardar cambios: $e');
  }
}


  Future<void> fetchDatosUsuario() async {
  try {
    var dio = Dio();
    final response = await dio.get('$url/usuario/roles/${widget.idUsuario}');

    if (response.statusCode == 200) {
      final responseBody = response.data;
      if (responseBody is List) {
        setState(() {
          datosUsuario = List<Map<String, dynamic>>.from(responseBody);
          print("Datos del usuario recibidos: $datosUsuario");

          if (datosUsuario.isNotEmpty) {
            for (var usuario in datosUsuario) {
              municipioControllers.add(
                  TextEditingController(text: usuario['municipio'] ?? 'N/A'));
              estacionControllers.add(
                  TextEditingController(text: usuario['estacion'] ?? 'N/A'));
              tipoEstacionControllers.add(TextEditingController(
                  text: usuario['tipoEstacion'] ?? 'N/A'));
              zonaControllers
                  .add(TextEditingController(text: usuario['zona'] ?? 'N/A'));
              nombreCultivoControllers.add(TextEditingController(
                  text: usuario['cultivoNombre'] ?? 'N/A'));

              municipioSeleccionado = usuario['municipio'];
              estacionSeleccionada = usuario['estacion'];
              tipoEstacionSeleccionada = usuario['tipoEstacion'];
              idEstacionSeleccionada = usuario['idEstacion'];
              idMunicipioSeleccionada = usuario['idMunicipio'];
              idZonaSeleccionada = usuario['idZona'];
              zonaSeleccionada = usuario['zona'];
              nombreCultivoSeleccionada = usuario['cultivoNombre'];
              idCultivoSeleccionada = usuario['idCultivo'];
            }

            tiposEstacion = ['Meteorologica', 'Hidrologica'];
          }

          isLoading = false;
        });
      } else {
        throw Exception('El formato de la respuesta no es una lista.');
      }
    } else {
      print('Error: ${response.statusCode}, Body: ${response.data}');
      throw Exception('Error al obtener los datos del usuario');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Error en fetchDatosUsuario: $e');
  }
}


  @override
  void dispose() {
    municipioController?.dispose();
    estacionController?.dispose();
    tipoEstacionController?.dispose();
    zonaController?.dispose();
    nombreCultivoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          CustomDrawer(idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
            isHomeScreen: false,
            idUsuario: 0,
            estado: PerfilEstado.soloNombreTelefono),
      ),
      body: Stack(
        children: [
          const FondoWidget(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              Text('| Admin | Seccion Editar',
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
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: _buildImage(),
                        ),
                        const SizedBox(
                            height: 10),
                        MouseRegion(
                          cursor: SystemMouseCursors
                              .click,
                          child: GestureDetector(
                            onTap: _selectImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(
                                    8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize
                                    .min,
                                children: [
                                  Icon(Icons.image,
                                      color: Colors.white),
                                  SizedBox(
                                      width:
                                          8),
                                  Text(
                                    'Seleccionar Imagen',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: nombreController,
                                      decoration: getInputDecoration(
                                          'Nombre', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: apePatController,
                                      decoration: getInputDecoration(
                                          'Apellido Paterno', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: apeMatController,
                                      decoration: getInputDecoration(
                                          'Apellido Materno', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: ciController,
                                      decoration: getInputDecoration(
                                          'CI', Icons.card_membership),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: telefonoController,
                                      decoration: getInputDecoration(
                                          'Teléfono', Icons.phone),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildAdminSwitch(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: rolController,
                                      decoration: getInputDecoration(
                                          'Rol', Icons.phone),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildEstadoSwitch(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      decoration: getInputDecoration(
                                          'Password', Icons.phone),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextField(
                                controller: nombreController,
                                decoration:
                                    getInputDecoration('Nombre', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: apePatController,
                                decoration: getInputDecoration(
                                    'Apellido Paterno', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: apeMatController,
                                decoration: getInputDecoration(
                                    'Apellido Materno', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: ciController,
                                decoration: getInputDecoration(
                                    'CI', Icons.card_membership),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: telefonoController,
                                decoration: getInputDecoration(
                                    'Teléfono', Icons.phone),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              _buildAdminSwitch(),
                              const SizedBox(height: 20),
                              TextField(
                                controller: rolController,
                                decoration:
                                    getInputDecoration('Rol', Icons.phone),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              _buildEstadoSwitch(),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                decoration: getInputDecoration(
                                    'Password', Icons.phone),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 240,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17A589),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _guardarCambios,
                        icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                        label: Text(
                          'Guardar',
                          style: getTextStyleNormal20(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
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
                              Text(
                                widget.rol == null
                                    ? ''
                                    : widget.rol == '1'
                                        ? ''
                                        : widget.rol == '2'
                                            ? 'CREAR DATOS OBSERVADOR'
                                            : 'CREAR DATOS PROMOTOR',
                                style: getTextStyleNormal20(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildUserInfoGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFile(String labelText, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: valueText,
        decoration: getInputDecoration(labelText, icon),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildObservadorCard(Map<String, dynamic> usuario, int index) {
    if (municipioControllers == null ||
        estacionControllers == null ||
        tipoEstacionControllers == null) {
      return const Center(
          child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize
            .min,
        children: [
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.white),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: const Color.fromARGB(255, 3, 50, 112),
                value: municipioSeleccionado,
                hint: Text(
                  'Seleccione un municipio',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    municipioSeleccionado = newValue;
                    Map<String, dynamic> municipioSeleccionadoObj =
                        municipios.firstWhere(
                      (municipio) => municipio['nombreMunicipio'] == newValue,
                      orElse: () =>
                          {},
                    );

                    idMunicipioSeleccionada =
                        municipioSeleccionadoObj.isNotEmpty
                            ? municipioSeleccionadoObj['idMunicipio']
                            : null;

                    print('ddddd' + idMunicipioSeleccionada.toString());
                    if (municipioSeleccionadoObj != null) {
                      idMunicipioSeleccionada =
                          municipioSeleccionadoObj['idMunicipio'];
                    } else {
                      idMunicipioSeleccionada =
                          null;
                    }
                  });
                },
                items: municipios.isNotEmpty
                    ? municipios.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> municipio) {
                        return DropdownMenuItem<String>(
                          value: municipio['nombreMunicipio'],
                          child: Text(
                            municipio['nombreMunicipio'],
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildEditableField(
                    'Estación', estacionControllers[index], Icons.dashboard),
                _buildEditableField('Tipo Estación',
                    tipoEstacionControllers[index], Icons.settings),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                onPressed: () => _guardarCambiosObservador(index),
                icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotorCard(Map<String, dynamic> usuario, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: const Color.fromARGB(255, 3, 50, 112),
                  value: municipioSeleccionado,
                  hint: Text(
                    'Seleccione un municipio',
                    style: GoogleFonts.lexend(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      municipioSeleccionado = newValue;
                      Map<String, dynamic> municipioSeleccionadoObj =
                          municipios.firstWhere(
                        (municipio) => municipio['nombreMunicipio'] == newValue,
                        orElse: () =>
                            {},
                      );

                      idMunicipioSeleccionada =
                          municipioSeleccionadoObj.isNotEmpty
                              ? municipioSeleccionadoObj['idMunicipio']
                              : null;
                    });
                  },
                  items: municipios.isNotEmpty
                      ? municipios.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> municipio) {
                          return DropdownMenuItem<String>(
                            value: municipio['nombreMunicipio'],
                            child: Text(
                              municipio['nombreMunicipio'],
                              style: GoogleFonts.lexend(
                                textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildEditableField('Zona', zonaControllers[index], Icons.map),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween,
              children: [
                // Botón Guardar
                Container(
                  width: 240,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17A589),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _guardarCambiosPromotor(index),
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.save_as_outlined, color: Colors.white),
                    ),
                    label: Text(
                      'Guardar',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),

                Container(
                  width: 240,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DatosFechaSiembraScreen(
                            idZona: idZonaSeleccionada ?? 0,
                            nombreMunicipio: municipioSeleccionado ?? '',
                            nombreZona: zonaSeleccionada ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    label: Text(
                      'Editar Cultivo',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_image != null) {
      return Image.asset(
        'images/${widget.imagen}',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'images/1.jpg',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildEditableField(
      String labelText, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller:
            controller,
        decoration: getInputDecoration(labelText, icon),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

Future<void> _guardarCambiosObservador(int index) async {
  String estacionEditada = estacionControllers[index].text;
  String tipoEstacionEditada = tipoEstacionControllers[index].text;

  final dio = Dio();
  final url2 = '$url/estacion/editar_estacion';

  final data = {
    'idEstacion': idEstacionSeleccionada,
    'idMunicipio': idMunicipioSeleccionada,
    'nombre': estacionEditada.isEmpty ? null : estacionEditada,
    'tipoEstacion': tipoEstacionEditada.isEmpty ? null : tipoEstacionEditada,
  };

  try {
    final response = await dio.post(url2, data: data);

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true);
    } else {
      print('Error al actualizar los datos');
    }
  } catch (e) {
    print('Error al guardar cambios: $e');
  }
}

  Future<void> _guardarCambiosPromotor(int index) async {
  String zonaEditada = zonaControllers[index].text;

  final dio = Dio();
  final url2 = '$url/zona/editar_zona';

  final data = {
    'idZona': idZonaSeleccionada,
    'idMunicipio': idMunicipioSeleccionada,
    'nombre': zonaEditada.isEmpty ? null : zonaEditada,
  };

  try {
    final response = await dio.post(url2, data: data);

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true);
    } else {
      print('Error al actualizar los datos');
    }
  } catch (e) {
    print('Error al guardar cambios: $e');
  }
}


  Widget _buildUserInfoGrid() {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      shrinkWrap:
          true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: datosUsuario.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> usuario = datosUsuario[index];

        if (usuario['rol'] == '2') {
          return _buildObservadorCard(usuario, index);
        } else if (usuario['rol'] == '3') {
          return _buildPromotorCard(
              usuario, index);
        }

        return const SizedBox();
      },
    );
  }
}
