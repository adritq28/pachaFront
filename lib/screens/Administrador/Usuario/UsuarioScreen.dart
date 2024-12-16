import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/AnadirUsuarioScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/EditarUsuarioScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/VisualizarUsuarioScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';


class UsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;
  final String imagen;

  const UsuarioScreen({super.key,
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.imagen,
  });

  @override
  UsuarioScreenState createState() => UsuarioScreenState();
}

class UsuarioScreenState extends State<UsuarioScreen> {
  List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
  String url = Url().apiUrl;
  String ip = Url().ip;
  String? rolSeleccionado;
  final List<String> roles = ["ADMIN", "OBSERVADOR", "PROMOTOR", "TODOS"];

  @override
  void initState() {
    super.initState();
    fetchDatosUsuario();
  }

  void reloadData() {
    fetchDatosUsuario();
  }

  Future<void> fetchDatosUsuario() async {
  setState(() {
    isLoading = true;
  });

  try {
    final dio = Dio();
    final response = await dio.get('$url/usuario/lista_usuario');

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> fetchedData =
          List<Map<String, dynamic>>.from(response.data);

      setState(() {
        datos = fetchedData;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load datos de usuario');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    throw Exception('Failed to load datos de usuario: $e');
  }
}

  void editarDato(int index) async {
    try {
      Map<String, dynamic> dato = datos[index];

      bool cambiosGuardados = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditarUsuarioScreen(
            idUsuario: dato['idUsuario'] ??
                0,
            nombre: dato['nombre'] ?? '',
            imagen: dato['imagen'] ??
                'default_image.png',
            apePat: dato['apePat'] ?? '',
            apeMat: dato['apeMat'] ?? '',
            ci: dato['ci'] ?? '',
            admin:
                dato['admin'] ?? false,
            telefono: dato['telefono'] ?? '',
            rol: dato['rol'] ?? '',
            estado: dato['estado'] ?? false,
            password: dato['password'] ?? '',
          ),
        ),
      );

      if (cambiosGuardados == true) {
        fetchDatosUsuario();
      }
    } catch (e) {
      print('Error al editar dato: $e');
    }
  }

  void visualizarDato(int index) {
    try {
      Map<String, dynamic> dato = datos[index];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarUsuarioScreen(
              idUsuario: dato['idUsuario'] ?? 0,
              nombre: dato['nombre'] ?? '',
              imagen: dato['imagen'] ?? 'default_image.png',
              apePat: dato['apePat'] ?? '',
              apeMat: dato['apeMat'] ?? '',
              ci: dato['ci'] ?? '',
              admin: dato['admin'] ?? false,
              telefono: dato['telefono'] ?? '',
              rol: dato['rol'] ?? ''),
        ),
      );
      print('Visualizar dato en la posición $index');
    } catch (e) {
      print('Error al intentar visualizar el dato en la posición $index: $e');
    }
  }

  void eliminarDato(int index) async {
  Map<String, dynamic> dato = datos[index];
  int idUsuario = dato['idUsuario'];

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

              final dio = Dio();
              final url2 = '$url/usuario/eliminar/$idUsuario';
              final headers = {'Content-Type': 'application/json'};

              try {
                final response = await dio.delete(url2, options: Options(headers: headers));

                if (response.statusCode == 200) {
                  setState(() {
                    datos.removeAt(index);
                    datos = datos
                        .where((dato) => dato['idUsuario'] != idUsuario)
                        .toList();
                  });
                  print('Dato eliminado correctamente');
                } else {
                  print('Error al intentar eliminar el dato');
                }
              } catch (e) {
                print('Error al intentar eliminar el dato: $e');
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
      builder: (context) => AnadirUsuarioScreen(idUsuario: widget.idUsuario),
    ),
  );

  if (result == true) {
    fetchDatosUsuario();
  }
}


  String obtenerRol(String rol) {
    switch (rol) {
      case '1':
        return "ADMIN";
      case '2':
        return "OBSERVADOR";
      case '3':
        return "PROMOTOR";
      default:
        return "DESCONOCIDO";
    }
  }

  List<Map<String, dynamic>> filtrarDatosPorRol() {
    if (rolSeleccionado == null || rolSeleccionado == "TODOS") {
      return datos;
    } else {
      return datos
          .where((dato) => obtenerRol(dato['rol']) == rolSeleccionado)
          .toList();
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
                  Container(
                    height: 70,
                    color: const Color.fromARGB(91, 4, 18, 43),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("images/${widget.imagen}"),
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
                              Text(
                                  '| ${widget.nombre} ${widget.apePat} ${widget.apeMat}',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      dropdownColor: const Color.fromARGB(255, 3, 50, 112),
                      hint: Text(
                        'Selecciona un rol',
                        style: GoogleFonts.lexend(
                          textStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      value: rolSeleccionado,
                      items: roles.map((String rol) {
                        return DropdownMenuItem<String>(
                          value: rol,
                          child: Text(rol, style: GoogleFonts.lexend(
                                    textStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15.0,
                                    ),
                                  ),),
                        );
                      }).toList(),
                      onChanged: (String? nuevoRol) {
                        setState(() {
                          rolSeleccionado = nuevoRol;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextButton.icon(
                          onPressed: anadirDato,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Añadir',
                            style: GoogleFonts.lexend(
                              textStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 142, 146, 143),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowHeight: 60,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Id Usuario',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Imagen',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ap. Paterno',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ap. Materno',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Rol',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Telefono',
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
                                rows: filtrarDatosPorRol().map((dato) {
                                  int index = datos.indexOf(dato);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          dato['idUsuario'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        dato['imagen'] != null
                                            ? Image.network(
                                                '$url/usuario/images/${dato['imagen']}',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.white,
                                                  );
                                                },
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white,
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
                                          dato['apePat'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['apeMat'] != null
                                              ? dato['apeMat'].toString()
                                              : "",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['ci'].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          obtenerRol(dato[
                                              'rol']),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          dato['telefono'].toString(),
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
