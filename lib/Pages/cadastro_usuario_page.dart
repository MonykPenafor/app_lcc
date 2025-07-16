import 'package:app_lcc/Models/cadastro_usuario_models.dart';
import 'package:app_lcc/Pages/login_page.dart';
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
        title: const Text("Cadastro de Usuário"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 168, 217, 255),
        elevation: 4,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    "Cadastre-se agora",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: const Color.fromARGB(234, 111, 109, 228),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(
                    controller: _nomeController,
                    label: "Nome",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "O nome não pode estar vazio";
                      }
                      if (value.length < 5) {
                        return "O nome é muito curto";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "E-mail",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite um e-mail';
                      }
                      if (!value.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _senhaController,
                    label: "Senha",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "A senha não pode estar vazia";
                      }
                      if (value.length < 5) {
                        return "A senha está muito curta";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmaSenhaController,
                    label: "Confirme a Senha",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "A confirmação de senha não pode estar vazia";
                      }
                      if (value != _senhaController.text) {
                        return "As senhas não coincidem";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String nome = _nomeController.text;
                        String email = _emailController.text;
                        String senha = _senhaController.text;
                        print("Usuário cadastrado: $nome, $email");
                        _autServico.cadastrarUsuario(
                            nome: nome, senha: senha, email: email).then((_) {
                          // Cadastro bem-sucedido: redireciona para a tela de login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        }).catchError((e) {
                          // Em caso de erro, mostre um alerta
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erro ao cadastrar usuário: $e")),
                          );
                        });;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 168, 217, 255),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Já tem uma conta? Entre!",
                      style: TextStyle(
                          color: Color.fromARGB(234, 111, 109, 228),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Função que centraliza o design do TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(234, 111, 109, 228)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}