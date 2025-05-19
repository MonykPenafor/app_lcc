import 'package:app_lcc/Pages/cadastro_usuario_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cadastro',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 215, 253, 1)),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: const CadastroUsuarioPage());
  }
}
