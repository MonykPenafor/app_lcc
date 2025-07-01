import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;
  late TextEditingController nomeController;
  late TextEditingController emailController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    user = _auth.currentUser;

    nomeController = TextEditingController(text: user?.displayName ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Se cancelar a edição, reseta os campos para dados atuais
        nomeController.text = user?.displayName ?? "";
        emailController.text = user?.email ?? "";
      }
    });
  }

  Future<void> salvarAlteracoes() async {
    try {
      // Atualiza o nome no Firebase
      await user?.updateDisplayName(nomeController.text.trim());

      // Opcional: Para atualizar o email, o usuário precisaria reautenticar
      // await user?.updateEmail(emailController.text.trim());

      // Refresh do usuário atual para pegar os novos dados
      await user?.reload();
      user = _auth.currentUser;

      setState(() {
        isEditing = false;
        nomeController.text = user?.displayName ?? "";
        emailController.text = user?.email ?? "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Usuário não está logado
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(
          child: Text('Nenhum usuário logado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade400,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.cancel : Icons.edit),
            tooltip: isEditing ? "Cancelar edição" : "Editar perfil",
            onPressed: toggleEditMode,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              color: Colors.teal,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Informações do Usuário',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: nomeController,
              readOnly: !isEditing,
              decoration: InputDecoration(
                labelText: "Nome",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              readOnly: true, // Por segurança, não permite editar o email aqui
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: salvarAlteracoes,
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
