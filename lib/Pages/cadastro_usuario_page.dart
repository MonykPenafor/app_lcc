import 'package:flutter/material.dart';

class CadastroUsuarioPage extends StatelessWidget {
  const CadastroUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Usuario"), centerTitle: true,),
      body:
      Center(child:
        Padding(padding: const EdgeInsets.all(16.0),child: 
          Form(child: 
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [ 
                const SizedBox(height: 32,),
                TextFormField(decoration: const InputDecoration(label: Text("Nome:")),),
                TextFormField(decoration: const InputDecoration(label: Text("E-mail:")),),
                TextFormField(decoration: const InputDecoration(label: Text("Senha:")),),
                TextFormField(decoration: const InputDecoration(label: Text("Confirme a Senha:")),),
                const SizedBox(height: 16,),
                ElevatedButton(onPressed: (){}, child: const Text("Cadastrar")),
                const Divider(),
                TextButton(onPressed: (){}, child: const Text("Já tem uma conta? Entre!")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CadastroUsuarioPage extends StatelessWidget {
  const CadastroUsuarioPage({super.key});

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Nome:")),
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("E-mail:")),
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Senha:")),
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(label: Text("Confirme a Senha:")),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                      print("Cadastrado");
                    },
                    child: const Text("Cadastrar")),
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
