import 'package:flutter/material.dart';

class DatosEstacionHidrologica with ChangeNotifier {
  double _limnimetro = 0;
  String _fechaReg = '';

  double get limnimetro => _limnimetro;
  String get fechaReg => _fechaReg;

  void setLimnimetro(double value) {
    _limnimetro = value;
    notifyListeners();
  }

  void setFechaReg(String value) {
    _fechaReg = value;
    notifyListeners();
  }

  bool validateForm() {
    return limnimetro > 0 && _fechaReg.isNotEmpty;
  }

}
