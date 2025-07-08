import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;

  cadastrarUsuario({
    required String nome,
    required String senha,
    required String email,
  }) async {
    UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    await userCredential.user!.updateDisplayName(nome);
  }
}
