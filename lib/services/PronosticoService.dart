import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/url.dart';

Future<void> guardarDato(
  BuildContext context,
  GlobalKey<FormState> formKey,
  String url,
  int idZona,
  TextEditingController tempMax,
  TextEditingController tempMin,
  TextEditingController pcpn,
  TextEditingController fechaReg,
) async {
  if (formKey.currentState!.validate()) {
    final newDato = {
      'idZona': idZona,
      'tempMax': tempMax.text.isEmpty
          ? null
          : double.parse(tempMax.text),
      'tempMin': tempMin.text.isEmpty
          ? null
          : double.parse(tempMin.text),
      'pcpn': pcpn.text.isEmpty
          ? null
          : double.parse(pcpn.text),
      'fecha': fechaReg.text.isEmpty ? null : fechaReg.text,
    };

    final dio = Dio();

    try {
      final response = await dio.post(
        '$url/datos_pronostico/addDatosPronostico',
        data: newDato,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dato añadido correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = response.data.toString();
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

class PronosticoService extends ChangeNotifier {
  String url = Url().apiUrl;
  String ip = Url().ip;

  final Dio _dio = Dio();

  Future<bool> guardarCambios({
    required int idPronostico,
    required double tempMax,
    required double tempMin,
    required double pcpn,
    String? fecha,
  }) async {
    try {
      final data = {
        'idPronostico': idPronostico,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'pcpn': pcpn,
        'fecha': fecha,
      };

      final response = await _dio.post(
        '$url/datos_pronostico/editar',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
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

  Future<List<Map<String, dynamic>>> fetchZona(int idZona) async {
    try {
      final response = await _dio.get(
        '$url/datos_pronostico/lista_datos_zona/$idZona',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to fetch zonas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> zonaID() async {
    try {
      final response = await _dio.get('$url/datos_pronostico/lista_zonas');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load zonas');
      }
    } catch (e) {
      print('Error al cargar las estacion: $e');
      throw Exception('Error de red o decodificación');
    }
  }
}
