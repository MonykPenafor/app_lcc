
import 'package:cloud_firestore/cloud_firestore.dart';

class ListasPorUsuarios {
  String? id;
  String? listaId;
  String? usuarioId;
  bool? podeVisualizar;
  bool? podeEditar;
  bool? podeExcluir;

  ListasPorUsuarios(
    {
    this.id,
    this.listaId,
    this.usuarioId,
    this.podeVisualizar,
    this.podeEditar,
    this.podeExcluir,
  });

 Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listaId': listaId,
      'usuarioId': usuarioId,
      'podeVisualizar': podeVisualizar,
      'podeEditar': podeEditar,
      'podeExcluir': podeExcluir
    };
  }

  factory ListasPorUsuarios.fromJson(Map<String, dynamic> map, String id) {
    return ListasPorUsuarios(
      id: id,
      listaId: map['listaId'],
      usuarioId: map['usuarioId'],
      podeVisualizar: map['podeVisualizar'],
      podeEditar: map['podeEditar'],
      podeExcluir: map['podeExcluir'],
    );
  }

  ListasPorUsuarios.fromDocument(DocumentSnapshot doc){
    id = doc.id;
    listaId = doc.get('listaId');
    usuarioId = doc.get('usuarioId');
    podeVisualizar = doc.get('podeVisualizar');
    podeEditar = doc.get('podeEditar');
    podeExcluir = doc.get('podeExcluir');
  }

}