
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaDeCompras {
  String? id;
  String? nome;
  String? categoria;
  String? usuarioCriador;

  ListaDeCompras(
    {
    this.id,
    this.nome,
    this.categoria,
    this.usuarioCriador,
  });

 Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'usuarioCriador': usuarioCriador,
    };
  }

  factory ListaDeCompras.fromJson(Map<String, dynamic> map, String id) {
    return ListaDeCompras(
      id: id,
      nome: map['nome'],
      categoria: map['categoria'],
      usuarioCriador: map['usuarioCriador'],
    );
  }

  ListaDeCompras.fromDocument(DocumentSnapshot doc){
    id = doc.id;
    nome = doc.get('nome');
    categoria = doc.get('categoria');
    usuarioCriador = doc.get('usuarioCriador');
  }

}