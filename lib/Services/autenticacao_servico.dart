import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutenticacaoServico {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> cadastrarUsuario({
    required String nome,
    required String senha,
    required String email,
  }) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = userCredential.user;

      // Atualiza o displayName
      await user!.updateDisplayName(nome);

      // Salva os dados no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'nome': nome,
        'email': email,
        'uid': user.uid,
        'criadoEm': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Erro ao cadastrar e salvar usuário: $e');
      rethrow;
    }
  }
}
