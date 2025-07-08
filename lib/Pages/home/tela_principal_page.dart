import 'package:app_lcc/Models/app_user.dart';
import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:app_lcc/Services/lista_de_compras_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/custom_snackbar.dart';
import '../../Services/user_services.dart';
import '../compras_listas/compras_listas_itens_page.dart';

class TelaPrincipalPage extends StatelessWidget {
  TelaPrincipalPage({super.key});

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaCntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    
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
                        .buscarListas(user),
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
                          ListaDeCompras lista =
                              ListaDeCompras.fromDocument(ds);

                          return GestureDetector(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ComprasListasItensPage(
                                        id: lista.id!,
                                        nome: lista.nome ?? 'Sem nome',
                                      ),
                                    ),
                                  );
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
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lista.nome!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                Text(
                                                  lista.categoria!,
                                                  style: const TextStyle(
                                                      fontSize: 14.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (String value) {
                                              _handleMenuAction(
                                                  context,
                                                  value,
                                                  lista,
                                                  userServices,
                                                  listaDeComprasServices);
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'editar',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Editar'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'compartilhar',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.share, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Compartilhar'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'excluir',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        size: 20,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Excluir',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            icon: const Icon(Icons.more_vert),
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
                          usuarioCriador: user!.uid,
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

  void _handleMenuAction(
    BuildContext context,
    String action,
    ListaDeCompras lista,
    UserServices userServices,
    ListaDeComprasServices listaDeComprasServices,
  ) {
    switch (action) {
      case 'editar':
        _editarLista(context, lista, listaDeComprasServices);
        break;
      case 'compartilhar':
        _compartilharLista(context, lista, listaDeComprasServices);
        break;
      case 'excluir':
        _excluirLista(context, lista, listaDeComprasServices);
        break;
    }
  }

  void _editarLista(
    BuildContext context,
    ListaDeCompras lista,
    ListaDeComprasServices listaDeComprasServices,
  ) {
    final TextEditingController nomeEditController =
        TextEditingController(text: lista.nome);
    final TextEditingController categoriaEditController =
        TextEditingController(text: lista.categoria);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeEditController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: categoriaEditController,
                decoration: const InputDecoration(
                  labelText: "Categoria",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String nome = nomeEditController.text.trim();
                String categoria = categoriaEditController.text.trim();

                if (nome.isEmpty || categoria.isEmpty) {
                  CustomSnackBar.show(
                    context,
                    'Preencha todos os campos!',
                    false,
                  );
                  return;
                }

                lista.nome = nome;
                lista.categoria = categoria;

                var result = await listaDeComprasServices.salvarLista(lista);

                Navigator.of(context).pop();

                CustomSnackBar.show(
                  context,
                  result['message'] ?? 'Lista atualizada com sucesso!',
                  result['success'] ?? true,
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _compartilharLista(BuildContext context, ListaDeCompras lista,
      ListaDeComprasServices listaDeComprasServices) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Compartilhar Lista'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Compartilhar "${lista.nome}" com:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email do usuário",
                  border: OutlineInputBorder(),
                  hintText: "usuario@email.com",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();

                if (email.isEmpty) {
                  CustomSnackBar.show(
                    context,
                    'Digite um email válido!',
                    false,
                  );
                  return;
                }

                await listaDeComprasServices.compartilharLista(lista.id, email);

                Navigator.of(context).pop();

                CustomSnackBar.show(
                  context,
                  'Lista compartilhada com $email!',
                  true,
                );
              },
              child: const Text('Compartilhar'),
            ),
          ],
        );
      },
    );
  }

  void _excluirLista(
    BuildContext context,
    ListaDeCompras lista,
    ListaDeComprasServices listaDeComprasServices,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Lista'),
          content:
              Text('Tem certeza que deseja excluir a lista "${lista.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                var result =
                    await listaDeComprasServices.excluirLista(lista.id);

                Navigator.of(context).pop();

                CustomSnackBar.show(
                  context,
                  result['message'] ?? 'Lista excluída com sucesso!',
                  result['success'] ?? true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
