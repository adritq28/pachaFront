import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosPronostico.dart';
import 'package:helvetasfront/model/Fenologia.dart';
import 'package:helvetasfront/url.dart';

class FenologiaService extends ChangeNotifier {
  List<Fenologia> _lista = [];
  List<DatosPronostico> _lista2 = [];
  List<Fenologia> get lista11 => _lista;
  List<DatosPronostico> get lista112 => _lista2;

  String url = Url().apiUrl;
  String ip = Url().ip;
  int _faseActual = 0;
  int get faseActual => _faseActual;

  final Dio dio = Dio();

  Future<List<DatosPronostico>> pronosticoCultivo(int idCultivo) async {
    try {
      final response = await dio.get('$url/datos_pronostico/registro/$idCultivo');
      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data;
        if (jsonData.isEmpty) {
          return [];
        }
        return jsonData.map((item) => DatosPronostico.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener datos del observador');
      }
    } catch (e) {
      throw Exception('Error al obtener pronóstico: $e');
    }
  }

  Future<void> obtenerPronosticosFase(int cultivoId) async {
    try {
      final response = await dio.get('$url/alertas/pronostico_fase/$cultivoId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista2 = data.map((e) => DatosPronostico.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Error al obtener los pronósticos');
      }
    } catch (e) {
      throw Exception('Error al obtener pronósticos de fase: $e');
    }
  }

  Future<void> fase(int cultivoId) async {
    try {
      final response = await dio.get('$url/alertas/fase/$cultivoId');
      if (response.statusCode == 200) {
        final int faseActual = response.data;
        _faseActual = faseActual;
        notifyListeners();
      } else {
        throw Exception('Error al obtener la fase actual');
      }
    } catch (e) {
      throw Exception('Error al obtener la fase: $e');
    }
  }

  Future<void> obtenerFenologia(int idCultivo) async {
    try {
      final response = await dio.get('$url/fenologia/verFenologia/$idCultivo');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista = data.map((e) => Fenologia.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Error al obtener la fenología');
      }
    } catch (e) {
      throw Exception('Error al obtener fenología: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPcpnFase(int cultivoId) async {
    try {
      final response = await dio.get('$url/alertas/pcpnFase/$cultivoId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener datos de pcpnFase');
      }
    } catch (e) {
      throw Exception('Error al obtener pcpnFase: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUltimaAlerta(int cultivoId) async {
    try {
      final response = await dio.get('$url/alertas/ultima/$cultivoId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener la última alerta');
      }
    } catch (e) {
      throw Exception('Error al obtener la última alerta: $e');
    }
  }
}
