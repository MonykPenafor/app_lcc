import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:app_lcc/Services/lista_de_compras_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/custom_snackbar.dart';
import '../compras_listas/compras_listas_itens_page.dart';

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
              child: Consumer<ListaDeComprasServices>(
                builder:
                    (context, listaDeComprasServices, child) {
                  return StreamBuilder(
                    stream: listaDeComprasServices
                        .buscarListas(),
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

                      final userId = Provider.of<ListaDeComprasServices>(context, listen: false).user?.uid;

return ListView.builder(
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    DocumentSnapshot ds = snapshot.data!.docs[index];
    ListaDeCompras lista = ListaDeCompras.fromDocument(ds);

    Map<String, dynamic>? acessos = (ds.data() as Map<String, dynamic>)['acessos'];
    Map<String, dynamic>? meuAcesso = acessos != null ? acessos[userId] : null;

    Color backgroundColor = Colors.grey[200]!;
    IconData acessoIcon = Icons.remove_red_eye;

    if (meuAcesso != null) {
      if (meuAcesso['podeExcluir'] == true) {
        backgroundColor = Colors.red[100]!;
        acessoIcon = Icons.admin_panel_settings;
      } else if (meuAcesso['podeEditar'] == true) {
        backgroundColor = Colors.blue[100]!;
        acessoIcon = Icons.edit;
      } else if (meuAcesso['podeVisualizar'] == true) {
        backgroundColor = Colors.green[100]!;
        acessoIcon = Icons.visibility;
      }
    }

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(acessoIcon),
          title: Text(
            lista.nome ?? 'Sem nome',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            lista.categoria ?? '',
            style: const TextStyle(fontSize: 14.0),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComprasListasItensPage(
                  id: lista.id!,
                  nome: lista.nome ?? 'Sem nome',
                ),
              ),
            );
          },
          trailing: PopupMenuButton<String>(
            onSelected: (String value) {
              _handleMenuAction(
                  context,
                  value,
                  lista,
                  Provider.of<ListaDeComprasServices>(context, listen: false));
            },
            itemBuilder: (BuildContext context) => [
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
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
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
          final listaServices =
              Provider.of<ListaDeComprasServices>(context, listen: false);

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
                          categoria.isEmpty) {
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
) async {
  final doc = await listaDeComprasServices.getListaDocumento(lista.id);

  if (doc == null) {
    CustomSnackBar.show(context, 'Lista não encontrada.', false);
    return;
  }

  final data = doc.data() as Map<String, dynamic>;
  final userId = listaDeComprasServices.user?.uid;

  final acessos = data['acessos'] as Map<String, dynamic>?;

  bool podeEditar = false;

  if (userId != null && acessos != null) {
    if (acessos.containsKey(userId) && acessos[userId]['podeEditar'] == true) {
      podeEditar = true;
    }
  }

  if (!podeEditar) {
    CustomSnackBar.show(
      context,
      'Você não tem permissão para editar esta lista.',
      false,
    );
    return;
  }

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
void _compartilharLista(
  BuildContext context,
  ListaDeCompras lista,
  ListaDeComprasServices listaDeComprasServices
) {
  final currentUserId = listaDeComprasServices.user?.uid;

  // Verifica permissão de administrador
  bool isAdmin = false;
  if (lista.acessos != null && currentUserId != null) {
    final acessoUsuario = lista.acessos![currentUserId];
    if (acessoUsuario != null && acessoUsuario['podeExcluir'] == true) {
      isAdmin = true;
    }
  }

  if (!isAdmin) {
    // Usuário não tem permissão para compartilhar
    CustomSnackBar.show(
      context,
      'Apenas administradores podem compartilhar esta lista.',
      false,
    );
    return; // Sai da função, não abre o diálogo
  }

  // Se for admin, continua e abre o diálogo
  final TextEditingController emailController = TextEditingController();
  String selectedPermissao = 'convidado'; // valor padrão

  final Map<String, String> permissoes = {
    'convidado': 'Somente visualização',
    'participante': 'Pode editar itens',
    'administrador': 'Pode editar e excluir',
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Compartilhar Lista "${lista.nome}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "E-mail do usuário",
                border: OutlineInputBorder(),
                hintText: "usuario@email.com",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPermissao,
              decoration: const InputDecoration(
                labelText: 'Tipo de acesso',
                border: OutlineInputBorder(),
              ),
              items: permissoes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text('${entry.key[0].toUpperCase()}${entry.key.substring(1)} - ${entry.value}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedPermissao = value;
                }
              },
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
              final email = emailController.text.trim();

              if (email.isEmpty) {
                CustomSnackBar.show(
                  context,
                  'Digite um e-mail válido!',
                  false,
                );
                return;
              }

              Navigator.of(context).pop(); // Fecha o modal

              await listaDeComprasServices.compartilharLista(
                lista.id,
                email,
                selectedPermissao,
              );

              CustomSnackBar.show(
                context,
                'Lista compartilhada com $email como ${selectedPermissao.toUpperCase()}!',
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
              Navigator.of(context).pop();

              final doc = await listaDeComprasServices.getListaDocumento(lista.id);

              if (doc == null) {
                CustomSnackBar.show(
                  context,
                  'Lista não encontrada.',
                  false,
                );
                return;
              }

              final data = doc.data() as Map<String, dynamic>;
              final usuarioCriador = data['usuarioCriador'];
              final userId = listaDeComprasServices.user?.uid;

              // Verifica permissões no campo 'acessos'
              final acessos = data['acessos'] as Map<String, dynamic>?;

              bool podeExcluir = false;

              if (userId != null) {
                if (userId == usuarioCriador) {
                  podeExcluir = true;
                } else if (acessos != null &&
                    acessos.containsKey(userId) &&
                    acessos[userId]['podeExcluir'] == true) {
                  podeExcluir = true;
                }
              }

              if (!podeExcluir) {
                CustomSnackBar.show(
                  context,
                  'Você não tem permissão para excluir esta lista.',
                  false,
                );
                return;
              }

              var result = await listaDeComprasServices.excluirLista(lista.id);

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
