import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Usuário atualmente autenticado
  User? get usuarioAtual => _auth.currentUser;

  /// Altera a senha do usuário logado
  Future<void> alterarSenha(String novaSenha) async {
    if (usuarioAtual != null) {
      await usuarioAtual!.updatePassword(novaSenha);
    }
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    await _auth.signOut();
  }
}

