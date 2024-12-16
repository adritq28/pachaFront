import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/UsuarioEstacion.dart';
import 'package:helvetasfront/screens/Administrador/AdminScreen.dart';
import 'package:helvetasfront/url.dart';

class UsuarioService extends ChangeNotifier {
  List<UsuarioEstacion> _lista = [];
  List<UsuarioEstacion> get lista11 => _lista;
  String url = Url().apiUrl;
  String ip = Url().ip;
  final Dio dio = Dio();
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> get usuarios => _usuarios;

  Future<Map<String, dynamic>> _handleResponse(Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': response.data};
    } else {
      return {'success': false, 'error': response.data};
    }
  }

  Future<Map<String, dynamic>> guardarUsuario({
    required String? nombre,
    required String? apePat,
    required String? apeMat,
    required String? telefono,
    required String? ci,
    required String? correoElectronico,
    required String? rol,
    required bool estado,
    required bool delete,
    required bool edit,
    String? imageName,
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    try {
      DateTime fechaActual = DateTime.now();
      String nombreUsuarioGenerado = '';
      if (nombre != null && apePat != null && apePat.isNotEmpty) {
        nombreUsuarioGenerado =
            '$nombre${apePat.substring(0, 2)}'.toLowerCase();
      }
      print(imageName);
      final formData = FormData.fromMap({
        'nombreUsuario': nombreUsuarioGenerado,
        'nombre': nombre,
        'apePat': apePat,
        'apeMat': apeMat,
        'telefono': telefono,
        'ci': ci,
        'password': ci,
        'fechaCreacion': fechaActual.toIso8601String(),
        'ultimoAcceso': fechaActual.toIso8601String(),
        'estado': estado,
        'rol': rol,
        'delete': delete,
        'edit': edit,
        'imagen': imageName,
        'correoElectronico': correoElectronico,
        if (imageBytes != null)
          'imagenArchivo': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName ?? 'uploaded_image',
          ),
        if (imagePath != null)
          'imagenArchivo': await MultipartFile.fromFile(
            imagePath,
            filename: imageName,
          ),
      });

      final response = await dio.post(
        '$url/usuario/addUsuario',
        data: formData,
      );

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Ocurrió un error al guardar el usuario: $e'
      };
    }
  }

  Future<void> fetchDatosUsuario() async {
    try {
      final response = await dio.get('$url/usuario/lista_usuario');
      if (response.statusCode == 200) {
        _usuarios = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
      } else {
        throw Exception('Failed to load datos de usuario');
      }
    } catch (e) {
      throw Exception('Error al obtener datos de usuario: $e');
    }
  }

  Future<void> getUsuario() async {
    try {
      final response = await dio.get('$url/usuario/verusuarios');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista = data.map((e) => UsuarioEstacion.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> login(
    String nombreUsuario,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await dio.post(
        '$url/login',
        data: {
          'username': nombreUsuario,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = response.data;
        if (userDetails.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminScreen(
                idUsuario: userDetails['idUsuario'],
                nombre: userDetails['nombre'],
                apeMat: userDetails['apeMat'],
                apePat: userDetails['apePat'],
                imagen: userDetails['imagen'],
              ),
            ),
          );

          return {'success': true, 'idUsuario': userDetails['idUsuario']};
        } else {
          _showDialog(context, 'Error de autenticación',
              'No se encontraron detalles de usuario.');
          return {'success': false};
        }
      } else {
        _showDialog(context, 'Error de autenticación',
            'Usuario no encontrado o credenciales incorrectas.');
        return {'success': false};
      }
    } catch (e) {
      _showDialog(context, 'Error de red',
          'Hubo un problema al conectar con el servidor.');
      return {'success': false};
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
