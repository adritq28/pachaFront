import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Cultivo.dart';
import 'package:helvetasfront/model/DatosEstacionHidrologica.dart';
import 'package:helvetasfront/screens/LoginScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsuarioService()),
        ChangeNotifierProvider(create: (context) => EstacionService()),
        ChangeNotifierProvider(create: (context) => CultivoFormState()),
        ChangeNotifierProvider(create: (context) => DatosEstacionHidrologica()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pachayatiña',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
