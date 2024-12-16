import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/url.dart';

class PromotorService extends ChangeNotifier {
  List<Promotor> _lista = [];
  List<Promotor> get lista11 => _lista;
  String url = Url().apiUrl;
  String ip = Url().ip;

  final Dio dio = Dio();

  Future<String?> addPromotor({
    required int idUsuario,
    required int idMunicipio,
  }) async {
    try {
      final url2 = '$url/promotor/addPromotor';
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'idUsuario': idUsuario,
        'idMunicipio': idMunicipio,
      });

      final response = await dio.post(url2, data: body, options: Options(headers: headers));

      if (response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } catch (e) {
      return 'Error al conectar con el servidor: $e';
    }
  }

  Future<void> getPromotor() async {
    try {
      final response = await dio.get('$url/promotor/lista_promotor');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista = data.map((e) => Promotor.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> obtenerListaZonas(int id) async {
    try {
      final response = await dio.get('$url/promotor/lista_zonas/$id');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _lista = data.map((e) => Promotor.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
