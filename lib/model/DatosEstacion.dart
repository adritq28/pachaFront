

// class DatosEstacion {
//   final int idUsuario;
//   final String nombreMunicipio;
//   final String nombreEstacion;
//   final String tipoEstacion;
//   final String nombreCompleto;
//   final String telefono;
//   final double tempMax;
//   final double tempMin;
//   final double tempAmb;
//   final double pcpn;
//   final double taevap;
//   late DateTime fechaReg = DateTime.now();
//   final String dirViento;
//   final double velViento;
//   final int idEstacion;
//   final bool codTipoEstacion;
//   final bool delete;

//   DatosEstacion({
//     required this.idUsuario,
//     required this.nombreMunicipio,
//     required this.nombreEstacion,
//     required this.tipoEstacion,
//     required this.nombreCompleto,
//     required this.telefono,
//     required this.tempMax,
//     required this.tempMin,
//     required this.tempAmb,
//     required this.pcpn,
//     required this.taevap,
//     required this.fechaReg,
//     required this.dirViento,
//     required this.velViento,
//     required this.idEstacion,
//     required this.codTipoEstacion,
//     required this.delete,
//   });

//   factory DatosEstacion.fromJson(Map<String, dynamic> json) {
//     return DatosEstacion(
//       idUsuario: json['idUsuario'] ?? 0,
//       nombreMunicipio: (json['nombreMunicipio'] ?? ''),
//       nombreEstacion: (json['nombreEstacion'] ?? ''),
//       tipoEstacion: (json['tipoEstacion'] ?? ''),
//       nombreCompleto: (json['nombreCompleto'] ?? ''),
//       telefono: (json['telefono'] ?? ''),
//       tempMax: (json['tempMax'] ?? 0.0).toDouble(),
//       tempMin: (json['tempMin'] ?? 0.0).toDouble(),
//       tempAmb: (json['tempAmb'] ?? 0.0).toDouble(),
//       pcpn: (json['pcpn'] ?? 0.0).toDouble(),
//       taevap: (json['taevap'] ?? 0.0).toDouble(),
//       fechaReg: json['fechaReg'] != null
//            ? DateTime.parse(json['fechaReg'])
//            : DateTime.now(),
//       dirViento: (json['dirViento'] ?? ''),
//       velViento: (json['velViento'] ?? 0.0).toDouble(),
//       idEstacion: json['idEstacion'] ?? 0,
//       codTipoEstacion: json['codTipoEstacion'] != null ? json['codTipoEstacion'] == true : false,
//       delete: json['delete'] != null ? json['delete'] == true : false,

//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'idUsuario': idUsuario,
//         'nombreMunucipio': nombreMunicipio,
//         'nombreEstacion': nombreEstacion,
//         'tipoEstacion': tipoEstacion,
//         'nombreCompleto': nombreCompleto,
//         'telefono': telefono,
//         'tempMax': tempMax,
//         'tempMin': tempMin,
//         'tempAmb': tempAmb,
//         'pcpn': pcpn,
//         'taevap': taevap,
//          'fechaReg': fechaReg
//              .toUtc()
//              .toIso8601String(),
//         'dirViento': dirViento,
//         'velViento': velViento,
//         'idEstacion': idEstacion,
//         'codTipoEstacion': codTipoEstacion,
//         //'edit': edit,
//         'delete': delete,
//       };

//   String toStringDatosEstacion() {
//     return "DatosEstacion [idUsuario.toString()" +
//         ", nombreMunicipio=" +
//         nombreMunicipio +
//         ", nombreEstacion=" +
//         nombreEstacion +
//         ", tipoEstacion=" +
//         tipoEstacion +
//         ", nombreCompleto=" +
//         nombreCompleto +
//         ", telefono=" +
//         telefono +
//         ", fechaReg=" +
//         fechaReg.toString() +
//         ", tempMax=" +
//         tempMax.toString() +
//         ", tempMin=" +
//         tempMin.toString() +
//         ", tempAmb=" +
//         tempAmb.toString() +
//         ", pcpn=" +
//         pcpn.toString() +
//         ", taevap=" +
//         taevap.toString() +
//         ", dirViento=" +
//         dirViento.toString() +
//         ", velViento=" +
//         velViento.toString() +
//         ", idEstacion=" +
//         idEstacion.toString() +
//         ", codTipoEstacion=" +
//         codTipoEstacion.toString() +
//         ", delete=" +
//         delete.toString() +
//         "]";
//   }
// }
