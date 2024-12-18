import 'package:flutter/material.dart';

class ComunidadesListWidget extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> Function(int idZona) fetchComunidades;
  final int idZona;

  const ComunidadesListWidget({
    super.key,
    required this.fetchComunidades,
    required this.idZona,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchComunidades(idZona),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No hay comunidades disponibles.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else {
          List<Map<String, dynamic>> comunidades =
              List<Map<String, dynamic>>.from(snapshot.data!);

          List<String> nombresComunidades = comunidades
              .map((comunidad) => comunidad['nombreComunidad'] ?? 'Sin nombre')
              .toList()
              .cast<String>();

          List<Color> cardColors = [
            const Color.fromARGB(120, 30, 136, 229),
            const Color.fromARGB(120, 75, 169, 124),
            const Color.fromARGB(120, 199, 119, 16),
            const Color.fromARGB(120, 111, 12, 231),
            const Color.fromARGB(120, 7, 170, 230),
          ];

          return Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Comunidades:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nombresComunidades.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Card(
                            elevation: 4,
                            color: cardColors[index % cardColors.length],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                      'images/76.png',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    nombresComunidades[index].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
