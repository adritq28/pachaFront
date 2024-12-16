import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/url.dart';

class ZonaService extends ChangeNotifier {
  String url = Url().apiUrl;
  String ip = Url().ip;
  final Dio dio = Dio();

  Future<List<Map<String, dynamic>>> fetchZonas(int idZona) async {
    try {
      final response = await dio.get('$url/cultivos/lista_datos_cultivo/$idZona');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al cargar datos meteorológicos');
      }
    } catch (e) {
      throw Exception('Error al cargar zonas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchZonasFechaS() async {
    try {
      final response = await dio.get('$url/datos_pronostico/lista_zonas');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load zonas');
      }
    } catch (e) {
      print('Error al cargar las zonas: $e');
      throw Exception('Error de red o decodificación');
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparZonasPorMunicipio(List<Map<String, dynamic>> zonas) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var zona in zonas) {
      if (!agrupadas.containsKey(zona['nombreMunicipio'])) {
        agrupadas[zona['nombreMunicipio']] = [];
      }
      agrupadas[zona['nombreMunicipio']]!.add(zona);
    }
    return agrupadas;
  }
}
