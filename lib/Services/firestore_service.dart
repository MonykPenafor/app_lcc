import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usuarios = FirebaseFirestore.instance.collection('usuarios');

  Future<void> atualizarNomeUsuario(String uid, String novoNome) async {
    await usuarios.doc(uid).update({'nome': novoNome});
  }

  Future<String?> buscarNomeUsuario(String uid) async {
    final doc = await usuarios.doc(uid).get();
    return doc.exists ? doc.get('nome') : null;
  }
}
