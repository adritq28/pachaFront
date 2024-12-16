
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

Future<void> downloadExcelMobile(List<int> fileBytes, 
String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    Share.shareFiles([file.path], text: 'Datos Hidrológicos');
  } catch (e) {
    print('Error al guardar el archivo: $e');
  }
}


Future<void> downloadExcelMobile2(List<int> fileBytes,
String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);
    Share.shareFiles([file.path], text: 'Umbrales');
  } catch (e) {
    print('Error al guardar el archivo: $e');
  }
}


