import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';

class MunicipioService extends ChangeNotifier {
  List<Municipio> _lista = [];
  List<Municipio> get lista11 => _lista;

  String url = Url().apiUrl;
  String ip = Url().ip;

  final Dio dio = Dio();

  Future<void> obtenerZonas(int id) async {
    try {
      final response = await dio.get('$url/municipio/zona/$id');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista = data.map((e) => Municipio.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load zonas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
