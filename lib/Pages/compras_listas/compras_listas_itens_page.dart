import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lcc/Models/item.dart';
import 'package:app_lcc/Services/lista_de_compras_services.dart';

class ComprasListasItensPage extends StatefulWidget {
  final String id;
  final String nome;

  const ComprasListasItensPage({super.key, required this.id, required this.nome});

  @override
  _ComprasListasItensPageState createState() => _ComprasListasItensPageState();
}

class _ComprasListasItensPageState extends State<ComprasListasItensPage> {
  final ListaDeComprasServices _listaService = ListaDeComprasServices();
  final _itemNomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _obsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? userAccess;
  bool isLoadingAccess = true;

  @override
  void initState() {
    super.initState();
    _loadUserAccess();
  }

  Future<void> _loadUserAccess() async {
    final userId = _listaService.user?.uid;
    if (userId == null) {
      setState(() {
        userAccess = null;
        isLoadingAccess = false;
      });
      return;
    }
    final access = await _listaService.getUserAccessForList(widget.id, userId);
    setState(() {
      userAccess = access;
      isLoadingAccess = false;
    });
  }

  bool get canEditItems => userAccess?['podeEditar'] == true;
  bool get canDeleteItems => userAccess?['podeExcluir'] == true;
  bool get canViewItems => userAccess?['podeVisualizar'] == true;

  @override
  Widget build(BuildContext context) {
    if (isLoadingAccess) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (!canViewItems) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.nome)),
          body: const Center(child: Text('Você não tem permissão para visualizar esta lista.')));
    }

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
          final itens = snapshot.data ?? [];

          int totalItens = itens.length;
          int boughtItens = itens.where((item) => item.isBought).length;
          double progress = totalItens > 0 ? boughtItens / totalItens : 0.0;

          return Column(
            children: [
              if (totalItens > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}% Concluído ($boughtItens de $totalItens itens)",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (itens.isEmpty && snapshot.connectionState != ConnectionState.waiting)
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
                          onChanged: canEditItems
                              ? (bool? newValue) {
                                  if (newValue != null) {
                                    _updateItemStatus(item, newValue);
                                  }
                                }
                              : null, // desabilita checkbox se não pode editar
                        ),
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
                        onTap: canEditItems
                            ? () {
                                _updateItemStatus(item, !item.isBought);
                              }
                            : null,
                        trailing: canDeleteItems
                            ? IconButton(
                                icon: const Icon(Icons.delete_outlined,
                                    color: Colors.redAccent),
                                tooltip: 'Remover Item',
                                onPressed: () {
                                  _deleteItem(item);
                                },
                              )
                            : null,
                      );
                    },
                  ),
                )
            ],
          );
        },
      ),
      floatingActionButton: canEditItems
          ? FloatingActionButton(
              onPressed: () => _showAddItemDialog(context),
              tooltip: 'Adicionar Item',
              child: const Icon(Icons.add),
            )
          : null,
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
