import 'package:app_lcc/Models/perfil_usuario_models.dart';
import 'package:flutter/material.dart';

class PerfilUsuario extends StatelessWidget {
  PerfilUsuario({super.key});

  final PerfilModels perfilModels =
      PerfilModels(id: "PF001", nome: "Jobernico", senha: "Salgadodeacucar");

  final List<PerfilModels> listaperfis = [
    PerfilModels(id: "PF002", nome: "JHON5", senha: "Rockislife!"),
    PerfilModels(id: "PF003", nome: "Belo", senha: "Gracianne<3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(perfilModels.nome),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(78, 4, 162, 235),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                /*Title(
                  color: const Color.fromARGB(255, 17, 218, 100),
                  child: Text(perfilModels.nome),
                ),*/
                const Icon(
                  Icons.account_circle,
                  color: Color.fromARGB(255, 22, 202, 82),
                  size: 100.0,
                  semanticLabel: "Perfil",
                ),
                TextFormField(initialValue: perfilModels.nome,
                  decoration: const InputDecoration(
                    label: Text("Nome:"),
                  ),
                ),
                TextFormField(initialValue: perfilModels.senha,
                  decoration: const InputDecoration(label: Text("Senha:")),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: const Text("Salvar"),
                ),
              ],
            ),
          ),
        ));
  }
}
