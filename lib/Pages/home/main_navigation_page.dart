import 'package:app_lcc/Pages/cadastro_usuario_page.dart';
import 'package:app_lcc/Pages/perfil_usuario_page.dart';
import 'package:flutter/material.dart';
import '../login_page.dart';
import 'tela_principal_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const PerfilUsuario(),
          TelaPrincipalPage()
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Listas de Compra',
          )
        ],
      ),
    );
  }
}
