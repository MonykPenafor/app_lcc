import 'dart:async';
import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:app_lcc/Models/listas_por_usuarios.dart';
import 'package:app_lcc/Services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../Models/app_user.dart';
import '../Models/item.dart';

class ListaDeComprasServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collectionRefLista => _firestore.collection("listas");
  CollectionReference get _collectionRefListasPorUsuario => _firestore.collection("listasPorUsuario");
  final UserServices _userServices = UserServices();

  Future<Map<String, dynamic>> salvarLista(ListaDeCompras lista) async {
    dynamic resultado;

    try {
      if (lista.id != null) {
        resultado = await atualizarLista(lista);
      } else {
        resultado = await criarLista(lista);
      }

      return {
        'success': true,
        'message': resultado,
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao salvar a lista: $e'};
    }
  }

  Future<String> criarLista(ListaDeCompras lista) async {
    DocumentReference docRef = await _collectionRefLista.add(lista.toJson());

    var listaPorUsuario = ListasPorUsuarios(
      listaId: lista.id,
      usuarioId: lista.usuarioCriador,
      podeVisualizar: true,
      podeEditar: true,
      podeExcluir: true
    );

    await _collectionRefListasPorUsuario.add(listaPorUsuario.toJson());

    await docRef.update({'id': docRef.id});
    return "lista criada";
  }

  Future<String> atualizarLista(ListaDeCompras lista) async {
    await _collectionRefLista
        .doc(lista.id)
        .set(lista.toJson(), SetOptions(merge: true));
    return "Event updated successfully";
  }

  Stream<QuerySnapshot> buscarListas(AppUser? user) {
    String? userId = user!.id;
    return _collectionRefLista
        .where('usuarioCriador', isEqualTo: userId)
        .orderBy('nome')
        .snapshots();
  }

  Future<Map<String, dynamic>> excluirLista(String? listaId) async {
    try {
      await _collectionRefLista.doc(listaId).delete();

      return {
        'success': true,
        'message': 'Lista Excluida',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao excluir a lista: $e'};
    }
  }

  Future<Map<String, dynamic>> compartilharLista(String? listaId, String email) async {
    try {
      //var idUsuario = _userServices.retornarIdUsuarioPeloEmail(email);
      var idUsuario = '123';

      var listaPorUsuario = ListasPorUsuarios(
        listaId: listaId,
        usuarioId: idUsuario,
        podeVisualizar: true
      );

      DocumentReference docRef = await _collectionRefListasPorUsuario.add(listaPorUsuario.toJson());
      await docRef.update({'id': docRef.id});

      return {
        'success': true,
        'message': 'Lista compartilhada',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao compartilhar a lista: $e'};
    }
  }

  
  CollectionReference<Item> _itemsRef(String listId) => _collectionRef
      .doc(listId)
      .collection('itens') // Nome da subcoleção de itens
      .withConverter<Item>(
        fromFirestore: Item.fromFirestore,
        toFirestore: (Item item, _) => item.toFirestore(),
      );

  Stream<List<Item>> getItemsStream(String listId) {
    return _itemsRef(listId)
        .orderBy('createdAt',
            descending: false) // Ordena por data de criação (ou como preferir)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addItem(String listId, Item item) async {
    try {
      await _itemsRef(listId).add(item);
      print('Item "${item.itemNome}" adicionado com sucesso à lista $listId');
    } catch (e) {
      print('Erro ao adicionar item à lista $listId: $e');
      // Re-throw para que a UI possa tratar o erro, se necessário
      rethrow;
    }
  }

}
