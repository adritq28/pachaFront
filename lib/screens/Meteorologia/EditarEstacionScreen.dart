import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';

class EditarEstacionScreen extends StatefulWidget {
  final int estacionId;
  final int idUsuario;
  final String nombreMunicipio;
  final double tempMax;
  final double tempMin;
  final double tempAmb;
  final double pcpn;
  final double taevap;
  final String dirViento;
  final double velViento;
  final int idEstacion;

  const EditarEstacionScreen({super.key,
    required this.estacionId,
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.tempMax,
    required this.tempMin,
    required this.tempAmb,
    required this.pcpn,
    required this.taevap,
    required this.dirViento,
    required this.velViento,
    required this.idEstacion,
  });

  @override
  EditarEstacionScreenState createState() => EditarEstacionScreenState();
}

class EditarEstacionScreenState extends State<EditarEstacionScreen> {
  TextEditingController idUsuario = TextEditingController();
  TextEditingController nombreMunicipio = TextEditingController();
  TextEditingController tempMax = TextEditingController();
  TextEditingController tempMin = TextEditingController();
  TextEditingController tempAmb = TextEditingController();
  TextEditingController pcpn = TextEditingController();
  TextEditingController taevap = TextEditingController();
  TextEditingController dirViento = TextEditingController();
  TextEditingController velViento = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  

  @override
  void initState() {
    super.initState();
    idUsuario.text = widget.idUsuario.toString();
    nombreMunicipio.text = widget.tempMax.toString();
    tempMax.text = widget.tempMax.toString();
    tempMin.text = widget.tempMin.toString();
    tempAmb.text = widget.tempAmb.toString();
    pcpn.text = widget.pcpn.toString();
    taevap.text = widget.taevap.toString();
    dirViento.text = widget.dirViento.toString();
    velViento.text = widget.velViento.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, showProfileButton: true, idUsuario: 0,
        estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: tempMax,
              decoration: const InputDecoration(labelText: 'tempMax'),
            ),
            TextFormField(
              controller: tempMin,
              decoration: const InputDecoration(labelText: 'Temperatura Mínima'),
            ),
            TextFormField(
              controller: tempAmb,
              decoration: const InputDecoration(labelText: 'tempAmb'),
            ),
            TextFormField(
              controller: pcpn,
              decoration: const InputDecoration(labelText: 'pcpn'),
            ),
            TextFormField(
              controller: taevap,
              decoration: const InputDecoration(labelText: 'taevap'),
            ),
            TextFormField(
              controller: dirViento,
              decoration: const InputDecoration(labelText: 'Dir viento'),
            ),
            TextFormField(
              controller: velViento,
              decoration: const InputDecoration(labelText: 'Vel Viento'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                actualizarDatosEstacion();
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
        
      ),
      
    );
  }

  Future<void> actualizarDatosEstacion() async {
  final String url2 =
      '$url/datosEstacion/updateDatosEstacion/${widget.estacionId}';

  Map<String, dynamic> datosActualizados = {
    "idUsuario": idUsuario.text,
    "nombreMunicipio": nombreMunicipio.text,
    "tempMax": tempMax.text,
    "tempMin": tempMin.text,
    "tempAmb": tempAmb.text,
    "pcpn": pcpn.text,
    "taevap": taevap.text,
    "dirViento": dirViento.text,
    "velViento": velViento.text,
  };

  try {
    final dio = Dio();
    final response = await dio.put(
      url2,
      data: datosActualizados,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Actualizado con éxito'),
            content: const Text(
                'Los datos de la estación han sido actualizados correctamente.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } else {
      print('Error al actualizar los datos de la estación: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error al realizar la solicitud PUT: $e');
  }
}

}
