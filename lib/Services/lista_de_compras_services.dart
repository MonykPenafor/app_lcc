import 'dart:async';
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
      if (lista.id != null) 
      {
        resultado = await atualizarLista(lista);
      } 
      else 
      {
        resultado = await criarLista(lista);
      }

      return {
        'success': true,
        'message': resultado,
      };
    } 
    catch (e) {
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
      await _collectionRef.doc(lista.id).set(lista.toJson(), SetOptions(merge: true));
      return "Event updated successfully";
  }


  Stream<QuerySnapshot> buscarListas(AppUser? user) {
    String? userId = user!.id;
    return _collectionRef
        .where('usuarioCriador', isEqualTo: userId)
        .orderBy('nome')
        .snapshots();
  }
  

  Future<Map<String, dynamic>> excluirLista(String? listaId) async {
    try {
            
      await _collectionRef.doc(listaId).delete();

      return {
        'success': true,
        'message': 'Lista Excluida',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro ao excluir a lista: $e'};
    }
  }


}


