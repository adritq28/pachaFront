import 'package:flutter/material.dart';


class CultivoFormState with ChangeNotifier {
  String _nombre = '';
  String _tipo = '';
  String _fechaSiembra = '';

  String get nombre => _nombre;
  String get tipo => _tipo;
  String get fechaSiembra => _fechaSiembra;

  void setNombre(String nombre) {
    _nombre = nombre;
    notifyListeners();
  }

  void setTipo(String tipo) {
    _tipo = tipo;
    notifyListeners();
  }

  void setFechaSiembra(String fecha) {
    _fechaSiembra = fecha;
    notifyListeners();
  }
}
