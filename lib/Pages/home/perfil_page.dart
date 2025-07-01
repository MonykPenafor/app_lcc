// lib/pages/perfil_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'Pages/login_page.dart';

class PerfilPage extends StatefulWidget {
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  void _carregarDadosUsuario() async {
    final user = _authService.usuarioAtual;
    if (user != null) {
      final nome = await _firestoreService.buscarNomeUsuario(user.uid);
      setState(() {
        _nomeController.text = nome ?? '';
        _emailController.text = user.email ?? '';
        _carregando = false;
      });
    }
  }

  void _atualizarNome() async {
    final uid = _authService.usuarioAtual?.uid;
    if (uid != null) {
      await _firestoreService.atualizarNomeUsuario(uid, _nomeController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nome atualizado com sucesso!')));
    }
  }

  void _alterarSenha() async {
    try {
      await _authService.alterarSenha(_senhaController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha alterada. Faça login novamente.')));
      await _authService.logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  void _atualizarEmail() async {
    try {
      final user = _authService.usuarioAtual;
      final cred = EmailAuthProvider.credential(email: user!.email!, password: _senhaAtualController.text);
      await user.reauthenticateWithCredential(cred);
      await user.updateEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email atualizado com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar e-mail: $e')));
    }
  }

  void _excluirConta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir sua conta? Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.usuarioAtual?.delete();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.usuarioAtual;
    return Scaffold(
      appBar: AppBar(title: Text('Perfil do Usuário')),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Icon(Icons.account_circle, size: 80, color: Colors.grey)),
                    SizedBox(height: 10),
                    Text('Nome:'),
                    TextField(controller: _nomeController),
                    ElevatedButton(onPressed: _atualizarNome, child: Text('Salvar Nome')),

                    SizedBox(height: 20),
                    Text('Email:'),
                    TextField(controller: _emailController),
                    TextField(controller: _senhaAtualController, obscureText: true, decoration: InputDecoration(hintText: 'Senha atual')), 
                    ElevatedButton(onPressed: _atualizarEmail, child: Text('Atualizar Email')),

                    SizedBox(height: 20),
                    Text('Nova Senha:'),
                    TextField(controller: _senhaController, obscureText: true),
                    ElevatedButton(onPressed: _alterarSenha, child: Text('Alterar Senha')),

                    Divider(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _excluirConta,
                      child: Text('Excluir Conta'),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      onPressed: () async {
                        await _authService.logout();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                      },
                      child: Text('Sair da Conta'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
