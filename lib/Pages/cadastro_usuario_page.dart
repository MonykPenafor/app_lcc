import 'package:app_lcc/Models/cadastro_usuario_models.dart';
import 'package:flutter/material.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  UsuarioModel usuarioModel =
      UsuarioModel(id: "", nome: "nome", email: "email", senha: "senha");
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmaSenhaController = TextEditingController();
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
                  controller: nomeController,
                  decoration: const InputDecoration(label: Text("Nome:")),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(label: Text("E-mail:")),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Digite um e-mail';
                    if (!value.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: senhaController,
                  decoration: const InputDecoration(label: Text("Senha:")),
                ),
                TextFormField(
                    controller: confirmaSenhaController,
                    decoration: const InputDecoration(
                        label: Text("Confirme a Senha:"))),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (senhaController.text !=
                          confirmaSenhaController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("As senhas não coincidem")),
                        );
                        return;
                      }

                      setState(() {
                        usuarioModel = UsuarioModel(
                          id: "", // pode ser gerado com UUID ou no backend
                          nome: nomeController.text,
                          email: emailController.text,
                          senha: senhaController.text,
                        );
                        @override
                        void dispose() {
                          nomeController.dispose();
                          emailController.dispose();
                          senhaController.dispose();
                          confirmaSenhaController.dispose();
                          super.dispose();
                        }
                      });

                      print(
                          "Usuário cadastrado: ${usuarioModel.nome}, ${usuarioModel.email}");
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
