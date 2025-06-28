import 'dart:async';
import 'package:app_lcc/Models/item.dart';
import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../Models/app_user.dart';

class ListaDeComprasServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collectionRef => _firestore.collection("listas");

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
    DocumentReference docRef = await _collectionRef.add(lista.toJson());

    // lista.id = docRef.id;

    // await _collectionRef .doc(lista.id).set(lista.toJson(), SetOptions(merge: true));

    await docRef.update({'id': docRef.id});
    return "lista criada";
  }

  Future<String> atualizarLista(ListaDeCompras lista) async {
    await _collectionRef
        .doc(lista.id)
        .set(lista.toJson(), SetOptions(merge: true));
    return "Event updated successfully";
  }

  Stream<QuerySnapshot> buscarListas(AppUser? user) {
    String? userId = user!.id;
    return _collectionRef
        .where('usuarioCriador', isEqualTo: userId)
        .orderBy('nome')
        .snapshots();
  }

  Future<Map<String, dynamic>> excluirLista(String? id) async {
    try {
      await _collectionRef.doc(id).delete();

      return {
        'success': true,
        'message': 'Lista Excluida',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao excluir a lista: $e'};
    }
  }

  CollectionReference<Item> _itemsRef(String id) => _collectionRef
      .doc(id)
      .collection('itens') // Nome da subcoleção de itens
      .withConverter<Item>(
        fromFirestore: Item.fromFirestore,
        toFirestore: (Item item, _) => item.toFirestore(),
      );

  Stream<List<Item>> getItemsStream(String id) {
    return _itemsRef(id)
        .orderBy('createdAt',
            descending: false) // Ordena por data de criação (ou como preferir)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addItem(String id, Item item) async {
    try {
      await _itemsRef(id).add(item);
      print('Item "${item.itemNome}" adicionado com sucesso à lista $id');
    } catch (e) {
      print('Erro ao adicionar item à lista $id: $e');
      // Re-throw para que a UI possa tratar o erro, se necessário
      rethrow;
    }
  }

  Future<void> updateItemStatus(
      String id, String idItem, bool newStatus) async {
    try {
      await _itemsRef(id).doc(idItem).update({
        'isBought': newStatus,
        'updatedAt': Timestamp.now(),
      });
      print('Status do item $idItem atualizado para $newStatus na lista $id');
    } catch (e) {
      print('Erro ao atualizar status do item $idItem na lista $id: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id, String idItem) async {
    try {
      await _itemsRef(id).doc(idItem).delete();
      print('Item $id removido com sucesso da lista $id');
    } catch (e) {
      print('Erro ao remover item $idItem da lista $id: $e');
      rethrow;
    }
  }
}
