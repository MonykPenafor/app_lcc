import 'package:app_lcc/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:app_lcc/Pages/perfil_usuario_page.dart';
import 'tela_principal_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  bool _isDarkTheme = false; // Controle do tema (claro ou escuro)

  // Função para alternar o tema
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

 // Função de logout simples (sem persistência de token)
  void _logout() {
    // Limpar dados de sessão (se houver)
    // Exemplo: Você pode resetar variáveis de estado ou limpar qualquer dado em memória

    // Navegar de volta para a tela de login ou alguma tela inicial
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Troque pela sua tela de login
      (route) => false, // Remove todas as rotas anteriores
    );

    print("Usuário deslogado");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode:
          _isDarkTheme ? ThemeMode.dark : ThemeMode.light, // Aplica o tema
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema escuro
      home: Scaffold(
        appBar: AppBar(
          title: const Text("MARIMO"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout, // Chama a função de logout
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const PerfilUsuario(),
            TelaPrincipalPage(),
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
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleTheme, // Alterna o tema
          child: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}
