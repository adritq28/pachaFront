import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Cultivo.dart';
import 'package:helvetasfront/url.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> guardarDato(
  BuildContext context,
  String url,
  int idZona,
) async {
  final formState = Provider.of<CultivoFormState>(context, listen: false);

  if (formState.nombre.isNotEmpty && formState.tipo.isNotEmpty) {
    final String fechaReg =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());

    final newDato = {
      'idZona': idZona,
      'nombre': formState.nombre,
      'tipo': formState.tipo,
      'fechaSiembra': formState.fechaSiembra.isEmpty
          ? null
          : formState.fechaSiembra,
      'fechaReg': fechaReg,
    };

    try {
      final dio = Dio();
      final response = await dio.post(
        '$url/cultivos/addCultivo',
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
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, complete todos los campos')),
    );
  }
}



class CultivoService extends ChangeNotifier{
  String url = Url().apiUrl;
  String ip = Url().ip;

  final Dio dio = Dio();
  final int idCultivo;
  TextEditingController nombreController = TextEditingController();
  TextEditingController fechaSiembraController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();
  TextEditingController tipoController = TextEditingController();

  CultivoService({
    required this.idCultivo,
    required String nombre,
    required String fechaSiembra,
    required String fechaReg,
    required String tipo,
  }) {
    nombreController.text = nombre;
    fechaSiembraController.text = fechaSiembra;
    fechaRegController.text = fechaReg;
    tipoController.text = tipo;
  }

  Future<bool> guardarCambios() async {
  final body = {
    'idCultivo': idCultivo,
    'nombre': nombreController.text.isEmpty ? null : nombreController.text,
    'fechaSiembra': fechaSiembraController.text.isEmpty ? null : fechaSiembraController.text,
    'fechaReg': fechaRegController.text.isEmpty ? null : fechaRegController.text,
    'tipo': tipoController.text.isEmpty ? null : tipoController.text,
  };

  try {
    final response = await dio.post(
      '$url/cultivos/editar',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: body,
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error al guardar cambios: ${e.toString()}');
    return false;
  }
}

}

