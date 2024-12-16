import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Estacion.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';

class EstacionService extends ChangeNotifier {

  List<Municipio> _lista4 = [];
  List<Municipio> get lista114 => _lista4;

  List<Estacion> _lista5 = [];
  List<Estacion> get lista115 => _lista5;

  String url = Url().apiUrl;
  String ip = Url().ip;

  Dio dio = Dio();

  Future<void> guardarDato(
    BuildContext context,
    GlobalKey<FormState> formKey,
    int idEstacion,
    String url,
    TextEditingController tempMaxController,
    TextEditingController tempMinController,
    TextEditingController pcpnController,
    TextEditingController fechaRegController,
    TextEditingController tempAmbController,
    TextEditingController dirVientoController,
    TextEditingController velVientoController,
    TextEditingController taevapController,
  ) async {
    if (formKey.currentState!.validate()) {
      final newDato = {
        'idEstacion': idEstacion,
        'tempMax': tempMaxController.text.isEmpty
            ? null
            : double.parse(tempMaxController.text),
        'tempMin': tempMinController.text.isEmpty
            ? null
            : double.parse(tempMinController.text),
        'pcpn': pcpnController.text.isEmpty
            ? null
            : double.parse(pcpnController.text),
        'tempAmb': tempAmbController.text.isEmpty
            ? null
            : double.parse(tempAmbController.text),
        'dirViento': dirVientoController.text,
        'velViento': velVientoController.text.isEmpty
            ? null
            : double.parse(velVientoController.text),
        'taevap': taevapController.text.isEmpty
            ? null
            : double.parse(taevapController.text),
        'fechaReg':
            fechaRegController.text.isEmpty ? null : fechaRegController.text,
      };

      try {
        final response = await dio.post(
          '$url/datosEstacion/addDatosEstacion',
          data: newDato,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dato añadido correctamente')),
          );
          Navigator.pop(context, true);
        } else {
          final errorMessage = response.data;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir dato: $errorMessage')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> guardarCambios({
    required int idEstacion,
    required double tempMax,
    required double tempMin,
    required double pcpn,
    required double tempAmb,
    required String dirViento,
    required double velViento,
    required double taevap,
    String? fechaReg,
  }) async {
    try {
      final data = {
        'idDatosEst': idEstacion,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'pcpn': pcpn,
        'tempAmb': tempAmb,
        'dirViento': dirViento,
        'velViento': velViento,
        'taevap': taevap,
        'fechaReg': fechaReg,
      };

      final response = await dio.post(
        '$url/estacion/editar',
        data: data,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDatosMeteorologico(
      int idEstacion) async {
    try {
      final response = await dio.get(
        '$url/estacion/lista_datos_meteorologica/$idEstacion',
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to fetch datos meteorologicos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEstacion() async {
    try {
      final response = await dio.get(
        '$url/estacion/lista_meteorologica',
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load estaciones');
      }
    } catch (e) {
      print('Error al cargar las estaciones: $e');
      throw Exception('Error de red o decodificación');
    }
  }

  Future<String?> obtenerPassword(int idUsuario) async {
    final response = await dio.get('$url/usuario/password/$idUsuario');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Error al obtener la contraseña');
    }
  }

  Future<bool> validarContrasena(
      String contrasenaIngresada, int idUsuario) async {
    try {
      final password = await obtenerPassword(idUsuario);
      return contrasenaIngresada == password;
    } catch (e) {
      print('Error al validar la contraseña: $e');
      return false;
    }
  }

  Future<List<Estacion>> getEstacion(int id) async {
    final response = await dio.get('$url/estacion/verEstaciones/$id');

    if (response.statusCode == 200) {
      List<dynamic> jsonData = response.data;
      _lista5 = jsonData.map((e) => Estacion.fromJson(e)).toList();
      notifyListeners();
      if (jsonData.isEmpty) {
        return [];
      }
      return _lista5;
    } else {
      throw Exception('Error al obtener datos de la estación');
    }
  }

  Future<void> actualizarUltimoAcceso(int idUsuario) async {
    try {
      final response = await dio.put(
        '$url/usuario/actualizarUltimoAcceso/$idUsuario',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print('Último acceso actualizado correctamente');
      } else {
        print('Error al actualizar último acceso: ${response.data}');
      }
    } catch (error) {
      print('Error en la petición: $error');
    }
  }

  Future<void> getMunicipio2() async {
    try {
      final response = await dio.get('$url/zona/vermunicipios');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista4 = data.map((e) => Municipio.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load municipios');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
