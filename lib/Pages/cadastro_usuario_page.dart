import 'package:app_lcc/Models/cadastro_usuario_models.dart';
import 'package:app_lcc/Services/autenticacao_servico.dart';
import 'package:flutter/material.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  UsuarioModel usuarioModel =
      UsuarioModel(id: "", nome: "nome", email: "email", senha: "senha");
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController =
      TextEditingController();
  final AutenticacaoServico _autServico = AutenticacaoServico();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Usuario"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(label: Text("Nome:")),
                  validator: (String? value) {
                    if (value == null) {
                      return "O nome não pode estar vazio";
                    }
                    if (value.length < 5) {
                      return "O nome é muito curto";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(label: Text("E-mail:")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite um e-mail';
                    }
                    if (!value.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(label: Text("Senha:")),
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null) {
                      return "A senha não pode estar vazia";
                    }
                    if (value.length < 5) {
                      return "A senha esta muito curta";
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: _confirmaSenhaController,
                    decoration: const InputDecoration(
                        label: Text("Confirme a Senha:")),
                        validator: (String? value) {
                    if (value == null) {
                      return "A Confirmção de senha não pode estar vazia";
                    }
                    if (value.length < 5) {
                      return "A Confirmção de senha é muito curta";
                    }
                    return null;
                  },),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String nome = _nomeController.text;
                      String email = _emailController.text;
                      String senha = _senhaController.text;
                      print(
                          "Usuário cadastrado: ${_emailController.text}, ${_senhaController.text}, ${_nomeController.text}, ");
                      _autServico.cadastrarUsuario(
                          nome: nome, senha: senha, email: email);
                      // Aqui você pode chamar um método para enviar os dados ao backend
                    }
                  },
                  child: const Text("Cadastrar"),
                ),
                const Divider(),
                TextButton(
                    onPressed: () {
                      print("foi pro login");
                    },
                    child: const Text("Já tem uma conta? Entre!")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
