import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/cadastro_usuario_page.dart';
import 'Pages/home/tela_principal_page.dart';

import 'Services/lista_de_compras_services.dart';
import 'Services/user_services.dart';


void main() async {
  
  var options = const FirebaseOptions(
      apiKey: "AIzaSyC_rHsI6Ori_m5Da3g7ZwAEwaCuf3ewHwU",
      authDomain: "app-lcc-cbfa9.firebaseapp.com",
      projectId: "app-lcc-cbfa9",
      storageBucket: "app-lcc-cbfa9.firebasestorage.app",
      messagingSenderId: "70967126082",
      appId: "1:70967126082:web:f3ca802e3ceddb351165db",
      measurementId: "G-6X5XPR3GP5"
  );
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb){
    await Firebase.initializeApp(options: options);
  } else  {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListaDeComprasServices(), lazy: false,),
        ChangeNotifierProvider(create: (_) => UserServices(), lazy: false,)],
      
      child: MaterialApp(
        title: 'APP MARIMO',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 175, 46, 46)),
          useMaterial3: true,
        ),
        initialRoute: '/cadastroUsuario',
        routes: {
            '/main':(context) => TelaPrincipalPage(),
            '/cadastroUsuario': (context) => const CadastroUsuarioPage(),
        },     
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

