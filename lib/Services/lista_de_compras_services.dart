import 'dart:async';
import 'package:app_lcc/Models/lista_de_compras.dart';
import 'package:app_lcc/Models/listas_por_usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../Models/item.dart';

class ListaDeComprasServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  CollectionReference get _collectionRefLista =>
      _firestore.collection("listas");
  CollectionReference get _collectionRefListasPorUsuario =>
      _firestore.collection("listasPorUsuario");

  Future<Map<String, dynamic>> salvarLista(ListaDeCompras lista) async {
    dynamic resultado;

    lista.usuarioCriador = user!.uid;


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
  final userId = user!.uid;

  lista.acessos = {
    userId: {
      'podeVisualizar': true,
      'podeEditar': true,
      'podeExcluir': true,
    }
  };

  DocumentReference docRef = await _collectionRefLista.add(lista.toJson());

  await docRef.update({'id': docRef.id});

  return "Lista criada com sucesso";
}

Future<String> atualizarLista(ListaDeCompras lista) async {
  await _collectionRefLista
      .doc(lista.id)
      .set(lista.toJson(), SetOptions(merge: true));
  return "Lista atualizada com sucesso";
}

  Stream<QuerySnapshot> buscarListas() {
  String? userId = user?.uid;
  if (userId == null) return const Stream.empty();

  return _collectionRefLista
      .where('acessos.$userId.podeVisualizar', isEqualTo: true)
      .snapshots();
  }


  Future<Map<String, dynamic>> excluirLista(String? id) async {
    try {
      await _collectionRefLista.doc(id).delete();

      return {
        'success': true,
        'message': 'Lista Excluida',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao excluir a lista: $e'};
    }
  }
Future<Map<String, dynamic>> compartilharLista(
  String? listaId,
  String email,
  String permissao,
) async {
  try {
    var idUsuario = await retornarIdUsuarioPeloEmail(email);
    if (idUsuario == null) {
      return {
        'success': false,
        'message': 'Usuário com o e-mail $email não encontrado.',
      };
    }

    bool podeVisualizar = false;
    bool podeEditar = false;
    bool podeExcluir = false;

    switch (permissao) {
      case 'convidado':
        podeVisualizar = true;
        break;

      case 'participante':
        podeVisualizar = true;
        podeEditar = true;
        break;

      case 'administrador':
        podeVisualizar = true;
        podeEditar = true;
        podeExcluir = true;
        break;

      default:
        return {
          'success': false,
          'message': 'Permissão inválida',
        };
    }

    await _collectionRefLista.doc(listaId).update({
      'acessos.$idUsuario': {
        'podeVisualizar': podeVisualizar,
        'podeEditar': podeEditar,
        'podeExcluir': podeExcluir,
      }
    });

    return {
      'success': true,
      'message': 'Lista compartilhada com sucesso!',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Erro ao compartilhar a lista: $e',
    };
  }
}

  CollectionReference<Item> _itemsRef(String listId) => _collectionRefLista
      .doc(listId)
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

  Future<String?> retornarIdUsuarioPeloEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null; 
      }
    } catch (e) {
      print('Erro ao buscar usuário por e-mail: $e');
      return null;
    }
  }

Future<DocumentSnapshot<Map<String, dynamic>>?> getListaDocumento(String? id) async {
  if (id == null) return null;

  try {
    final doc = await _collectionRefLista.doc(id).get();
    return doc as DocumentSnapshot<Map<String, dynamic>>;
  } catch (e) {
    print('Erro ao buscar documento da lista: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getUserAccessForList(String listId, String userId) async {
  final doc = await FirebaseFirestore.instance.collection('listas').doc(listId).get();
  if (!doc.exists) return null;
  final acessos = doc.get('acessos') as Map<String, dynamic>?;
  if (acessos == null) return null;
  return acessos[userId] as Map<String, dynamic>?;
}


}
