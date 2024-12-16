import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/DatosFechaSiembraScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/ZonaService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';

class FechaSiembraScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;

  const FechaSiembraScreen({super.key,
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
  });

  @override
  FechaSiembraScreenState createState() => FechaSiembraScreenState();
}

class FechaSiembraScreenState extends State<FechaSiembraScreen> {
  List<Map<String, dynamic>> zonas = [];
  Map<String, List<Map<String, dynamic>>> zonasPorMunicipio = {};
  String? municipioSeleccionado;
  String? zonaSeleccionada;
  int? idzonaSeleccionada;
  String url = Url().apiUrl;
  String ip = Url().ip;
  bool isLoading = true;

  final ZonaService zonaService = ZonaService();

  @override
  void initState() {
    super.initState();
    cargarZonas();
  }

  Future<void> cargarZonas() async {
    try {
      final zonasCargadas = await zonaService.fetchZonasFechaS();
      setState(() {
        zonas = zonasCargadas;
        zonasPorMunicipio = zonaService.agruparZonasPorMunicipio(zonas);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar las zonas')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToDatosFechaSiembraScreen() {
    if (idzonaSeleccionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DatosFechaSiembraScreen(
            idZona: idzonaSeleccionada!,
            nombreMunicipio: municipioSeleccionado!,
            nombreZona: zonaSeleccionada!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: widget.idUsuario,estado: PerfilEstado.soloNombreTelefono,),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: widget.idUsuario, estado: PerfilEstado.soloNombreTelefono,),
      ),
      body: FondoWidget(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage("images/47.jpg"),
                      ),
                      const SizedBox(width: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bienvenid@: ${widget.nombre} ${widget.apePat} ${widget.apeMat}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(208, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: zonas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: zonasPorMunicipio.keys.length,
                      itemBuilder: (context, index) {
                        String municipio = zonasPorMunicipio.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      municipioSeleccionado = municipio;
                                      zonaSeleccionada = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 203, 230, 255),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      municipio,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 34, 52, 96),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (municipioSeleccionado != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Seleccione una estación en $municipioSeleccionado:',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 234, 240, 255),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: zonaSeleccionada,
                      hint: const Text(
                        'Seleccione una estación',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 236, 241, 255),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          zonaSeleccionada = newValue;
                          idzonaSeleccionada =
                              zonasPorMunicipio[municipioSeleccionado]!
                                  .firstWhere((element) =>
                                      element['nombreZona'] ==
                                      newValue)['idZona'];
                          navigateToDatosFechaSiembraScreen();
                        });
                      },
                      items: zonasPorMunicipio[municipioSeleccionado]!
                          .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> zona) {
                        return DropdownMenuItem<String>(
                          value: zona['nombreZona'],
                          child: Text(zona['nombreZona']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
                  Footer(),
          ],
          
        ),
        
      ),
      
    );
    
  }
}
