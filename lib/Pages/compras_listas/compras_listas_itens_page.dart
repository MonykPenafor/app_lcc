import 'package:app_lcc/Components/list_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lcc/Models/item.dart';
import 'package:app_lcc/Services/lista_de_compras_services.dart';

class ComprasListasItensPage extends StatefulWidget {
  final String id;
  final String nome;

  const ComprasListasItensPage({Key? key, required this.id, required this.nome})
      : super(key: key);

  @override
  _ComprasListasItensPageState createState() => _ComprasListasItensPageState();
}

class _ComprasListasItensPageState extends State<ComprasListasItensPage> {
  final ListaDeComprasServices _listaService = ListaDeComprasServices();
  final _itemNomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _obsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nome),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _listaService.getItemsStream(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar itens: ${snapshot.error}'));
          }
          final itens = snapshot.data ??
              []; // Garante uma lista vazia se não houver dados

          // calcular progresso
          int totalItens = itens.length;
          int boughtItens = itens.where((item) => item.isBought).length;
          double progress = totalItens > 0 ? boughtItens / totalItens : 0.0;
          return Column(
            children: [
              // Barra de Progresso (só mostra se houver itens)
              if (totalItens > 0)
                ListProgressBar(
                  totalItens: totalItens,
                  boughtItens: boughtItens,
                  progressColor: Colors.green,
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.all(8.0),
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              // Mensagem se a lista estiver vazia
              if (itens.isEmpty &&
                  snapshot.connectionState != ConnectionState.waiting)
                const Expanded(
                  child: Center(child: Text('Nenhum item nesta lista ainda')),
                )
              else
                Expanded(
                    child: ListView.builder(
                        itemCount: itens.length,
                        itemBuilder: (context, index) {
                          final item = itens[index];
                          return ListTile(
                            leading: Checkbox(
                                value: item.isBought,
                                onChanged: (bool? newValue) {
                                  if (newValue != null) {
                                    _updateItemStatus(item, newValue);
                                  }
                                }),
                            title: Text(
                              item.itemNome,
                              style: TextStyle(
                                decoration: item.isBought
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.isBought ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text(
                              'Qdt:${item.quantidade}${item.obs != null && item.obs!.isNotEmpty ? " - Obs: ${item.obs}" : ""}',
                              style: TextStyle(
                                decoration: item.isBought
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item.isBought ? Colors.grey : null,
                              ),
                            ),
                            onTap: () {
                              _updateItemStatus(item, !item.isBought);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outlined,
                                  color: Colors.redAccent),
                              tooltip: 'Remover Item',
                              onPressed: () {
                                _deleteItem(item);
                              },
                            ),
                          );
                        }))
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        tooltip: 'Adicionar Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _itemNomeController.dispose();
    _quantidadeController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _showAddItemDialog(BuildContext context) {
    _itemNomeController.clear();
    _quantidadeController.clear();
    _obsController.clear();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Adicionar novo item'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _itemNomeController,
                      decoration:
                          const InputDecoration(labelText: 'Nome do Item'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do item';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                          labelText: 'Quantidade (ex: 1kg, 2 un)'),
                    ),
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                          labelText: 'Observações (opcional)'),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Adicionar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addItemToList();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  Future<void> _addItemToList() async {
    final newItem = Item(
      itemNome: _itemNomeController.text,
      quantidade: _quantidadeController.text.isNotEmpty
          ? _quantidadeController.text
          : '1',
      obs: _obsController.text,
      isBought: false, // Novo item sempre pendente
      listaId: widget.id,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      //userId: FirebaseAuth.instance.currentUser!.uid,
      //idItem: '', // Adicionar se usar autenticação
    );
    try {
      await _listaService.addItem(widget.id, newItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('"${newItem.itemNome}" adicionado!'),
            duration: const Duration(seconds: 2)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao adicionar item: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateItemStatus(Item item, bool newStatus) async {
    if (item.idItem == null) {
      print("Erro> ID do item é nulo.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erro ao atualizar item: ID não encontrado."),
            backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await _listaService.updateItemStatus(widget.id, item.idItem!, newStatus);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erro ao atualizar status: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteItem(Item item) async {
    if (item.idItem == null) {
      print("Erro: ID do item é nulo.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erro ao remover item: ID não encontrado."),
            backgroundColor: Colors.red),
      );
      return;
    }
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Remover "${item.itemNome}" da lista'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remover',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ));

    if (confirm == true) {
      try {
        await _listaService.deleteItem(widget.id, item.idItem!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('"${item.itemNome}" removido.'),
              duration: const Duration(seconds: 2)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro ao remover item: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}
