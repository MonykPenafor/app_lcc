import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  String id;
  String nome;
  String email;
  String senha;

  UsuarioModel(
      {required this.id,
      required this.nome,
      required this.email,
      required this.senha});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "senha": senha,
    };
  }

  UsuarioModel.fromJson(DocumentSnapshot doc) {
    id = doc.id;
    nome = doc.get('nome');
    email = doc.get('email');
  }
}
