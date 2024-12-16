import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/decoration.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:intl/intl.dart';

class AnadirUsuarioScreen extends StatefulWidget {
  final int? idUsuario;

  const AnadirUsuarioScreen({
    super.key,
    required this.idUsuario,
  });

  @override
  AnadirUsuarioScreenState createState() => AnadirUsuarioScreenState();
}

class AnadirUsuarioScreenState extends State<AnadirUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController imagenController = TextEditingController();
  final TextEditingController nombreUsuarioController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apePatController = TextEditingController();
  final TextEditingController apeMatController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController ciController = TextEditingController();
  final TextEditingController adminController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController rolController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController nombreNuevoMunicipioController =
      TextEditingController();

  bool isAdmin = false;
  bool isEstado = false;
  bool delete = false;
  bool edit = false;
  bool estado = true;
  String url = Url().apiUrl;
  File? _image;
  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;
  List<Map<String, dynamic>> estaciones = [];
  List<String> tiposEstacion = ['Meteorológica', 'Hidrológica'];
  String? municipioSeleccionado;
  String? tipoEstacionSeleccionada;
  int? idEstacionSeleccionada;
  int? idMunicipioSeleccionada;
  String? zonaSeleccionada;
  String? nombreCultivoSeleccionada;
  String? nombreZonaSeleccionada;
  int? idZonaSeleccionada;
  int? idCultivoSeleccionada;
  int? idUsuarioSeleccionada;
  String? rolSeleccionado;
  Map<String, List<Map<String, dynamic>>> estacionesPorMunicipio = {};
  Map<String, List<Map<String, dynamic>>> zonasPorMunicipio = {};
  List<Map<String, dynamic>> zonas = [];
  String? estacionSeleccionada;

  List<Map<String, dynamic>> municipios = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  Uint8List? imageBytes;
  String? imageName;
  String? imagePath;

  bool mostrarFormularioNuevoMunicipio = false;
  bool mostrarFormularioNuevaEstacion = false;

  bool mostrarFormularioNuevoMunicipioZ = false;
  bool mostrarFormularioNuevaZona = false;

  final TextEditingController nombreNuevaEstacion = TextEditingController();
  final TextEditingController latitud = TextEditingController();
  final TextEditingController longitud = TextEditingController();
  final TextEditingController altura = TextEditingController();
  String? tipoEstacion;
  final TextEditingController nombreNuevaZona = TextEditingController();
  bool isButtonDisabledUsuario = false;
  bool isButtonDisabledMunicipio = false;
  bool isButtonDisabledEstacion = false;
  bool isButtonDisabledObservador = false;
  bool isButtonDisabledPromotor = false;
  bool isButtonDisabledZona = false;

  late PromotorService promotorService = PromotorService();
  late UsuarioService usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    fetchMunicipio();
    fetchEstaciones();
    fetchZonas();
  }

  @override
  void dispose() {
    imagenController.dispose();
    nombreController.dispose();
    apePatController.dispose();
    apeMatController.dispose();
    ciController.dispose();
    telefonoController.dispose();
    rolController.dispose();
    super.dispose();
  }

  void _guardarCambiosPromotor() async {
    if (idMunicipioSeleccionada != null) {
      final errorMessage = await promotorService.addPromotor(
        idUsuario: idUsuarioSeleccionada!,
        idMunicipio: idMunicipioSeleccionada!,
      );

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dato añadido correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir dato: $errorMessage')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un municipio válido')),
      );
    }
  }

  void guardarDatosSeleccionados(String municipio, dynamic idEstacion) async {
    if (idEstacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: idEstacion no seleccionado')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newDato = {
        'idUsuario': idUsuarioSeleccionada,
        'idEstacion': idEstacionSeleccionada
      };

      try {
        final dio = Dio();
        final response = await dio.post(
          '$url/observador/addObservador',
          data: newDato,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dato añadido correctamente')),
          );
          Navigator.pop(context, true);
        } else {
          final errorMessage = response.data ?? 'Error desconocido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir dato: $errorMessage')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir dato: $e')),
        );
      }
    }
  }

  Future<void> guardarDato() async {
  if (_formKey.currentState!.validate()) {
    try {
      DateTime fechaActual = DateTime.now();

      String nombre = nombreController.text.trim();
      String apePat = apePatController.text.trim();
      String nombreUsuarioGenerado = '';

      if (nombre.isNotEmpty && apePat.isNotEmpty) {
        nombreUsuarioGenerado =
            '$nombre${apePat.substring(0, 2).toLowerCase()}';
      }

      final newDato = {
        'nombreUsuario': nombreUsuarioGenerado,
        'nombre': nombre.isEmpty ? null : nombre,
        'apePat': apePat.isEmpty ? null : apePat,
        'apeMat':
            apeMatController.text.trim().isEmpty ? null : apeMatController.text,
        'telefono': telefonoController.text.trim().isEmpty
            ? null
            : telefonoController.text,
        'ci': ciController.text.trim().isEmpty ? null : ciController.text,
        'password': ciController.text.trim().isEmpty ? null : ciController.text,
        'fechaCreacion': fechaActual.toIso8601String(),
        'ultimoAcceso': fechaActual.toIso8601String(),
        'estado': isEstado,
        'rol': rolSeleccionado,
        'delete': delete,
        'edit': edit,
        'imagen': imageName,
        'correoElectronico': correoController.text.trim().isEmpty
            ? null
            : correoController.text,
      };

      Dio dio = Dio();

      FormData formData = FormData.fromMap({
        ...newDato.map((key, value) => MapEntry(key, value.toString())),
        if (_image != null)
          'imagen': await MultipartFile.fromFile(
            _image!.path,
            filename: imageName,
          ),
        if (_image == null && imageBytes != null)
          'imagen': MultipartFile.fromBytes(
            imageBytes!,
            filename: imageName,
          ),
      });

      Response response = await dio.post(
        '$url/usuario/addUsuario',
        data: formData,
      );

      if (response.statusCode == 201) {
        print('Usuario añadido correctamente: ${response.data}');
        final idUsuario = response.data['idUsuario'];

        setState(() {
          idUsuarioSeleccionada = idUsuario;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Usuario añadido correctamente. ID: $idUsuario')),
        );
      } else {
        print('Error: ${response.statusCode}');
        print('Respuesta del servidor: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al añadir usuario: ${response.data}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al añadir el usuario')),
      );
    }
    nombreUsuarioController.clear();
    nombreController.clear();
    apePatController.clear();
    apeMatController.clear();
    ciController.clear();
    rolController.clear();
    telefonoController.clear();
    imagenController.clear();
  }
}

  Future<void> fetchMunicipio() async {
    try {
      final dio = Dio();
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

  Future<void> fetchZonas() async {
    try {
      final dio = Dio();
      final response = await dio.get('$url/zona/lista_zonas');

      if (response.statusCode == 200) {
        setState(() {
          zonas = List<Map<String, dynamic>>.from(response.data);
          zonasPorMunicipio = agruparZonasPorMunicipio(zonas);
        });
      } else {
        throw Exception('Failed to load estaciones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las estaciones')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparZonasPorMunicipio(
      List<Map<String, dynamic>> zonas) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};

    for (var zona in zonas) {
      String nombreMunicipio = zona['nombreMunicipio'];
      if (!agrupadas.containsKey(nombreMunicipio)) {
        agrupadas[nombreMunicipio] = [];
      }
      agrupadas[nombreMunicipio]!.add({
        'nombreZona': zona['nombreZona'],
        'idZona': zona['idZona'],
        'idMunicipio': zona['idMunicipio'],
        'nombreMunicipio': nombreMunicipio,
      });
    }

    return agrupadas;
  }

  Future<void> fetchEstaciones() async {
    try {
      final dio = Dio();
      final response = await dio.get('$url/estacion/lista_estaciones');

      if (response.statusCode == 200) {
        setState(() {
          estaciones = List<Map<String, dynamic>>.from(response.data);
          estacionesPorMunicipio = agruparEstacionesPorMunicipio(estaciones);
        });
      } else {
        throw Exception('Failed to load estaciones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las estaciones')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};

    for (var estacion in estaciones) {
      String nombreMunicipio = estacion['nombreMunicipio'];
      int idMunicipio = estacion['idMunicipio'];
      if (!agrupadas.containsKey(nombreMunicipio)) {
        agrupadas[nombreMunicipio] = [];
      }
      agrupadas[nombreMunicipio]!.add({
        'nombreEstacion': estacion['nombreEstacion'],
        'tipoEstacion': estacion['tipoEstacion'],
        'idEstacion': estacion['idEstacion'],
        'idMunicipio': idMunicipio,
        'nombreMunicipio': nombreMunicipio,
      });
    }

    return agrupadas;
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

  Widget _buildDropdownTiposEstacion() {
    return Container(
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
          value: tipoEstacionSeleccionada,
          hint: Text(
            'Seleccione tipo de estación',
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              tipoEstacionSeleccionada = newValue;
              municipioSeleccionado = null;
              estacionSeleccionada = null;
            });
          },
          items: tiposEstacion.map<DropdownMenuItem<String>>((String tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(
                tipo,
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdownEstaciones() {
    return Container(
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
          value: estacionSeleccionada != null &&
                  estacionesPorMunicipio[municipioSeleccionado]?.any(
                          (estacion) =>
                              estacion['nombreEstacion'] ==
                              estacionSeleccionada) ==
                      true
              ? estacionSeleccionada
              : null,
          hint: Text(
            'Seleccione una estación',
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              estacionSeleccionada = newValue;
              mostrarFormularioNuevaEstacion = (newValue == 'Otro');
              if (newValue != null &&
                  estacionesPorMunicipio[municipioSeleccionado]!.any(
                      (estacion) => estacion['nombreEstacion'] == newValue)) {
                var estacionSeleccionadaData =
                    estacionesPorMunicipio[municipioSeleccionado]!.firstWhere(
                        (estacion) => estacion['nombreEstacion'] == newValue);
                idEstacionSeleccionada = estacionSeleccionadaData['idEstacion'];
                print('idEstacionSeleccionada: $idEstacionSeleccionada');
              }
            });
          },
          items: [
            if (estacionesPorMunicipio[municipioSeleccionado] != null &&
                !estacionesPorMunicipio[municipioSeleccionado]!
                    .any((estacion) => estacion['nombreEstacion'] == 'Otro'))
              DropdownMenuItem<String>(
                value: 'Otro',
                child: Text(
                  'Otro',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ...?estacionesPorMunicipio[municipioSeleccionado]
                ?.map<DropdownMenuItem<String>>((mapaEstacion) {
              String estacion2 =
                  '${mapaEstacion['nombreEstacion']} - ${mapaEstacion['tipoEstacion']}';
              String nombreEstacion =
                  mapaEstacion['nombreEstacion'] ?? 'Estación no disponible';

              return DropdownMenuItem<String>(
                value: nombreEstacion,
                child: Text(
                  estacion2,
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
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
    print('Botón presionado');

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (kIsWeb) {
        print('Imagen seleccionada (Web): ${result.files.single.name}');
        setState(() {
          imageBytes = result.files.single.bytes;
          imageName = result.files.single.name;
        });
      } else {
        print('Imagen seleccionada (Móvil): ${result.files.single.path}');
        setState(() {
          _image = File(result.files.single.path!);
          imageName = result.files.single.name;
        });
      }
    } else {
      print('No se seleccionó ninguna imagen');
    }
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
                              Text('| Admin | Seccion Añadir',
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (imageBytes != null || _image != null) ...[
                        ClipOval(
                          child: kIsWeb
                              ? Image.memory(
                                  imageBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Imagen seleccionada: ${imageName ?? 'Sin nombre'}',
                          style: const TextStyle(
                              color: Colors.green, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _selectImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.image, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Seleccionar Imagen',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: nombreController,
                                      decoration: getInputDecoration(
                                          'Nombre', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, ingresa tu nombre';
                                        }
                                        if (value.length < 3) {
                                          return 'El nombre debe tener al menos 3 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: apePatController,
                                      decoration: getInputDecoration(
                                          'Apellido Paterno', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, ingresa tu apellido paterno';
                                        }
                                        if (value.length < 3) {
                                          return 'El nombre debe tener al menos 3 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: apeMatController,
                                      decoration: getInputDecoration(
                                          'Apellido Materno', Icons.person),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: ciController,
                                      decoration: getInputDecoration(
                                          'CI', Icons.card_membership),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El CI no puede estar vacío';
                                        }
                                        if (value.length < 5) {
                                          return 'El CI debe tener al menos 5 caracteres';
                                        }
                                        if (!RegExp(r'^[A-Za-z0-9]+$')
                                            .hasMatch(value)) {
                                          return 'El CI debe contener solo letras y números';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: telefonoController,
                                      decoration: getInputDecoration(
                                          'Teléfono', Icons.phone),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El teléfono no puede estar vacío';
                                        }
                                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                                          return 'El teléfono solo debe contener números';
                                        }
                                        if (value.length < 8 ||
                                            value.length > 15) {
                                          return 'El teléfono debe tener entre 8 y 15 dígitos';
                                        }
                                        return null;
                                      },
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: rolSeleccionado,
                                          decoration: getInputDecoration(
                                            'Rol',
                                            Icons.person_outline,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 17.0,
                                            color: Color.fromARGB(
                                                255, 201, 219, 255),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: '1',
                                              child: Text('Administrador'),
                                            ),
                                            DropdownMenuItem(
                                              value: '2',
                                              child: Text('Observador'),
                                            ),
                                            DropdownMenuItem(
                                              value: '3',
                                              child: Text('Promotor'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              rolSeleccionado = value;
                                            });
                                          },
                                          dropdownColor: const Color.fromARGB(
                                              255, 35, 47, 62),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor, selecciona un rol';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
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
                                    child: TextFormField(
                                      controller: correoController,
                                      decoration: getInputDecoration(
                                          'Correo Electrónico', Icons.email),
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return null;
                                        }

                                        final emailRegex = RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Por favor, ingresa un correo electrónico válido';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextFormField(
                                controller: nombreController,
                                decoration:
                                    getInputDecoration('Nombre', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu nombre';
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: apePatController,
                                decoration: getInputDecoration(
                                    'Apellido Paterno', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu apellido paterno';
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: apeMatController,
                                decoration: getInputDecoration(
                                    'Apellido Materno', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu apellido materno';
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: ciController,
                                  decoration: getInputDecoration(
                                      'CI', Icons.card_membership),
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: Color.fromARGB(255, 201, 219, 255),
                                  ),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El CI no puede estar vacío';
                                    }
                                    if (value.length < 5) {
                                      return 'El CI debe tener al menos 5 caracteres';
                                    }
                                    if (!RegExp(r'^[A-Za-z0-9]+$')
                                        .hasMatch(value)) {
                                      return 'El CI debe contener solo letras y números';
                                    }
                                    return null;
                                  }),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: telefonoController,
                                decoration:
                                    getInputDecoration('Teléfono', Icons.phone),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El teléfono no puede estar vacío';
                                  }
                                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                                    return 'El teléfono solo debe contener números';
                                  }
                                  if (value.length < 8 || value.length > 15) {
                                    return 'El teléfono debe tener entre 8 y 15 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildAdminSwitch(),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: rolSeleccionado,
                                decoration: getInputDecoration(
                                  'Rol',
                                  Icons.person_outline,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Administrador'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Observador'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('Promotor'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    rolSeleccionado = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, selecciona un rol';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: correoController,
                                decoration: getInputDecoration(
                                    'Correo Electronico', Icons.person),
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Por favor, ingresa un correo electrónico válido';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
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
                        onPressed: isButtonDisabledUsuario
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isButtonDisabledUsuario = true;
                                  });
                                  guardarDato();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Por favor, corrige los errores.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.save_as_outlined,
                            color: Colors.white),
                        label: Text(
                          'Añadir Usuario',
                          style: getTextStyleNormal20(),
                        ),
                      ),
                    ),
                  ),
                  if (rolSeleccionado == '2') _buildEstacionesList(),
                  if (rolSeleccionado == '3') _buildPromotorFields(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstacionesList() {
    if (rolSeleccionado == '2') {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mostrarFormularioNuevoMunicipio) ...[
                Container(
                  height: 70,
                  color: const Color.fromARGB(91, 4, 18, 43),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Text(
                              'CREAR DATOS OBSERVADOR',
                              style: getTextStyleNormal20(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Seleccione un municipio y una estación:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 234, 240, 255),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildDropdownMunicipios()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDropdownEstaciones()),
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
                      onPressed: isButtonDisabledObservador
                          ? null
                          : () {
                              if (municipioSeleccionado == null ||
                                  idEstacionSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Debe seleccionar un municipio y una estación antes de continuar.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                setState(() {
                                  isButtonDisabledObservador = true;
                                });
                                guardarDatosSeleccionados(
                                  municipioSeleccionado!,
                                  idEstacionSeleccionada,
                                );
                              }
                            },
                      icon: const Icon(Icons.save_as_outlined,
                          color: Colors.white),
                      label: Text(
                        'Añadir Observador',
                        style: getTextStyleNormal20(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (mostrarFormularioNuevoMunicipio) ...[
                Column(
                  children: [
                    _buildNuevoMunicipioForm(),
                    _buildNuevaEstacionForm(),
                  ],
                ),
              ],
              if (mostrarFormularioNuevaEstacion) ...[
                Column(
                  children: [
                    _buildNuevaEstacionForm(),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildDropdownMunicipios() {
    return Container(
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
          value: municipioSeleccionado != null &&
                  estacionesPorMunicipio.keys.contains(municipioSeleccionado)
              ? municipioSeleccionado
              : null,
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
            mostrarFormularioNuevaEstacion = false;
            setState(() {
              municipioSeleccionado = newValue;
              estacionSeleccionada = null;
              mostrarFormularioNuevoMunicipio = (newValue == 'Otro');
              if (newValue != null &&
                  estacionesPorMunicipio.containsKey(newValue)) {
                var estacionesDelMunicipio = estacionesPorMunicipio[newValue];
                if (estacionesDelMunicipio != null &&
                    estacionesDelMunicipio.isNotEmpty) {
                  var idMunicipio = estacionesDelMunicipio[0]['idMunicipio'];
                  print(estacionesDelMunicipio[0]['idMunicipio']);
                  idMunicipioSeleccionada = idMunicipio;
                }
              }
            });
          },
          items: [
            ...estacionesPorMunicipio.keys
                .map<DropdownMenuItem<String>>((String municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(
                  municipio,
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            DropdownMenuItem<String>(
              value: 'Otro',
              child: Text(
                'Otro',
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNuevoMunicipioForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        'CREAR NUEVO MUNICIPIO',
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      mostrarFormularioNuevoMunicipio = false;
                      mostrarFormularioNuevoMunicipioZ = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevoMunicipioController,
            decoration: getInputDecoration('Nombre del Municipio', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Seleccionar Imagen',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
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
                onPressed: isButtonDisabledMunicipio
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledMunicipio = true;
                        });
                        _guardarNuevoMunicipio();
                      },
                icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar municipio',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNuevoMunicipio() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevoMunicipioController.text,
          'delete': delete,
          'edit': edit,
          'imagen': imageName,
          'fechaCreacion': fechaActual.toIso8601String(),
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        var dio = Dio();
        FormData formData = FormData.fromMap(newDato);

        if (_image != null) {
          formData.files.add(MapEntry(
            'imagen',
            await MultipartFile.fromFile(_image!.path, filename: imageName),
          ));
        } else if (imageBytes != null) {
          formData.files.add(MapEntry(
            'imagen',
            MultipartFile.fromBytes(imageBytes!, filename: imageName),
          ));
        }

        final response =
            await dio.post('$url/municipio/addMunicipio', data: formData);

        if (response.statusCode == 201) {
          final decodedResponse = response.data;
          final idMunicipio = decodedResponse['idMunicipio'];

          setState(() {
            idMunicipioSeleccionada = idMunicipio;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Municipio añadido correctamente. ID: $idMunicipio')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al añadir municipio: ${response.data}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ocurrió un error al añadir el municipio')),
        );
      }
      nombreNuevoMunicipioController.clear();
    }
  }

  Widget _buildNuevaEstacionForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        'CREAR NUEVA ESTACION',
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevaEstacion,
            decoration: getInputDecoration('Nombre de Estacion', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: latitud,
            decoration: getInputDecoration('Latitud', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: longitud,
            decoration: getInputDecoration('Longitud', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: altura,
            decoration: getInputDecoration('Altura', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdownTiposEstacion(),
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
                onPressed: isButtonDisabledEstacion
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledEstacion = true;
                        });
                        _guardarNuevaEstacion();
                      },
                icon: const Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar Estación',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModal(String municipio, String estacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 3, 50, 112),
          title: const Text(
            'Estación Creada',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'El observador se añadirá al municipio $municipio y la estación $estacion.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                guardarDatosSeleccionados(nombreNuevoMunicipioController.text,
                    idEstacionSeleccionada);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarNuevaEstacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevaEstacion.text,
          'latitud': latitud.text,
          'longitud': longitud.text,
          'altura': altura.text,
          'estado': estado,
          'idMunicipio': idMunicipioSeleccionada,
          'tipoEstacion': tipoEstacionSeleccionada,
          'delete': delete,
          'edit': edit,
          'fechaCreacion': fechaActual.toIso8601String(),
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        var dio = Dio();
        final response = await dio.post(
          '$url/estacion/addEstacion',
          data: newDato,
        );

        if (response.statusCode == 201) {
          final responseData = response.data;
          final idEstacion = responseData['idEstacion'];

          setState(() {
            idEstacionSeleccionada = idEstacion;
          });

          _mostrarModal(
              nombreNuevoMunicipioController.text, nombreNuevaEstacion.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Estación añadida correctamente. ID: $idEstacion')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al añadir estación: ${response.data}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ocurrió un error al añadir la estación')),
        );
      }
    }
    nombreNuevaEstacion.clear();
    latitud.clear();
    longitud.clear();
    altura.clear();
  }

  Widget _buildPromotorFields() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mostrarFormularioNuevoMunicipioZ) ...[
              Container(
                height: 70,
                color: const Color.fromARGB(91, 4, 18, 43),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10.0,
                        runSpacing: 5.0,
                        children: [
                          Text(
                            'CREAR DATOS PROMOTOR',
                            style: getTextStyleNormal20(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Seleccione un municipio:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 234, 240, 255),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDropdownMunicipiosZ()),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDropdownZona()),
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
                    onPressed: isButtonDisabledPromotor
                        ? null
                        : () {
                            if (_buildDropdownMunicipiosZ() == null ||
                                zonaSeleccionada == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Debe seleccionar un municipio y una zona antes de continuar.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                isButtonDisabledPromotor = true;
                              });
                              _guardarCambiosPromotor();
                            }
                          },
                    icon:
                        const Icon(Icons.save_as_outlined, color: Colors.white),
                    label: Text(
                      'Añadir Promotor',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (mostrarFormularioNuevoMunicipioZ) ...[
              Column(
                children: [
                  _buildNuevoMunicipioForm(),
                  _buildNuevaZonaForm(),
                ],
              ),
            ],
            if (mostrarFormularioNuevaZona) ...[
              Column(
                children: [
                  _buildNuevaZonaForm(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMunicipiosZ() {
    return Container(
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
          value: municipioSeleccionado != null &&
                  zonasPorMunicipio.keys.contains(municipioSeleccionado)
              ? municipioSeleccionado
              : null,
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
            mostrarFormularioNuevaZona = false;
            setState(() {
              municipioSeleccionado = newValue;
              zonaSeleccionada = null;
              mostrarFormularioNuevoMunicipioZ = (newValue == 'Otro');
              if (newValue != null && zonasPorMunicipio.containsKey(newValue)) {
                var zonasDelMunicipio = zonasPorMunicipio[newValue];
                if (zonasDelMunicipio != null && zonasDelMunicipio.isNotEmpty) {
                  var idMunicipio = zonasDelMunicipio[0]['idMunicipio'];
                  print(zonasDelMunicipio[0]['idMunicipio']);
                  idMunicipioSeleccionada = idMunicipio;
                }
              }
            });
          },
          items: [
            ...zonasPorMunicipio.keys
                .map<DropdownMenuItem<String>>((String municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(
                  municipio,
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            DropdownMenuItem<String>(
              value: 'Otro',
              child: Text(
                'Otro',
                style: GoogleFonts.lexend(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownZona() {
    return Container(
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
          value: zonaSeleccionada != null &&
                  zonasPorMunicipio[municipioSeleccionado]?.any(
                          (zona) => zona['nombreZona'] == zonaSeleccionada) ==
                      true
              ? zonaSeleccionada
              : null,
          hint: Text(
            'Visualice una zona o añada con la opcion "Otro"',
            style: GoogleFonts.lexend(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              zonaSeleccionada = newValue;
              mostrarFormularioNuevaZona = (newValue == 'Otro');
              if (mostrarFormularioNuevaZona) {
                print('Navegar al formulario de nueva zona');
              }

              if (newValue != null &&
                  zonasPorMunicipio[municipioSeleccionado]!
                      .any((zona) => zona['nombreZona'] == newValue)) {
                var zonasDelMunicipio =
                    zonasPorMunicipio[municipioSeleccionado];

                if (zonasDelMunicipio != null && zonasDelMunicipio.isNotEmpty) {
                  var idZona = zonasDelMunicipio[0]['idZona'];
                  idZonaSeleccionada = idZona;
                }
              }
            });
          },
          items: [
            if (zonasPorMunicipio[municipioSeleccionado] != null &&
                !zonasPorMunicipio[municipioSeleccionado]!
                    .any((zonas) => zonas['nombreZona'] == 'Otro'))
              DropdownMenuItem<String>(
                value: 'Otro',
                child: Text(
                  'Otro',
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ...?zonasPorMunicipio[municipioSeleccionado]
                ?.map<DropdownMenuItem<String>>((mapaEstacion) {
              String zona = mapaEstacion['nombreZona'] ?? 'Zona no disponible';
              return DropdownMenuItem<String>(
                value: zona,
                child: Text(
                  zona,
                  style: GoogleFonts.lexend(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNuevaZonaForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            height: 70,
            color: const Color.fromARGB(91, 4, 18, 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 5.0,
                    children: [
                      Text(
                        'CREAR NUEVA ZONA',
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevaZona,
            decoration: getInputDecoration('Nombre de Zona', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: latitud,
            decoration: getInputDecoration('Latitud', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: longitud,
            decoration: getInputDecoration('Longitud', Icons.abc),
            style: const TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
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
                onPressed: isButtonDisabledZona
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledZona = true;
                        });
                        _guardarNuevaZona();
                      },
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Guardar Zona',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNuevaZona() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevaZona.text,
          'latitud': latitud.text,
          'longitud': longitud.text,
          'idMunicipio': idMunicipioSeleccionada,
          'delete': delete,
          'edit': edit,
          'fechaCreacion': fechaActual.toIso8601String(),
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        var dio = Dio();
        final response = await dio.post(
          '$url/zona/addZona',
          data: newDato,
        );

        if (response.statusCode == 201) {
          final responseData = response.data;
          final idZona = responseData['idZona'];

          setState(() {
            idZonaSeleccionada = idZona;
          });

          _mostrarModalZ(
              nombreNuevoMunicipioController.text, nombreNuevaZona.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Zona añadida correctamente. ID: $idZona')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir zona: ${response.data}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error al añadir la zona')),
        );
      }
    }
    nombreNuevaZona.clear();
    latitud.clear();
    longitud.clear();
    altura.clear();
  }

  void _mostrarModalZ(String municipio, String zona) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 3, 50, 112),
          title: const Text(
            'Zona Creada',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'El promotor se añadirá al municipio $municipio y la zona $zona.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _guardarCambiosPromotor();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
