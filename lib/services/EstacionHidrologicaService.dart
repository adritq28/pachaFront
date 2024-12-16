import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosEstacionHidrologica.dart';
import 'package:helvetasfront/url.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> guardarDato(
  BuildContext context,
  int idEstacion,
  String url,
  double? limnimetro,
  String fechaReg,
) async {
  final formState =
      Provider.of<DatosEstacionHidrologica>(context, listen: false);

  if (formState.limnimetro !=null && formState.fechaReg.isNotEmpty) {
    final String fechaReg =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());
    final newDato = {
      'idEstacion': idEstacion,
      'limnimetro': limnimetro,
      'fechaReg': fechaReg,
    };

    try {
      final dio = Dio();
      final response = await dio.post(
        '$url/datosHidrologica/addDatosHidrologica',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: newDato,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dato añadido correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir dato: ${response.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: ${e.toString()}')),
      );
    }
  }
}

class EstacionHidrologicaService extends ChangeNotifier {
  final String url = Url().apiUrl;
  final String ip = Url().ip;

  final Dio dio = Dio();
  TextEditingController limnimetroController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  

  void resetMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchDatosHidrologico(
      int idEstacion) async {
    try {
      final response = await dio.get(
        '$url/estacion/lista_datos_hidrologica/$idEstacion',
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to fetch datos hidrológicos: $e');
    }
  }

  Future<bool> guardarCambios({
    required int idHidrologica,
    required double limnimetro,
    String? fechaReg,
  }) async {
    try {
      final response = await dio.post(
        '$url/estacion/editarHidrologica',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'idHidrologica': idHidrologica,
          'limnimetro': limnimetro,
          'fechaReg': fechaReg ?? '',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEstacion() async {
    try {
      final response = await dio.get('$url/estacion/lista_hidrologica');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al cargar estaciones: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error al cargar estaciones: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    return estaciones.fold({}, (map, estacion) {
      final municipio = estacion['nombreMunicipio'] ?? 'Desconocido';
      if (!map.containsKey(municipio)) {
        map[municipio] = [];
      }
      map[municipio]!.add(estacion);
      return map;
    });
  }
}
