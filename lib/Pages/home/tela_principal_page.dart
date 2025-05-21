import 'package:app_lcc/Models/app_user.dart';
import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:app_lcc/Services/lista_de_compras_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/custom_snackbar.dart';
import '../../Services/user_services.dart';

class TelaPrincipalPage extends StatelessWidget {
  TelaPrincipalPage({super.key});

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaCntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listas de Compras',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer2<UserServices, ListaDeComprasServices>(
                builder:
                    (context, userServices, listaDeComprasServices, child) {
                  return StreamBuilder(
                    stream: listaDeComprasServices
                        .buscarListas(userServices.appUser),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma lista encontrada.',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds = snapshot.data!.docs[index];
                            ListaDeCompras _lista = ListaDeCompras.fromDocument(ds);

                            return GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    //         EventNavigationPage(event: _event),
                                    //   ),
                                    // );
                                  },
                                  
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 168, 217, 255),
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                                  255, 161, 194, 255)
                                              .withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Card(
                                      elevation: 0,
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _lista.nome!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            Text(
                                              _lista.categoria!,
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                    
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final userServices =
              Provider.of<UserServices>(context, listen: false);
          final listaServices =
              Provider.of<ListaDeComprasServices>(context, listen: false);
          final AppUser? appUser = userServices.appUser;

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Nova Lista de Compras'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nome",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoriaCntroller,
                      decoration: const InputDecoration(
                        labelText: "Categoria",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _nomeController.clear();
                      _categoriaCntroller.clear();
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String nome = _nomeController.text.trim();
                      String categoria = _categoriaCntroller.text.trim();

                      if (nome.isEmpty ||
                          categoria.isEmpty ||
                          appUser == null) {
                        CustomSnackBar.show(
                          context,
                          'Preencha todos os campos!',
                          false,
                        );
                        return;
                      }

                      var novaLista = ListaDeCompras(
                        nome: nome,
                        categoria: categoria,
                        usuarioCriador: 'usuario1' //appUser.id,
                      );

                      var result = await listaServices.salvarLista(novaLista);

                      Navigator.of(context).pop();
                      _nomeController.clear();
                      _categoriaCntroller.clear();

                      CustomSnackBar.show(
                        context,
                        result['message'],
                        result['success'],
                      );
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
