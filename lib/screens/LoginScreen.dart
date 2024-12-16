import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Invitados/MunicipiosScreen.dart';
import 'package:helvetasfront/screens/Meteorologia/ListaUsuarioEstacionScreen.dart';
import 'package:helvetasfront/screens/Promotor/PromotorScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/fondo.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const LoginScreen());
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final EstacionService _datosService3 = EstacionService();
  late UsuarioService miModelo4;

  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> changePassword(
      BuildContext context, String email, String newPassword) async {
    if (newPassword.length < 6) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Contraseña muy corta'),
          content:
              const Text('La contraseña debe tener al menos 6 caracteres.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1abc9c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }

    Dio dio = Dio();
    final url2 = '$url/email/change-password';

    try {
      Response response = await dio.post(
        url2,
        data: {
          'correoElectronico': email,
          'newPassword': newPassword,
        },
        options: Options(
    headers: {"Content-Type": "application/json"},
  ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar la contraseña')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la conexión')),
      );
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
  }

  Future<bool> sendRecoveryEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Correo electrónico vacío'),
          content:
              const Text('Por favor, ingresa un correo electrónico válido.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1abc9c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }

    if (!_isValidEmail(email)) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Correo electrónico inválido'),
          content:
              const Text('Por favor, ingresa un correo electrónico válido.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1abc9c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }

    Dio dio = Dio();

try {
  Response response = await dio.post(
    '$url/email/send',
    data: {'email': email},
    options: Options(
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    ),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al enviar el correo electrónico')),
    );
    return false;
  }
} catch (e) {
  print('Error al enviar la solicitud: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Error en la conexión')),
  );
  return false;
}

  }

  Future<bool> verifyRecoveryCode(
      BuildContext context, String email, String code) async {
    Dio dio = Dio();
    final url2 = '$url/email/validate-code';

    try {
      Response response = await dio.post(
        url2,
        data: {'email': email, 'code': code},
        options: Options(
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
    ),
      );

      print('Respuesta del servidor: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data.contains("Código válido")) {
          return true;
        } else {
          if (!_isDialogShown) {
            _isDialogShown = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Código Incorrecto'),
                  content: const Text(
                      'El código ingresado es incorrecto. Inténtalo nuevamente.'),
                  actions: <Widget>[
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1abc9c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('OK',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _isDialogShown = false;
                      },
                    ),
                  ],
                );
              },
            );
          }
          return false;
        }
      } else {
        print('Error en la solicitud: Código HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al verificar el código: $e');
      return false;
    }
  }

  bool _isDialogShown = false;

  String? _emailTemporal;

  void _showPasswordDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool _obscureText = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFf0f0f0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Ingrese sus credenciales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: Color(0xFF34495e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 400,
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        labelStyle: const TextStyle(
                            color: Colors.blueGrey, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 12.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        labelStyle: const TextStyle(
                            color: Colors.blueGrey, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 12.0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _showForgotPasswordDialog(context);
                      },
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd35400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1abc9c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 20),
                      ),
                      child: const Text('OK',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () async {
                        String nombreUsuario = usernameController.text;
                        String password = passwordController.text;
                        Map<String, dynamic> resultadoLogin =
                            await Provider.of<UsuarioService>(context,
                                    listen: false)
                                .login(nombreUsuario, password, context);

                        if (resultadoLogin['success']) {
                          int idUsuario = resultadoLogin['idUsuario'];
                          await _datosService3
                              .actualizarUltimoAcceso(idUsuario);
                        }
                        usernameController.clear();
                        passwordController.clear();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;
    bool showCodeInput = false;

    void checkRecoveryCode() async {
      final email = emailController.text.trim();
      final code = codeController.text.trim();

      bool isValid = await verifyRecoveryCode(context, email, code);

      print('Correo: $email');
      print('Código ingresado: $code');
      print('¿Código válido?: $isValid');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFf0f0f0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Recuperación de contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0xFF34495e),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(hintText: 'Correo Electrónico'),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (showCodeInput)
                    TextField(
                      controller: codeController,
                      decoration:
                          const InputDecoration(hintText: 'Código recibido'),
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd35400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!showCodeInput) {
                      String email = emailController.text.trim();
                      setState(() {
                        isLoading = true;
                      });

                      bool success = await sendRecoveryEmail(context, email);

                      setState(() {
                        isLoading = false;
                        showCodeInput = success;
                      });

                      if (success) {
                        _emailTemporal = email;
                      } else {
                        // scaffoldMessengerKey.currentState?.showSnackBar(
                        //   SnackBar(
                        //       content: Text('Error al enviar el correo')),
                        // );
                      }
                    } else {
                      String code = codeController.text.trim();
                      if (code.isEmpty) {
                        // scaffoldMessengerKey.currentState?.showSnackBar(
                        //   SnackBar(
                        //       content: Text('Por favor, ingresa el código')),
                        // );
                      } else {
                        bool verified = await verifyRecoveryCode(
                            context, emailController.text.trim(), code);
                        print(verified);
                        print(verifyRecoveryCode(
                                context, emailController.text.trim(), code)
                            .toString());
                        checkRecoveryCode();

                        if (verified) {
                          // scaffoldMessengerKey.currentState?.showSnackBar(
                          //   SnackBar(
                          //       content:
                          //           Text('Código verificado correctamente')),
                          // );
                          Navigator.of(context).pop();
                          _showChangePasswordDialog(context);
                        } else {
                          // scaffoldMessengerKey.currentState?.showSnackBar(
                          //   SnackBar(content: Text('Código incorrecto')),
                          // );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  child: Text(
                      showCodeInput ? 'Verificar Código' : 'Enviar Correo',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool _obscureText = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cambiar Contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureText,
                    decoration: const InputDecoration(
                      hintText: 'Confirmar contraseña',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1abc9c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                  ),
                  onPressed: () async {
                    if (_emailTemporal == null) {
                      // scaffoldMessengerKey.currentState?.showSnackBar(
                      //   SnackBar(content: Text('No se identificó el usuario')),
                      // );
                      return;
                    }
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      // scaffoldMessengerKey.currentState?.showSnackBar(
                      //   SnackBar(content: Text('Las contraseñas no coinciden')),
                      // );
                    } else {
                      bool success = await changePassword(
                          context, _emailTemporal!, newPasswordController.text);

                      if (success) {
                        Navigator.of(context).pop();

                        // scaffoldMessengerKey.currentState?.showSnackBar(
                        //   SnackBar(content: Text('Contraseña cambiada exitosamente')),
                        // );
                      } else {
                        // scaffoldMessengerKey.currentState?.showSnackBar(
                        //   SnackBar(content: Text('Error al cambiar la contraseña')),
                        // );
                      }
                    }
                  },
                  child: const Text('Cambiar Contraseña',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            const FondoWidget(),
            Positioned(
              top: 35,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _showPasswordDialog(context);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings,
                            color: Colors.white),
                        const SizedBox(height: 5),
                        Text(
                          'Admin',
                          style: GoogleFonts.gantari(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 35),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      child: const LoginForm(),
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 600 ? 20 : 30;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SISTEMA DE DATOS PACHA',
                style: GoogleFonts.kodchasan(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                ),
              ),
              TextSpan(
                text: 'YATIÑA',
                style: GoogleFonts.gantari(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            'images/logo4.png',
            width: 300,
          ),
        ),
        SizedBox(
          width: 300,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListaUsuarioEstacionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8F9F9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.badge,
              size: 24,
              color: Color(0xFF164092),
            ),
            label: Text(
              "Soy Observador",
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8F9F9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChangeNotifierProvider(
                    create: (context) => PromotorService(),
                    child: const PromotorScreen(),
                  );
                }),
              );
            },
            icon: const Icon(
              Icons.assignment_ind,
              size: 24,
              color: Color(0xFF164092),
            ),
            label: Text(
              "Soy Promotor",
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChangeNotifierProvider(
                    create: (context) => EstacionService(),
                    child: const MunicipiosScreen(),
                  );
                }),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8F9F9),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(
              Icons.account_circle,
              size: 24,
              color: Color(0xFF164092),
            ),
            label: Text(
              "Entrar como invitado",
              style: GoogleFonts.lexend(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
