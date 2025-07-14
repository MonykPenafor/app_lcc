import 'package:cloud_firestore/cloud_firestore.dart';

class ListaDeCompras {
  String? id;
  String? nome;
  String? categoria;
  String? usuarioCriador;
  Map<String, Map<String, bool>>? acessos;

  ListaDeCompras({
    this.id,
    this.nome,
    this.categoria,
    this.usuarioCriador,
    this.acessos,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoria': categoria,
      'usuarioCriador': usuarioCriador,
      'acessos': acessos,
    };
  }

  factory ListaDeCompras.fromJson(Map<String, dynamic> map, String id) {
    return ListaDeCompras(
      id: id,
      nome: map['nome'],
      categoria: map['categoria'],
      usuarioCriador: map['usuarioCriador'],
      acessos: (map['acessos'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          Map<String, bool>.from(value as Map),
        ),
      ),
    );
  }

 ListaDeCompras.fromDocument(DocumentSnapshot doc) {
  id = doc.id;
  nome = doc.get('nome');
  categoria = doc.get('categoria');
  usuarioCriador = doc.get('usuarioCriador');

  if (doc.data() != null && (doc.data() as Map).containsKey('acessos')) {
    final rawAcessos = doc.get('acessos') as Map<String, dynamic>?;
    if (rawAcessos != null) {
      acessos = rawAcessos.map((key, value) {
        return MapEntry(key, Map<String, bool>.from(value as Map));
      });
    }
  } else {
    acessos = {}; 
  }
}

}
