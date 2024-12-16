// class Zona {
//   final int idZona;
//   final String nombre;
//   final int idMunicipio;
//   final double latitud;
//   final double longitud;

//   Zona({
//     required this.idZona,
//     required this.nombre,
//     required this.idMunicipio,
//     required this.latitud,
//     required this.longitud
//   });

//   factory Zona.fromJson(Map<String, dynamic> json) {
//     return Zona(
//       idZona: json['idZona'] ?? 0,
//       nombre: (json['nombre'] ?? ''),
//       idMunicipio: json['idMunicipio'] ?? 0,
//       longitud: (json['longitud'] ?? 0.0).toDouble(),
//       latitud: (json['latitud'] ?? 0.0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'idZona': idZona,
//         'nombre': nombre,
//         'idMunicipio': idMunicipio,
//       };

//   String toStringZona() {
//     return "Zona ["+ idZona.toString() +
//         ", nombre=" +
//         nombre +
//         ", idMunicipio=" +
//         idMunicipio.toString() +
//         "]";
//   }
// }